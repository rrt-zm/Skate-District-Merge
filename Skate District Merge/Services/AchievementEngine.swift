import Foundation

enum AchievementEngine {
    static func apply(_ event: GameEvent, progress: inout [String: Int]) {
        for def in GameContent.achievements {
            let current = progress[def.id] ?? 0
            if current >= def.goal.target { continue }
            switch ObjectiveMatcher.update(for: def.goal, event: event) {
            case .none:
                continue
            case let .increment(amount):
                progress[def.id] = min(def.goal.target, current + amount)
            case let .setAtLeast(value):
                progress[def.id] = min(def.goal.target, max(current, value))
            }
        }
    }

    static func isComplete(_ def: AchievementDef, progress: [String: Int]) -> Bool {
        (progress[def.id] ?? 0) >= def.goal.target
    }

    static func progressValue(_ def: AchievementDef, progress: [String: Int]) -> Int {
        min(def.goal.target, progress[def.id] ?? 0)
    }

    static func newlyClaimable(progress: [String: Int], claimed: Set<String>) -> [AchievementDef] {
        GameContent.achievements.filter { isComplete($0, progress: progress) && !claimed.contains($0.id) }
    }

    static func unlockedCount(progress: [String: Int]) -> Int {
        GameContent.achievements.filter { isComplete($0, progress: progress) }.count
    }
}
