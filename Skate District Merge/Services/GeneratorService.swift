import Foundation

enum GeneratorService {
    static func canTap(_ runtime: GeneratorRuntime, board: Board) -> Bool {
        runtime.unlocked && runtime.energy > 0 && board.firstEmptyPlayableIndex != nil
    }

    static func produce(_ runtime: inout GeneratorRuntime, rng: inout SeededRandom) -> ItemKind {
        runtime.energy = max(0, runtime.energy - 1)
        let def = GameContent.generator(runtime.id)
        var tier = 1
        if rng.chance(Balance.qualityTierThreeChance(level: runtime.qualityLevel)) {
            tier = 3
        } else if rng.chance(Balance.qualityTierTwoChance(level: runtime.qualityLevel)) {
            tier = 2
        }
        tier = min(tier, GameContent.maxTier(def.chain))
        return ItemKind(chain: def.chain, tier: tier)
    }
}
