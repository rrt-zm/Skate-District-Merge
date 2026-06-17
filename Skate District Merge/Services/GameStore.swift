import Foundation
import SwiftUI
import Observation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case requests
    case build
    case gear
    case codex

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "District"
        case .requests: return "Orders"
        case .build: return "Build"
        case .gear: return "Gear"
        case .codex: return "Codex"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "square.grid.3x3.fill"
        case .requests: return "list.bullet.clipboard.fill"
        case .build: return "hammer.fill"
        case .gear: return "shippingbox.fill"
        case .codex: return "books.vertical.fill"
        }
    }
}

enum MenuRoute: String, Identifiable {
    case quests
    case achievements
    case statistics
    case settings

    var id: String { rawValue }
}

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let symbol: String
    let tintHex: String
}

struct AwaySummary: Identifiable {
    let id = UUID()
    let seconds: Double
    let energyByGenerator: [GeneratorID: Int]
    var totalEnergy: Int { energyByGenerator.values.reduce(0, +) }
}

enum UpgradeKind {
    case capacity
    case rate
    case quality
}

@Observable
final class GameStore {
    private(set) var state: GameState

    var selectedTab: AppTab = .home
    var menuRoute: MenuRoute?
    var toasts: [ToastMessage] = []
    var achievementQueue: [AchievementDef] = []
    var levelUpBanner: Int?
    var awaySummary: AwaySummary?
    var newlyDiscovered: ItemKind?
    var celebrationToken: Int = 0

    @ObservationIgnored private let save: SaveService
    @ObservationIgnored let audio: AudioHapticsService
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var lastTick = Date()
    @ObservationIgnored private var trickAccumulator: Double = 0
    @ObservationIgnored private var secondsAccumulator: Double = 0
    @ObservationIgnored private var spawnSalt: UInt64 = 0x51A7E
    @ObservationIgnored private var dirty = false
    @ObservationIgnored private var announcedQuests: Set<String> = []

    init(save: SaveService, audio: AudioHapticsService) {
        self.save = save
        self.audio = audio
        let now = Date()
        if let loaded = save.load() {
            self.state = loaded
            applyOfflineProgress(now: now)
        } else {
            self.state = InitialState.make(now: now)
        }
        syncAudioSettings()
        ensureOrders()
        announcedQuests = Set(QuestEngine.newlyClaimable(progress: state.questProgress, claimed: state.questsClaimed).map { $0.id })
    }

    func start() {
        audio.configureSession()
        audio.syncMusic()
        lastTick = Date()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick(Date())
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        saveNow()
    }

    var generatorSpeedMultiplier: Double {
        BoostService.multiplier(.sessionTime, state: state, now: Date())
    }

    var liveSkaterCount: Int {
        let base = state.district.unlockedZones.reduce(0) { $0 + GameContent.zone($1).skaterBonus }
        return min(18, base / 2 + state.attractedSkaters / 5 + 1)
    }

    var unlockedChains: [ChainID] {
        var seen = Set<ChainID>()
        var result: [ChainID] = []
        for runtime in state.generators where runtime.unlocked {
            let chain = GameContent.generator(runtime.id).chain
            if seen.insert(chain).inserted { result.append(chain) }
        }
        return result.isEmpty ? [.boards] : result
    }

    private func tick(_ now: Date) {
        let dt = min(5.0, max(0, now.timeIntervalSince(lastTick)))
        lastTick = now

        BoostService.cleanup(&state, now: now)
        let speed = BoostService.multiplier(.sessionTime, state: state, now: now)
        for index in state.generators.indices {
            EnergyService.advance(&state.generators[index], now: now, speedMultiplier: speed)
        }

        let hype = BoostService.multiplier(.crowdHype, state: state, now: now)
        trickAccumulator += dt * Double(liveSkaterCount) * 0.1 * hype
        var tricks = 0
        while trickAccumulator >= 1 && tricks < 30 {
            trickAccumulator -= 1
            dispatch(.trickLanded)
            tricks += 1
        }

        secondsAccumulator += dt
        if secondsAccumulator >= 1 {
            let whole = Int(secondsAccumulator)
            state.statistics.secondsPlayed += whole
            secondsAccumulator -= Double(whole)
        }

        refillOrders(now: now)
        state.lastSeen = now

        if tricks > 0 { checkClaimables() }
        if dirty { saveNow() }
    }

