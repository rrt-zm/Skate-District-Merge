import Foundation

enum ChainID: String, Codable, CaseIterable, Identifiable, Hashable {
    case boards
    case ramps
    case graffiti
    case lighting
    case shops

    var id: String { rawValue }
}

struct ItemKind: Codable, Hashable, Identifiable {
    let chain: ChainID
    let tier: Int

    var id: String { "\(chain.rawValue).\(tier)" }
}

struct BoardItem: Codable, Identifiable, Hashable {
    var id: UUID
    var kind: ItemKind
    var spawnedAt: Date

    init(kind: ItemKind, id: UUID = UUID(), spawnedAt: Date = Date()) {
        self.id = id
        self.kind = kind
        self.spawnedAt = spawnedAt
    }
}

struct Board: Codable {
    var columns: Int
    var unlockedRows: Int
    var maxRows: Int
    var cells: [BoardItem?]

    var capacity: Int { columns * unlockedRows }

    func index(row: Int, column: Int) -> Int { row * columns + column }

    func isPlayable(index: Int) -> Bool {
        guard index >= 0 && index < cells.count else { return false }
        return index / columns < unlockedRows
    }

    var firstEmptyPlayableIndex: Int? {
        for i in 0..<cells.count where isPlayable(index: i) && cells[i] == nil {
            return i
        }
        return nil
    }

    var emptyPlayableCount: Int {
        var count = 0
        for i in 0..<cells.count where isPlayable(index: i) && cells[i] == nil { count += 1 }
        return count
    }

    var occupiedCount: Int {
        var count = 0
        for i in 0..<cells.count where isPlayable(index: i) && cells[i] != nil { count += 1 }
        return count
    }

    mutating func place(_ item: BoardItem, at index: Int) {
        guard isPlayable(index: index) else { return }
        cells[index] = item
    }

    func count(of kind: ItemKind) -> Int {
        cells.reduce(0) { partial, cell in
            partial + ((cell?.kind == kind) ? 1 : 0)
        }
    }
}
