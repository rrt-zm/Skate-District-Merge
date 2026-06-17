import Foundation

enum EconomyService {
    @discardableResult
    static func addXP(_ state: inout GameState, _ amount: Int) -> [Int] {
        guard amount > 0 else { return [] }
        state.progress.xp += amount
        var newLevels: [Int] = []
        while state.progress.xp >= Balance.xpToNext(level: state.progress.level) {
            state.progress.xp -= Balance.xpToNext(level: state.progress.level)
            state.progress.level += 1
            newLevels.append(state.progress.level)
        }
        return newLevels
    }

    @discardableResult
    static func grantReward(_ state: inout GameState, _ reward: Reward) -> [Int] {
        state.coins += reward.coins
        state.cred += reward.cred
        state.statistics.coinsEarned += reward.coins
        if let boost = reward.boost {
            state.boosts.owned[boost, default: 0] += 1
        }
        return addXP(&state, reward.xp)
    }

    static func spend(_ state: inout GameState, coins: Int) -> Bool {
        guard state.coins >= coins else { return false }
        state.coins -= coins
        state.statistics.coinsSpent += coins
        return true
    }

    static func spendCred(_ state: inout GameState, cred: Int) -> Bool {
        guard state.cred >= cred else { return false }
        state.cred -= cred
        return true
    }

    static func format(_ value: Int) -> String {
        let abs = Swift.abs(value)
        if abs < 10000 {
            return decimalGrouped(value)
        }
        let units: [(Double, String)] = [
            (1_000_000_000_000, "T"),
            (1_000_000_000, "B"),
            (1_000_000, "M"),
            (1_000, "K")
        ]
        let v = Double(value)
        for (threshold, suffix) in units where Swift.abs(v) >= threshold {
            let scaled = v / threshold
            if scaled >= 100 {
                return String(format: "%.0f%@", scaled, suffix)
            } else if scaled >= 10 {
                return String(format: "%.1f%@", scaled, suffix)
            } else {
                return String(format: "%.2f%@", scaled, suffix)
            }
        }
        return decimalGrouped(value)
    }

    private static func decimalGrouped(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