    private func applyOfflineProgress(now: Date) {
        let elapsed = now.timeIntervalSince(state.lastSeen)
        guard elapsed > 30 else {
            state.lastSeen = now
            return
        }
        let capped = min(elapsed, Balance.offlineCapSeconds)
        let reference = now.addingTimeInterval(-capped)
        var gained: [GeneratorID: Int] = [:]
        for index in state.generators.indices {
            guard state.generators[index].unlocked else { continue }
            if state.generators[index].refillReference < reference {
                state.generators[index].refillReference = reference
            }
            let before = state.generators[index].energy
            EnergyService.advance(&state.generators[index], now: now, speedMultiplier: 1.0)
            let delta = state.generators[index].energy - before
            if delta > 0 { gained[state.generators[index].id] = delta }
        }
        state.lastSeen = now
        if !gained.isEmpty {
            awaySummary = AwaySummary(seconds: capped, energyByGenerator: gained)
        }
    }

    private func ensureOrders() {
        while state.orders.count < Balance.maxActiveOrders {
            state.orders.append(makeOrder())
        }
    }

    private func refillOrders(now: Date) {
        if state.orders.count >= Balance.maxActiveOrders {
            state.orderReference = now
            return
        }
        if now.timeIntervalSince(state.orderReference) >= Balance.orderRefillSeconds {
            state.orders.append(makeOrder())
            state.orderReference = now
            dirty = true
        }
    }

    private func makeOrder() -> Order {
        spawnSalt = spawnSalt &* 6364136223846793005 &+ 1442695040888963407
        let seed = spawnSalt
            &+ UInt64(state.statistics.requestsFilled &* 2654435761)
            &+ UInt64(state.statistics.secondsPlayed &+ 17)
        return OrderService.generate(level: state.progress.level, unlockedChains: unlockedChains, seed: seed)
    }

    @discardableResult
    func tapGenerator(_ id: GeneratorID) -> ItemKind? {
        guard let index = state.generators.firstIndex(where: { $0.id == id }) else { return nil }
        let now = Date()
        let speed = BoostService.multiplier(.sessionTime, state: state, now: now)
        EnergyService.advance(&state.generators[index], now: now, speedMultiplier: speed)
        guard GeneratorService.canTap(state.generators[index], board: state.board),
              let slot = state.board.firstEmptyPlayableIndex else {
            audio.warning()
            return nil
        }
        spawnSalt = spawnSalt &* 2862933555777941757 &+ 3037000493
        var rng = SeededRandom(seed: spawnSalt)
        let kind = GeneratorService.produce(&state.generators[index], rng: &rng)
        state.board.place(BoardItem(kind: kind), at: slot)
        audio.play(.spawn)
        audio.impact(.light)
        dispatch(.generatorTapped(id))
        dispatch(.itemCreated(kind))
        afterAction()
        return kind
    }

    @discardableResult
    func performDrop(from: Int, to: Int) -> DropResult {
        let result = MergeEngine.drop(&state.board, from: from, to: to)
        switch result {
        case let .merged(kind):
            let xpMult = BoostService.multiplier(.gritSurge, state: state, now: Date())
            let xp = Int(Double(Balance.mergeXP(tier: kind.tier)) * xpMult)
            let coins = Balance.mergeCoins(tier: kind.tier)
            state.coins += coins
            state.statistics.coinsEarned += coins
            let levels = EconomyService.addXP(&state, xp)
            dispatch(.merged(kind))
            dispatch(.itemCreated(kind))
            applyLevels(levels)
            audio.play(.merge)
            audio.impact(.medium)
            if MergeEngine.isMaxed(kind) { audio.success() }
            afterAction()
        case .moved, .swapped:
            audio.impact(.light)
            dirty = true
        case .invalid:
            break
        }
        return result
    }

    func sellItem(at index: Int) {
        guard state.board.isPlayable(index: index), let item = state.board.cells[index] else { return }
        let value = Balance.sellValue(item.kind)
        state.board.cells[index] = nil
        state.coins += value
        state.statistics.coinsEarned += value
        audio.play(.tap)
        audio.impact(.light)
        toast("Sold for \(value)", symbol: "dollarsign.circle.fill", tint: "FFD23F")
        afterAction()
    }

    @discardableResult
    func fulfill(_ order: Order) -> Bool {
        guard let stored = state.orders.first(where: { $0.id == order.id }),
              OrderService.canFulfill(stored, board: state.board) else {
            audio.warning()
            return false
        }
        OrderService.fulfill(stored, board: &state.board)
        let now = Date()
        let coinMult = BoostService.multiplier(.coinRush, state: state, now: now)
        let coins = Int(Double(stored.rewardCoins) * coinMult)
        state.coins += coins
        state.cred += stored.rewardCred
        state.statistics.coinsEarned += coins
        let levels = EconomyService.addXP(&state, stored.rewardXP)
        state.orders.removeAll { $0.id == stored.id }
        dispatch(.requestFulfilled(stored))
        dispatch(.skatersAttracted(1))
        applyLevels(levels)
        audio.play(.reward)
        audio.success()
        celebrate()
        toast("+\(EconomyService.format(coins)) coins", symbol: "checkmark.seal.fill", tint: "20E0D6")
        afterAction()
        return true
    }

