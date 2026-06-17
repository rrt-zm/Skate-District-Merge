import SwiftUI

enum PixelArt {
    static let bitmaps: [ChainID: [String]] = [
        .boards: [
            "..............",
            "..............",
            "..............",
            "..............",
            "..............",
            ".kkkkkkkkkkkk.",
            ".khhmmmmmmhhk.",
            ".kmmmmmmmmmmk.",
            ".kkkkkkkkkkkk.",
            "...k......k...",
            "..ksk....ksk..",
            "..ksk....ksk..",
            "...k......k...",
            ".............."
        ],
        .ramps: [
            "..............",
            "..............",
            "............s.",
            "...........kk.",
            "..........kmm.",
            ".........kmmh.",
            "........kmmmh.",
            ".......kmmmmh.",
            "......kmmmmmh.",
            ".....kmmmmmmh.",
            "....kmmmmmmmh.",
            "...kkkkkkkkkk.",
            "..............",
            ".............."
        ],
        .graffiti: [
            "..............",
            ".....ss.......",
            "....s..s......",
            "....k..k......",
            "...kkkk.......",
            "...khhk.......",
            "...kmmk..ss...",
            "...kmmk.s..s..",
            "...kmmk.smms..",
            "...kmmk..ss...",
            "...kmmk.......",
            "...kkkk.......",
            "..............",
            ".............."
        ],
        .lighting: [
            "..............",
            ".....kkkk.....",
            "....khhhhk....",
            "...khhmmhhk...",
            "...khmmmmhk...",
            "...khmmmmhk...",
            "...khhmmhhk...",
            "....khmmhk....",
            ".....kmmk.....",
            ".....kssk.....",
            ".....kssk.....",
            "......kk......",
            "..............",
            ".............."
        ],
        .shops: [
            "..............",
            "..............",
            "..kkkkkkkkkk..",
            "..ksmsmsmsmk..",
            "..kmsmsmsmsk..",
            "..kkkkkkkkkk..",
            "..kmhhmmhhmk..",
            "..kmhhmmhhmk..",
            "..kmmmkkmmmk..",
            "..kmmmksmmmk..",
            "..kmmmkkmmmk..",
            "..kkkkkkkkkk..",
            "..............",
            ".............."
        ]
    ]
}

struct ItemSprite: View {
    let kind: ItemKind
    var animated: Bool = false

    var body: some View {
        let accent = Palette.accent(kind.chain)
        let grid = PixelArt.bitmaps[kind.chain] ?? []
        let main = accent
        let light = accent.blended(with: .white, amount: 0.55)
        let dark = accent.blended(with: .black, amount: 0.62)
        let glowStrength = Double(kind.tier) / Double(max(2, GameContent.maxTier(kind.chain)))

        Canvas { context, size in
            let rows = grid.count
            let cols = grid.first?.count ?? 14
            let cell = min(size.width / CGFloat(cols), size.height / CGFloat(rows))
            let originX = (size.width - cell * CGFloat(cols)) / 2
            let originY = (size.height - cell * CGFloat(rows)) / 2
            for (r, line) in grid.enumerated() {
                for (c, char) in line.enumerated() {
                    let color: Color
                    switch char {
                    case "m": color = main
                    case "h": color = light
                    case "k": color = dark
                    case "s": color = .white
                    default: continue
                    }
                    let rect = CGRect(x: originX + CGFloat(c) * cell,
                                      y: originY + CGFloat(r) * cell,
                                      width: cell + 0.5,
                                      height: cell + 0.5)
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .shadow(color: accent.opacity(0.25 + 0.5 * glowStrength), radius: 2 + 6 * glowStrength)
        .overlay(alignment: .topTrailing) {
            if kind.tier >= 6 {
                Image(systemName: "sparkle")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.white)
                    .padding(2)
            }
        }
    }
}

struct SkaterSprite: View {
    var seed: Int
    var phase: Double
    var doingTrick: Bool

    var body: some View {
        let palette: [Color] = [Palette.pink, Palette.cyan, Palette.yellow, Palette.violet, Palette.lime, Palette.orange]
        let shirt = palette[abs(seed) % palette.count]
        let pants = palette[(abs(seed) / 3 + 2) % palette.count]
        let skin = Color(hex: ["F2C9A0", "C68642", "8D5524", "FFE0BD"][abs(seed) % 4])
        let bob = sin(phase * .pi * 2) * 0.5
        let armSwing = sin(phase * .pi * 2)

        Canvas { context, size in
            let cell = size.width / 12
            func block(_ col: CGFloat, _ row: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: Color) {
                let rect = CGRect(x: col * cell, y: (row + CGFloat(bob)) * cell, width: w * cell + 0.5, height: h * cell + 0.5)
                context.fill(Path(rect), with: .color(color))
            }
            block(4, 1, 3, 3, skin)
            block(4, 4, 4, 4, shirt)
            block(3, 4 + CGFloat(armSwing), 1, 3, skin)
            block(8, 4 - CGFloat(armSwing), 1, 3, skin)
            if doingTrick {
                block(4, 8, 2, 3, pants)
                block(7, 8, 2, 3, pants)
            } else {
                block(4, 8, 2, 2, pants)
                block(6, 8, 2, 2, pants)
            }
            let deckY: CGFloat = doingTrick ? 9.4 : 10.5
            block(2, deckY, 8, 0.8, .black.opacity(0.9))
            block(3, deckY + 0.8, 1, 1, Palette.textSecondary)
            block(8, deckY + 0.8, 1, 1, Palette.textSecondary)
        }
    }
}

struct ChainGlyph: View {
    let chain: ChainID
    var size: CGFloat = 22

    var body: some View {
        Image(systemName: GameContent.chain(chain).symbol)
            .font(.system(size: size, weight: .black))
            .foregroundStyle(Palette.accent(chain))
    }
}
