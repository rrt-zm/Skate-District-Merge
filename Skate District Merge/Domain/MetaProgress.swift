import Foundation

struct Reward: Codable, Hashable {
    var coins: Int
    var xp: Int
    var cred: Int
    var boost: BoostID?

    init(coins: Int = 0, xp: Int = 0, cred: Int = 0, boost: BoostID? = nil) {
        self.coins = coins
        self.xp = xp
        self.cred = cred
        self.boost = boost
    }
}

struct Objective: Codable, Hashable {
    enum Kind: String, Codable {
        case merge
        case createItem
        case fulfillRequest
        case attractSkaters
        case landTricks
        case tapGenerator
        case reachLevel
        case unlockZone
        case spendCoins
        case useBoost
    }

    var kind: Kind
    var chain: ChainID?
    var tier: Int?
    var target: Int
}

enum BoostID: String, Codable, CaseIterable, Identifiable, Hashable {
    case sessionTime
    case coinRush
    case gritSurge
    case crowdHype

    var id: String { rawValue }
}

struct ActiveBoost: Codable, Identifiable, Hashable {
    var id: BoostID
    var endsAt: Date
}

struct BoostInventory: Codable {
    var owned: [BoostID: Int]
    var active: [ActiveBoost]

    static var initial: BoostInventory {
        BoostInventory(owned: [:], active: [])
    }
}

struct Statistics: Codable {
    var merges: Int = 0
    var itemsCreated: Int = 0
    var requestsFilled: Int = 0
    var skatersAttracted: Int = 0
    var structuresBuilt: Int = 0
    var tricksLanded: Int = 0
    var coinsEarned: Int = 0
    var coinsSpent: Int = 0
    var generatorTaps: Int = 0
    var boostsUsed: Int = 0
    var zonesUnlocked: Int = 1
    var secondsPlayed: Int = 0
    var highestTier: [String: Int] = [:]
    var mergesByChain: [String: Int] = [:]
    var createdByChain: [String: Int] = [:]

    static var initial: Statistics { Statistics() }
}

struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var highQuality: Bool = true
    var onboardingComplete: Bool = false

    static var initial: GameSettings { GameSettings() }
}

enum GameEvent {
    case merged(ItemKind)
    case itemCreated(ItemKind)
    case generatorTapped(GeneratorID)
    case requestFulfilled(Order)
    case zoneUnlocked(ZoneID)
    case skatersAttracted(Int)
    case trickLanded
    case leveledUp(Int)
    case coinsSpent(Int)
    case boostUsed(BoostID)
}