    func upgrade(_ id: GeneratorID, kind: UpgradeKind) {
        guard let index = state.generators.firstIndex(where: { $0.id == id }) else { return }
        let def = GameContent.generator(id)
        var runtime = state.generators[index]
        let cost: Int
        switch kind {
        case .capacity:
            guard runtime.capacityLevel < def.maxUpgradeLevel else { return }
            cost = Balance.capacityUpgradeCost(level: runtime.capacityLevel)
        case .rate:
            guard runtime.rateLevel < def.maxUpgradeLevel else { return }
            cost = Balance.rateUpgradeCost(level: runtime.rateLevel)
        case .quality:
            guard runtime.qualityLevel < def.maxUpgradeLevel else { return }
            cost = Balance.qualityUpgradeCost(level: runtime.qualityLevel)
        }
        guard EconomyService.spend(&state, coins: cost) else {
            audio.warning()
            return
        }
        switch kind {
        case .capacity: runtime.capacityLevel += 1
        case .rate: runtime.rateLevel += 1
        case .quality: runtime.qualityLevel += 1
        }
        state.generators[index] = runtime
        dispatch(.coinsSpent(cost))
        audio.play(.unlock)
        audio.impact(.rigid)
        toast("Upgraded \(def.title)", symbol: "arrow.up.circle.fill", tint: "B14EFF")
        afterAction()
    }

    func expandBoard() {
        guard state.board.unlockedRows < state.board.maxRows else { return }
        let cost = Balance.boardExpansionCost(currentRows: state.board.unlockedRows)
        guard EconomyService.spend(&state, coins: cost) else {
            audio.warning()
            return
        }
        state.board.unlockedRows += 1
        dispatch(.coinsSpent(cost))
        audio.play(.unlock)
        audio.impact(.rigid)
        celebrate()
        toast("Board expanded", symbol: "square.grid.3x3.fill", tint: "20E0D6")
        afterAction()
    }

    func canUnlockZone(_ id: ZoneID) -> Bool {
        let def = GameContent.zone(id)
        return !state.district.unlockedZones.contains(id)
            && state.progress.level >= def.unlockLevel
            && state.cred >= def.cost
    }

    func unlockZone(_ id: ZoneID) {
        guard canUnlockZone(id) else {
            audio.warning()
            return
        }
        let def = GameContent.zone(id)
        guard EconomyService.spendCred(&state, cred: def.cost) else { return }
        state.district.unlockedZones.insert(id)
        dispatch(.zoneUnlocked(id))
        dispatch(.skatersAttracted(def.skaterBonus))
        audio.play(.unlock)
        audio.success()
        celebrate()
        toast("\(def.title) unlocked!", symbol: "map.fill", tint: "FF2E97")
        afterAction()
    }

    func claimQuest(_ id: String) {
        guard let def = GameContent.quest(id),
              QuestEngine.isComplete(def, progress: state.questProgress),
              !state.questsClaimed.contains(id) else { return }
        state.questsClaimed.insert(id)
        let levels = EconomyService.grantReward(&state, def.reward)
        applyLevels(levels)
        audio.play(.reward)
        audio.success()
        celebrate()
        if let boost = def.reward.boost {
            toast("Earned \(GameContent.boost(boost).title)", symbol: "gift.fill", tint: "FFD23F")
        } else {
            toast("Quest reward claimed", symbol: "checkmark.seal.fill", tint: "FFD23F")
        }
        afterAction()
    }

    func activateBoost(_ id: BoostID) {
        guard BoostService.activate(id, state: &state, now: Date()) else {
            audio.warning()
            return
        }
        dispatch(.boostUsed(id))
        audio.play(.unlock)
        audio.impact(.medium)
        toast("\(GameContent.boost(id).title) active", symbol: GameContent.boost(id).symbol, tint: "FF7A3C")
        afterAction()
    }

    func setSound(_ enabled: Bool) {
        state.settings.soundEnabled = enabled
        syncAudioSettings()
        scheduleSave()
    }

    func setMusic(_ enabled: Bool) {
        state.settings.musicEnabled = enabled
        syncAudioSettings()
        audio.syncMusic()
        scheduleSave()
    }

    func setHaptics(_ enabled: Bool) {
        state.settings.hapticsEnabled = enabled
        syncAudioSettings()
        scheduleSave()
    }

    func setHighQuality(_ enabled: Bool) {
        state.settings.highQuality = enabled
        scheduleSave()
    }

    func completeOnboarding() {
        state.settings.onboardingComplete = true
        saveNow()
    }

