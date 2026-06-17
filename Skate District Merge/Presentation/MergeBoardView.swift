import SwiftUI

private struct BurstInfo: Equatable {
    var index: Int
    var color: Color
    var token: Int
}

struct MergeBoardView: View {
    @Environment(GameStore.self) private var store
    @State private var dragFrom: Int?
    @State private var dragLocation: CGPoint = .zero
    @State private var burst: BurstInfo?
    @State private var burstToken = 0

    private let spacing: CGFloat = 6

    var body: some View {
        let board = store.state.board
        let cols = board.columns
        let rows = board.unlockedRows

        GeometryReader { geo in
            let cell = (geo.size.width - spacing * CGFloat(cols - 1)) / CGFloat(cols)
            ZStack(alignment: .topLeading) {
                ForEach(0..<(rows * cols), id: \.self) { index in
                    cellView(index: index, board: board, cell: cell)
                        .frame(width: cell, height: cell)
                        .position(center(index: index, cell: cell, cols: cols))
                }

                if let burst {
                    SprayBurst(color: burst.color)
                        .frame(width: cell, height: cell)
                        .position(center(index: burst.index, cell: cell, cols: cols))
                        .id(burst.token)
                        .allowsHitTesting(false)
                }

                if let from = dragFrom, board.isPlayable(index: from), let item = board.cells[from] {
                    ItemTileView(item: item, showBadge: false)
                        .frame(width: cell * 1.12, height: cell * 1.12)
                        .position(dragLocation)
                        .shadow(color: .black.opacity(0.5), radius: 10, y: 6)
                        .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: "board")
        }
        .aspectRatio(CGFloat(cols) / CGFloat(rows), contentMode: .fit)
        .animation(Motion.snappy, value: store.state.board.cells)
    }

    @ViewBuilder
    private func cellView(index: Int, board: Board, cell: CGFloat) -> some View {
        if board.isPlayable(index: index), let item = board.cells[index] {
            ItemTileView(item: item, dimmed: dragFrom == index)
                .id(item.id)
                .transition(.scale.combined(with: .opacity))
                .gesture(dragGesture(index: index, cell: cell))
        } else {
            EmptyCellView(playable: board.isPlayable(index: index))
        }
    }

    private func dragGesture(index: Int, cell: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named("board"))
            .onChanged { value in
                if dragFrom == nil { dragFrom = index }
                dragLocation = value.location
            }
            .onEnded { value in
                let cols = store.state.board.columns
                let rows = store.state.board.unlockedRows
                defer { dragFrom = nil }
                guard let from = dragFrom else { return }
                guard let target = indexAt(point: value.location, cell: cell, cols: cols, rows: rows) else { return }
                let result = store.performDrop(from: from, to: target)
                if case .merged(let kind) = result {
                    burstToken += 1
                    burst = BurstInfo(index: target, color: Palette.accent(kind.chain), token: burstToken)
                }
            }
    }

    private func center(index: Int, cell: CGFloat, cols: Int) -> CGPoint {
        let row = index / cols
        let col = index % cols
        let x = CGFloat(col) * (cell + spacing) + cell / 2
        let y = CGFloat(row) * (cell + spacing) + cell / 2
        return CGPoint(x: x, y: y)
    }

    private func indexAt(point: CGPoint, cell: CGFloat, cols: Int, rows: Int) -> Int? {
        let col = Int(point.x / (cell + spacing))
        let row = Int(point.y / (cell + spacing))
        guard col >= 0, col < cols, row >= 0, row < rows else { return nil }
        let index = row * cols + col
        guard store.state.board.isPlayable(index: index) else { return nil }
        return index
    }
}
