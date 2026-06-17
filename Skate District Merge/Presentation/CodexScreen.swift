import SwiftUI

struct CodexScreen: View {
    @Environment(GameStore.self) private var store

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                SectionHeader(title: "Collection", symbol: "books.vertical.fill", accent: Palette.lime)

                ForEach(GameContent.chains, id: \.id) { chain in
                    chainSection(chain)
                }
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
    }

    private func chainSection(_ chain: ChainDefinition) -> some View {
        let accent = Color(hex: chain.accentHex)
        let discoveredCount = (1...chain.maxTier).filter { store.state.discovered.contains(ItemKind(chain: chain.id, tier: $0).id) }.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: chain.symbol).font(.system(size: 15, weight: .black)).foregroundStyle(accent)
                Text(chain.title).font(Typeface.heavy(16)).foregroundStyle(Palette.textPrimary)
                Spacer()
                Text("\(discoveredCount)/\(chain.maxTier)")
                    .font(Typeface.numeric(13))
                    .foregroundStyle(discoveredCount == chain.maxTier ? Palette.lime : Palette.textSecondary)
            }
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...chain.maxTier, id: \.self) { tier in
                    codexCell(chain: chain, tier: tier, accent: accent)
                }
            }
        }
        .padding(14)
        .panel()
    }

    private func codexCell(chain: ChainDefinition, tier: Int, accent: Color) -> some View {
        let kind = ItemKind(chain: chain.id, tier: tier)
        let discovered = store.state.discovered.contains(kind.id)
        return VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(discovered ? AnyShapeStyle(Palette.tileGradient(chain.id)) : AnyShapeStyle(Palette.asphalt))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(discovered ? accent.opacity(0.5) : Palette.strokeSoft, lineWidth: 1.5))
                if discovered {
                    ItemSprite(kind: kind).padding(6)
                } else {
                    Image(systemName: "questionmark")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Palette.textDim)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            Text(discovered ? chain.name(tier: tier) : "Tier \(tier)")
                .font(Typeface.medium(9))
                .foregroundStyle(discovered ? Palette.textSecondary : Palette.textDim)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
