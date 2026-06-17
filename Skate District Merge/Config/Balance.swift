import Foundation

enum Balance {
    static let boardColumns = 6
    static let initialRows = 5
    static let maxRows = 9

    static let maxActiveOrders = 4
    static let orderRefillSeconds: Double = 26
    static let offlineCapSeconds: Double = 8 * 60 * 60

    static func xpToNext(level: Int) -> Int {
        Int(45.0 * pow(1.16, Double(max(0, level - 1)))) + level * 8
    }

    static func mergeXP(tier: Int) -> Int { 2 + tier * 2 }
    static func mergeCoins(tier: Int) -> Int { max(1, tier) }

    static func itemValue(tier: Int) -> Int {
        Int(5.0 * pow(1.9, Double(max(0, tier - 1))))
    }

    static func sellValue(_ kind: ItemKind) -> Int {
        max(1, itemValue(tier: kind.tier) / 2)
    }

    static func capacityUpgradeCost(level: Int) -> Int {
        Int(35.0 * pow(1.7, Double(max(0, level - 1))))
    }

    static func rateUpgradeCost(level: Int) -> Int {
        Int(45.0 * pow(1.75, Double(max(0, level - 1))))
    }

    static func qualityUpgradeCost(level: Int) -> Int {
        Int(80.0 * pow(1.9, Double(max(0, level - 1))))
    }

    static func boardExpansionCost(currentRows: Int) -> Int {
        Int(220.0 * pow(2.0, Double(max(0, currentRows - initialRows))))
    }

    static func qualityTierTwoChance(level: Int) -> Double {
        min(0.5, Double(level - 1) * 0.07)
    }

    static func qualityTierThreeChance(level: Int) -> Double {
        min(0.18, Double(max(0, level - 2)) * 0.025)
    }

    static func orderReward(for requirements: [Requirement]) -> (coins: Int, xp: Int, cred: Int) {
        var value = 0
        for req in requirements {
            value += itemValue(tier: req.kind.tier) * req.count
        }
        let coins = Int(Double(value) * 1.35) + 15
        let xp = max(10, value / 3 + 8)
        let cred = max(1, value / 60 + 1)
        return (coins, xp, cred)
    }
}
