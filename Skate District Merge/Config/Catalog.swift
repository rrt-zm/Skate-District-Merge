import Foundation

struct TierDef {
    let name: String
}

struct ChainDefinition {
    let id: ChainID
    let title: String
    let accentHex: String
    let symbol: String
    let tiers: [TierDef]

    var maxTier: Int { tiers.count }

    func name(tier: Int) -> String {
        guard tier >= 1 && tier <= tiers.count else { return "Unknown" }
        return tiers[tier - 1].name
    }
}

struct GeneratorDef {
    let id: GeneratorID
    let title: String
    let blurb: String
    let chain: ChainID
    let unlockLevel: Int
    let baseCapacity: Int
    let capacityStep: Int
    let baseRefill: Double
    let refillStep: Double
    let minRefill: Double
    let maxUpgradeLevel: Int

    func capacity(level: Int) -> Int { baseCapacity + capacityStep * (level - 1) }

    func refillSeconds(level: Int) -> Double {
        max(minRefill, baseRefill - refillStep * Double(level - 1))
    }
}

struct ZoneDef {
    let id: ZoneID
    let title: String
    let blurb: String
    let cost: Int
    let unlockLevel: Int
    let structures: [String]
    let skaterBonus: Int
}

struct QuestDef: Identifiable {
    let id: String
    let chapter: Int
    let order: Int
    let title: String
    let detail: String
    let goal: Objective
    let reward: Reward
}

struct AchievementDef: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let goal: Objective
    let reward: Reward
}

struct BoostDef: Identifiable {
    let id: BoostID
    let title: String
    let blurb: String
    let symbol: String
    let duration: TimeInterval
    let multiplier: Double
}
