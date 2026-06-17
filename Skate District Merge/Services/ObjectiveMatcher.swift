import Foundation

enum ProgressUpdate {
    case none
    case increment(Int)
    case setAtLeast(Int)
}

enum ObjectiveMatcher {
    static func update(for goal: Objective, event: GameEvent) -> ProgressUpdate {
        switch event {
        case let .merged(kind):
            guard goal.kind == .merge else { return .none }
            return matches(goal: goal, kind: kind) ? .increment(1) : .none
        case let .itemCreated(kind):
            guard goal.kind == .createItem else { return .none }
            return matches(goal: goal, kind: kind) ? .increment(1) : .none
        case .generatorTapped:
            return goal.kind == .tapGenerator ? .increment(1) : .none
        case .requestFulfilled:
            return goal.kind == .fulfillRequest ? .increment(1) : .none
        case .zoneUnlocked:
            return goal.kind == .unlockZone ? .increment(1) : .none
        case let .skatersAttracted(amount):
            return goal.kind == .attractSkaters ? .increment(amount) : .none
        case .trickLanded:
            return goal.kind == .landTricks ? .increment(1) : .none
        case let .leveledUp(level):
            return goal.kind == .reachLevel ? .setAtLeast(level) : .none
        case let .coinsSpent(amount):
            return goal.kind == .spendCoins ? .increment(amount) : .none
        case .boostUsed:
            return goal.kind == .useBoost ? .increment(1) : .none
        }
    }

    private static func matches(goal: Objective, kind: ItemKind) -> Bool {
        if let chain = goal.chain, chain != kind.chain { return false }
        if let tier = goal.tier, kind.tier < tier { return false }
        return true
    }
}