    func resetTutorial() {
        state.settings.onboardingComplete = false
        saveNow()
    }

    func resetProgress() {
        state = InitialState.make(now: Date())
        ensureOrders()
        announcedQuests = []
        syncAudioSettings()
        saveNow()
        toast("Progress reset", symbol: "arrow.counterclockwise", tint: "FF2E97")
    }

    func dismissAway() {
        awaySummary = nil
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            lastTick = Date()
            audio.syncMusic()
        case .background, .inactive:
            saveNow()
            audio.stopMusic()
        @unknown default:
            break
        }
    }

    private func dispatch(_ event: GameEvent) {
        switch event {
        case let .merged(kind):
            state.statistics.merges += 1
            state.statistics.mergesByChain[kind.chain.rawValue, default: 0] += 1
        case let .itemCreated(kind):
            state.statistics.itemsCreated += 1
            state.statistics.createdByChain[kind.chain.rawValue, default: 0] += 1
            let highest = state.statistics.highestTier[kind.chain.rawValue] ?? 0
            if kind.tier > highest {
                state.statistics.highestTier[kind.chain.rawValue] = kind.tier
            }
            if !state.discovered.contains(kind.id) {
                state.discovered.insert(kind.id)
                newlyDiscovered = kind
                toast("Discovered \(GameContent.name(for: kind))", symbol: "sparkle.magnifyingglass", tint: GameContent.chain(kind.chain).accentHex)
            }
        case .generatorTapped:
            state.statistics.generatorTaps += 1
        case .requestFulfilled:
            state.statistics.requestsFilled += 1
        case let .zoneUnlocked(zone):
            state.statistics.zonesUnlocked += 1
            state.statistics.structuresBuilt += GameContent.zone(zone).structures.count
        case let .skatersAttracted(amount):
            state.statistics.skatersAttracted += amount
            state.attractedSkaters += amount
        case .trickLanded:
            state.statistics.tricksLanded += 1
        default:
            break
        }
        QuestEngine.apply(event, progress: &state.questProgress)
        AchievementEngine.apply(event, progress: &state.achievementProgress)
    }

    private func applyLevels(_ levels: [Int]) {
        guard !levels.isEmpty else { return }
        for level in levels {
            dispatch(.leveledUp(level))
        }
        levelUpBanner = levels.last
        unlockEligibleGenerators()
        audio.play(.levelUp)
        audio.success()
        celebrate()
    }

    private func unlockEligibleGenerators() {
        for index in state.generators.indices {
            let def = GameContent.generator(state.generators[index].id)
            if !state.generators[index].unlocked && state.progress.level >= def.unlockLevel {
                state.generators[index].unlocked = true
                state.generators[index].energy = def.capacity(level: state.generators[index].capacityLevel)
                state.generators[index].refillReference = Date()
                toast("\(def.title) unlocked", symbol: "lock.open.fill", tint: GameContent.chain(def.chain).accentHex)
            }
        }
    }

    private func checkClaimables() {
        var guardCount = 0
        while guardCount < 8 {
            guardCount += 1
            let claimable = AchievementEngine.newlyClaimable(progress: state.achievementProgress, claimed: state.achievementsClaimed)
            guard let def = claimable.first else { break }
            state.achievementsClaimed.insert(def.id)
            let levels = EconomyService.grantReward(&state, def.reward)
            achievementQueue.append(def)
            audio.play(.levelUp)
            audio.success()
            celebrate()
            applyLevels(levels)
        }
        for quest in QuestEngine.newlyClaimable(progress: state.questProgress, claimed: state.questsClaimed) where !announcedQuests.contains(quest.id) {
            announcedQuests.insert(quest.id)
            toast("Quest ready: \(quest.title)", symbol: "flag.checkered", tint: "9BE564")
        }
    }

    private func afterAction() {
        checkClaimables()
        scheduleSave()
    }

    private func celebrate() {
        celebrationToken += 1
    }

    private func toast(_ text: String, symbol: String, tint: String) {
        let message = ToastMessage(text: text, symbol: symbol, tintHex: tint)
        toasts.append(message)
        if toasts.count > 4 {
            toasts.removeFirst(toasts.count - 4)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) { [weak self] in
            self?.toasts.removeAll { $0.id == message.id }
        }
    }

    func dequeueAchievement() {
        if !achievementQueue.isEmpty {
            achievementQueue.removeFirst()
        }
    }

    private func syncAudioSettings() {
        audio.soundEnabled = state.settings.soundEnabled
        audio.musicEnabled = state.settings.musicEnabled
        audio.hapticsEnabled = state.settings.hapticsEnabled
    }

    private func scheduleSave() {
        dirty = true
    }

    private func saveNow() {
        save.save(state)
        dirty = false
    }
}
