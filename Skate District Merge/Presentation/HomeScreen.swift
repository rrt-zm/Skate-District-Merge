import SwiftUI

struct HomeScreen: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                DistrictSceneView()
                    .frame(height: 150)
                    .overlay(alignment: .topLeading) {
                        sceneTag
                            .padding(10)
                    }

                RequestRail()

                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Palette.cyan)
                        Text("MERGE BOARD")
                            .font(Typeface.heavy(13))
                            .foregroundStyle(Palette.textPrimary)
                            .tracking(1)
                        Spacer()
                        Text("\(store.state.board.occupiedCount)/\(store.state.board.capacity)")
                            .font(Typeface.numeric(12))
                            .foregroundStyle(Palette.textDim)
                    }
                    MergeBoardView()
                }
                .padding(12)
                .panel()

                GeneratorDock()
                    .padding(12)
                    .panel()
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 8)
            .padding(.bottom, 110)
        }
    }

    private var sceneTag: some View {
        HStack(spacing: 6) {
            Image(systemName: "figure.skating")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Palette.cyan)
            Text("\(store.liveSkaterCount) skating")
                .font(Typeface.numeric(11))
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(Palette.ink.opacity(0.7)))
    }
}
