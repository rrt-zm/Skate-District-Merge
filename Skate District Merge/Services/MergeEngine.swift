import Foundation

enum DropResult {
    case moved
    case swapped
    case merged(ItemKind)
    case invalid
}

enum MergeEngine {
    static func nextKind(for kind: ItemKind) -> ItemKind? {
        let maxTier = GameContent.maxTier(kind.chain)
        guard kind.tier < maxTier else { return nil }
        return ItemKind(chain: kind.chain, tier: kind.tier + 1)
    }

    static func canMerge(_ a: BoardItem, _ b: BoardItem) -> Bool {
        guard a.kind == b.kind else { return false }
        return nextKind(for: a.kind) != nil
    }

    static func isMaxed(_ kind: ItemKind) -> Bool {
        nextKind(for: kind) == nil
    }

    @discardableResult
    static func drop(_ board: inout Board, from: Int, to: Int) -> DropResult {
        guard from != to,
              board.isPlayable(index: from),
              board.isPlayable(index: to),
              let source = board.cells[from] else { return .invalid }

        guard let target = board.cells[to] else {
            board.cells[to] = source
            board.cells[from] = nil
            return .moved
        }

        if canMerge(source, target), let result = nextKind(for: source.kind) {
            board.cells[to] = BoardItem(kind: result)
            board.cells[from] = nil
            return .merged(result)
        }

        board.cells[to] = source
        board.cells[from] = target
        return .swapped
    }
}
