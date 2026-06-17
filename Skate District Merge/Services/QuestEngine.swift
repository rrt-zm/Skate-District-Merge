import Foundation

enum QuestEngine {
    static func apply(_ event: GameEvent, progress: inout [String: Int]) {
        for def in GameContent.quests {
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

    static func isComplete(_ def: QuestDef, progress: [String: Int]) -> Bool {
        (progress[def.id] ?? 0) >= def.goal.target
    }

    static func progressValue(_ def: QuestDef, progress: [String: Int]) -> Int {
        min(def.goal.target, progress[def.id] ?? 0)
    }

    static func activeChapter(progress: [String: Int], claimed: Set<String>) -> Int {
        for chapter in chapters {
            let defs = GameContent.quests.filter { $0.chapter == chapter }
            if defs.contains(where: { !claimed.contains($0.id) }) {
                return chapter
            }
        }
        return chapters.last ?? 1
    }

    static var chapters: [Int] {
        Array(Set(GameContent.quests.map { $0.chapter })).sorted()
    }

    static func newlyClaimable(progress: [String: Int], claimed: Set<String>) -> [QuestDef] {
        GameContent.quests.filter { isComplete($0, progress: progress) && !claimed.contains($0.id) }
    }
}
