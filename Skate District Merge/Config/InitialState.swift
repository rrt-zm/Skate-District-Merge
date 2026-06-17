import Foundation

enum InitialState {
    static func make(now: Date = Date()) -> GameState {
        var cells = [BoardItem?](repeating: nil, count: Balance.boardColumns * Balance.maxRows)
        let starters: [Int] = [0, 1, 3, 7, 8]
        for index in starters where index < cells.count {
            cells[index] = BoardItem(kind: ItemKind(chain: .boards, tier: 1), spawnedAt: now)
        }

        let board = Board(columns: Balance.boardColumns,
                          unlockedRows: Balance.initialRows,
                          maxRows: Balance.maxRows,
                          cells: cells)

        var generators: [GeneratorRuntime] = []
        for def in GameContent.generators {
            let unlocked = def.unlockLevel <= 1
            generators.append(
                GeneratorRuntime(
                    id: def.id,
                    energy: unlocked ? def.capacity(level: 1) : 0,
                    refillReference: now,
                    unlocked: unlocked
                )
            )
        }

        return GameState(
            version: GameState.currentVersion,
            createdAt: now,
            lastSeen: now,
            board: board,
            generators: generators,
            coins: 75,
            cred: 0,
            progress: .initial,
            orders: [],
            orderReference: now,
            district: .initial,
            boosts: .initial,
            statistics: .initial,
            settings: .initial,
            questProgress: [:],
            questsClaimed: [],
            achievementProgress: [:],
            achievementsClaimed: [],
            discovered: [ItemKind(chain: .boards, tier: 1).id],
            attractedSkaters: 0
        )
    }
}
