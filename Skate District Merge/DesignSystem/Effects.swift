import SwiftUI

struct GritOverlay: View {
    var density: Int = 120
    var opacity: Double = 0.06

    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 0xC0FFEE)
            for _ in 0..<density {
                let x = rng.double() * size.width
                let y = rng.double() * size.height
                let s = 0.5 + rng.double() * 1.4
                let rect = CGRect(x: x, y: y, width: s, height: s)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
            }
        }
        .allowsHitTesting(false)
        .blendMode(.overlay)
    }
}

struct HalftoneStripes: View {
    var color: Color
    var spacing: CGFloat = 7

    var body: some View {
        Canvas { context, size in
            var x: CGFloat = -size.height
            while x < size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 1)
                x += spacing
            }
        }
        .allowsHitTesting(false)
    }
}

extension View {
    func neonGlow(_ color: Color, radius: CGFloat = 10, opacity: Double = 0.8) -> some View {
        self.shadow(color: color.opacity(opacity), radius: radius)
    }

    func stickerBorder(_ color: Color = Palette.stroke, width: CGFloat = 2, corner: CGFloat = Metrics.radius) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(color, lineWidth: width)
        )
    }
}

struct PressScale: ButtonStyle {
    var scale: CGFloat = 0.92

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(Motion.pop, value: configuration.isPressed)
    }
}

struct BackdropView: View {
    var body: some View {
        ZStack {
            Palette.backdrop
            LinearGradient(
                colors: [Color(hex: "1C1830").opacity(0.7), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            RadialGradient(
                colors: [Palette.pink.opacity(0.10), Color.clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 360
            )
            RadialGradient(
                colors: [Palette.cyan.opacity(0.08), Color.clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 340
            )
            GritOverlay()
        }
        .ignoresSafeArea()
    }
}
