import SwiftUI

struct SkaterAvatar: View {
    var seed: Int
    var size: CGFloat = 50

    var body: some View {
        let palette: [Color] = [Palette.pink, Palette.cyan, Palette.yellow, Palette.violet, Palette.lime, Palette.orange]
        let beanie = palette[abs(seed) % palette.count]
        let skin = Color(hex: ["F2C9A0", "C68642", "8D5524", "FFE0BD"][abs(seed / 5) % 4])

        Canvas { context, canvasSize in
            let cell = canvasSize.width / 10
            func block(_ c: Int, _ r: Int, _ w: Int, _ h: Int, _ color: Color) {
                let rect = CGRect(x: CGFloat(c) * cell, y: CGFloat(r) * cell, width: CGFloat(w) * cell + 0.5, height: CGFloat(h) * cell + 0.5)
                context.fill(Path(rect), with: .color(color))
            }
            block(2, 2, 6, 2, beanie)
            block(2, 4, 6, 4, skin)
            block(3, 5, 1, 1, .black)
            block(6, 5, 1, 1, .black)
            block(3, 7, 4, 1, beanie.blended(with: .black, amount: 0.2))
            block(2, 8, 6, 2, beanie)
        }
        .frame(width: size, height: size)
        .background(
            Circle().fill(Palette.asphalt)
                .overlay(Circle().strokeBorder(beanie.opacity(0.6), lineWidth: 2))
        )
        .clipShape(Circle())
    }
}

struct ItemTileView: View {
    var item: BoardItem
    var dimmed: Bool = false
    var showBadge: Bool = true

    var body: some View {
        let accent = Palette.accent(item.kind.chain)
        ZStack {
            RoundedRectangle(cornerRadius: Metrics.tileCorner, style: .continuous)
                .fill(Palette.tileGradient(item.kind.chain))
                .overlay(
                    RoundedRectangle(cornerRadius: Metrics.tileCorner, style: .continuous)
                        .strokeBorder(accent.opacity(0.55), lineWidth: 1.5)
                )
            ItemSprite(kind: item.kind)
                .padding(7)
            if showBadge {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TierBadge(tier: item.kind.tier, tint: accent)
                            .padding(4)
                    }
                }
            }
            if MergeEngine.isMaxed(item.kind) {
                VStack {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Palette.yellow)
                            .padding(4)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .opacity(dimmed ? 0.3 : 1)
    }
}

struct EmptyCellView: View {
    var playable: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: Metrics.tileCorner, style: .continuous)
            .fill(playable ? Palette.asphalt.opacity(0.6) : Palette.ink.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.tileCorner, style: .continuous)
                    .strokeBorder(Palette.strokeSoft, style: StrokeStyle(lineWidth: 1, dash: playable ? [] : [4, 4]))
            )
            .overlay(
                Group {
                    if !playable {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Palette.textDim)
                    }
                }
            )
    }
}

struct RequirementChip: View {
    var requirement: Requirement
    var have: Int

    var body: some View {
        let satisfied = have >= requirement.count
        let accent = Palette.accent(requirement.kind.chain)
        VStack(spacing: 4) {
            ItemSprite(kind: requirement.kind)
                .frame(width: 38, height: 38)
            Text("\(min(have, requirement.count))/\(requirement.count)")
                .font(Typeface.numeric(12))
                .foregroundStyle(satisfied ? Palette.success : Palette.textSecondary)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.asphalt)
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(satisfied ? Palette.success.opacity(0.6) : accent.opacity(0.3), lineWidth: 1.5))
        )
    }
}
