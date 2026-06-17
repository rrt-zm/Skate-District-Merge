import Foundation

enum OrderService {
    static func reachableTier(chain: ChainID, level: Int) -> Int {
        let cap = GameContent.maxTier(chain)
        return min(cap, max(1, 2 + level / 3))
    }

    static func generate(level: Int, unlockedChains: [ChainID], seed: UInt64) -> Order {
        var rng = SeededRandom(seed: seed)
        let chains = unlockedChains.isEmpty ? [ChainID.boards] : unlockedChains

        let maxLines = level < 3 ? 1 : (level < 8 ? 2 : 3)
        let lineCount = max(1, rng.int(1...maxLines))

        var requirements: [Requirement] = []
        for _ in 0..<lineCount {
            let chain = chains[rng.int(0...(chains.count - 1))]
            let topTier = reachableTier(chain: chain, level: level)
            let lowTier = max(1, topTier - 2)
            let tier = rng.int(lowTier...topTier)
            let count = rng.chance(0.65) ? 1 : rng.int(2...3)
            let kind = ItemKind(chain: chain, tier: tier)
            if let existing = requirements.firstIndex(where: { $0.kind == kind }) {
                requirements[existing].count += count
            } else {
                requirements.append(Requirement(kind: kind, count: count))
            }
        }

        let reward = Balance.orderReward(for: requirements)
        let name = GameContent.skaterNames[rng.int(0...(GameContent.skaterNames.count - 1))]
        let portrait = rng.int(0...9999)

        return Order(
            skaterName: name,
            portraitSeed: portrait,
            requirements: requirements,
            rewardCoins: reward.coins,
            rewardXP: reward.xp,
            rewardCred: reward.cred
        )
    }

    static func canFulfill(_ order: Order, board: Board) -> Bool {
        for requirement in order.requirements {
            if board.count(of: requirement.kind) < requirement.count { return false }
        }
        return true
    }

    @discardableResult
    static func fulfill(_ order: Order, board: inout Board) -> Bool {
        guard canFulfill(order, board: board) else { return false }
        for requirement in order.requirements {
            var remaining = requirement.count
            for index in 0..<board.cells.count where remaining > 0 {
                if board.cells[index]?.kind == requirement.kind {
                    board.cells[index] = nil
                    remaining -= 1
                }
            }
        }
        return true
    }
}
