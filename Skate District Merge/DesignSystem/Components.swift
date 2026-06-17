import SwiftUI

struct RollingNumber: View {
    var value: Int
    var font: Font = Typeface.numeric(16)
    var color: Color = Palette.textPrimary

    var body: some View {
        Text(EconomyService.format(value))
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText(value: Double(value)))
            .animation(Motion.snappy, value: value)
    }
}

struct CurrencyChip: View {
    var symbol: String
    var value: Int
    var tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(tint)
            RollingNumber(value: value, font: Typeface.numeric(15), color: Palette.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(Palette.concrete)
                .overlay(Capsule().strokeBorder(tint.opacity(0.4), lineWidth: 1.5))
        )
        .neonGlow(tint, radius: 6, opacity: 0.35)
    }
}

struct PanelBackground: ViewModifier {
    var corner: CGFloat = Metrics.radius
    var stroke: Color = Palette.stroke

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Palette.panelGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(stroke, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
    }
}

extension View {
    func panel(corner: CGFloat = Metrics.radius, stroke: Color = Palette.stroke) -> some View {
        modifier(PanelBackground(corner: corner, stroke: stroke))
    }
}

struct StreetButton: View {
    var title: String
    var symbol: String?
    var tint: Color
    var filled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .black))
                }
                Text(title)
                    .font(Typeface.heavy(16))
            }
            .foregroundStyle(filled ? Palette.ink : tint)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous)
                    .fill(filled ? AnyShapeStyle(tint) : AnyShapeStyle(Palette.concrete))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous)
                    .strokeBorder(tint.opacity(filled ? 0.0 : 0.7), lineWidth: 2)
            )
            .neonGlow(filled ? tint : .clear, radius: 8, opacity: 0.5)
        }
        .buttonStyle(PressScale())
    }
}

struct IconBadgeButton: View {
    var symbol: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Palette.textPrimary)
                .frame(width: 42, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Palette.concrete)
                        .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(tint.opacity(0.45), lineWidth: 1.5))
                )
        }
        .buttonStyle(PressScale())
    }
}

struct SectionHeader: View {
    var title: String
    var symbol: String
    var accent: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(accent)
            Text(title.uppercased())
                .font(Typeface.heavy(15))
                .foregroundStyle(Palette.textPrimary)
                .tracking(1.2)
            Spacer(minLength: 0)
        }
    }
}

struct TierBadge: View {
    var tier: Int
    var tint: Color

    var body: some View {
        Text("T\(tier)")
            .font(Typeface.numeric(10))
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Capsule().fill(tint))
    }
}

struct CooldownRing: View {
    var progress: Double
    var tint: Color
    var lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            Circle()
                .stroke(Palette.strokeSoft, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct ProgressBarView: View {
    var value: Double
    var tint: Color
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.asphalt)
                Capsule()
                    .fill(LinearGradient(colors: [tint, tint.blended(with: .white, amount: 0.3)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, value)) * geo.size.width)
                    .neonGlow(tint, radius: 5, opacity: 0.6)
            }
        }
        .frame(height: height)
    }
}

struct StatPill: View {
    var label: String
    var value: String
    var tint: Color
    var symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(tint)
                Text(label.uppercased())
                    .font(Typeface.label(10))
                    .foregroundStyle(Palette.textDim)
                    .tracking(0.8)
            }
            Text(value)
                .font(Typeface.numeric(20))
                .foregroundStyle(Palette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .panel()
    }
}

struct EmptyStateView: View {
    var symbol: String
    var title: String
    var message: String
    var tint: Color = Palette.cyan

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 92, height: 92)
                Image(systemName: symbol)
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(Typeface.heavy(19))
                .foregroundStyle(Palette.textPrimary)
            Text(message)
                .font(Typeface.medium(14))
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

struct PixelLoader: View {
    @State private var phase = 0.0

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let count = 8
                let radius = size.width * 0.34
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for i in 0..<count {
                    let angle = Double(i) / Double(count) * 2 * .pi + t * 2.4
                    let fade = (sin(t * 4 - Double(i) * 0.7) + 1) / 2
                    let x = center.x + cos(angle) * radius
                    let y = center.y + sin(angle) * radius
                    let s = size.width * 0.12
                    let rect = CGRect(x: x - s / 2, y: y - s / 2, width: s, height: s)
                    let colors: [Color] = [Palette.pink, Palette.cyan, Palette.yellow]
                    context.fill(Path(rect), with: .color(colors[i % 3].opacity(0.4 + 0.6 * fade)))
                }
            }
        }
        .frame(width: 64, height: 64)
    }
}
