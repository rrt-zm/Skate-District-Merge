import Foundation

enum BoostService {
    static func cleanup(_ state: inout GameState, now: Date) {
        state.boosts.active.removeAll { $0.endsAt <= now }
    }

    static func isActive(_ id: BoostID, state: GameState, now: Date) -> Bool {
        state.boosts.active.contains { $0.id == id && $0.endsAt > now }
    }

    @discardableResult
    static func activate(_ id: BoostID, state: inout GameState, now: Date) -> Bool {
        guard (state.boosts.owned[id] ?? 0) > 0 else { return false }
        let def = GameContent.boost(id)
        state.boosts.owned[id]! -= 1
        if state.boosts.owned[id] == 0 { state.boosts.owned[id] = nil }
        if let index = state.boosts.active.firstIndex(where: { $0.id == id }) {
            state.boosts.active[index].endsAt = now.addingTimeInterval(def.duration)
        } else {
            state.boosts.active.append(ActiveBoost(id: id, endsAt: now.addingTimeInterval(def.duration)))
        }
        state.statistics.boostsUsed += 1
        return true
    }

    static func multiplier(_ id: BoostID, state: GameState, now: Date) -> Double {
        isActive(id, state: state, now: now) ? GameContent.boost(id).multiplier : 1.0
    }

    static func remaining(_ id: BoostID, state: GameState, now: Date) -> Double {
        guard let boost = state.boosts.active.first(where: { $0.id == id }) else { return 0 }
        return max(0, boost.endsAt.timeIntervalSince(now))
    }
}
