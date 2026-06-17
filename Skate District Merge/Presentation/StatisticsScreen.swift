import SwiftUI

struct StatisticsScreen: View {
    @Environment(GameStore.self) private var store

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        let stats = store.state.statistics
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                LazyVGrid(columns: columns, spacing: 12) {
                    StatPill(label: "Merges", value: EconomyService.format(stats.merges), tint: Palette.cyan, symbol: "arrow.triangle.merge")
                    StatPill(label: "Items Made", value: EconomyService.format(stats.itemsCreated), tint: Palette.yellow, symbol: "shippingbox.fill")
                    StatPill(label: "Orders Filled", value: EconomyService.format(stats.requestsFilled), tint: Palette.lime, symbol: "checkmark.seal.fill")
                    StatPill(label: "Skaters", value: EconomyService.format(stats.skatersAttracted), tint: Palette.pink, symbol: "figure.skating")
                    StatPill(label: "Tricks Landed", value: EconomyService.format(stats.tricksLanded), tint: Palette.orange, symbol: "flame.fill")
                    StatPill(label: "Structures", value: EconomyService.format(stats.structuresBuilt), tint: Palette.violet, symbol: "building.2.fill")
                    StatPill(label: "Coins Earned", value: EconomyService.format(stats.coinsEarned), tint: Palette.yellow, symbol: "dollarsign.circle.fill")
                    StatPill(label: "Gen Taps", value: EconomyService.format(stats.generatorTaps), tint: Palette.cyan, symbol: "hand.tap.fill")
                    StatPill(label: "Zones", value: "\(store.state.district.unlockedZones.count)/\(GameContent.zones.count)", tint: Palette.pink, symbol: "map.fill")
                    StatPill(label: "Played", value: timePlayed(stats.secondsPlayed), tint: Palette.lime, symbol: "clock.fill")
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Merges by Chain", symbol: "chart.bar.fill", accent: Palette.cyan)
                    ChainBarChart()
                }
                .padding(14)
                .panel()
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
    }

    private func timePlayed(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

struct ChainBarChart: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        let counts = GameContent.chains.map { ($0, store.state.statistics.mergesByChain[$0.id.rawValue] ?? 0) }
        let maxCount = max(1, counts.map { $0.1 }.max() ?? 1)
        VStack(spacing: 10) {
            ForEach(GameContent.chains, id: \.id) { chain in
                let count = store.state.statistics.mergesByChain[chain.id.rawValue] ?? 0
                let accent = Color(hex: chain.accentHex)
                HStack(spacing: 10) {
                    Image(systemName: chain.symbol)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 22)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Palette.asphalt)
                            Capsule()
                                .fill(accent)
                                .frame(width: max(6, geo.size.width * CGFloat(count) / CGFloat(maxCount)))
                        }
                    }
                    .frame(height: 14)
                    Text("\(count)")
                        .font(Typeface.numeric(13))
                        .foregroundStyle(Palette.textPrimary)
                        .frame(width: 44, alignment: .trailing)
                }
            }
        }
    }
}
