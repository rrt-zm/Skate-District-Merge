import SwiftUI

struct SprayBurst: View {
    var color: Color
    var count: Int = 12
    @State private var expanded = false

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) / Double(count) * 2 * .pi
                Circle()
                    .fill(color)
                    .frame(width: expanded ? 3 : 7, height: expanded ? 3 : 7)
                    .offset(x: expanded ? cos(angle) * 38 : 0,
                            y: expanded ? sin(angle) * 38 : 0)
                    .opacity(expanded ? 0 : 1)
            }
            Circle()
                .stroke(color, lineWidth: expanded ? 0 : 3)
                .frame(width: expanded ? 70 : 6, height: expanded ? 70 : 6)
                .opacity(expanded ? 0 : 1)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { expanded = true }
        }
    }
}

struct FloatingReward: View {
    var text: String
    var color: Color
    @State private var rise = false

    var body: some View {
        Text(text)
            .font(Typeface.heavy(18))
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
            .offset(y: rise ? -54 : 0)
            .opacity(rise ? 0 : 1)
            .scaleEffect(rise ? 1.15 : 0.7)
            .onAppear {
                withAnimation(.easeOut(duration: 0.95)) { rise = true }
            }
    }
}

private struct ConfettiParticle {
    var x: Double
    var vx: Double
    var vy: Double
    var rotation: Double
    var spin: Double
    var color: Color
    var size: Double
}

struct ConfettiOverlay: View {
    var token: Int
    @State private var startDate = Date()
    @State private var active = false
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        TimelineView(.animation(paused: !active)) { timeline in
            Canvas { context, size in
                guard active else { return }
                let elapsed = timeline.date.timeIntervalSince(startDate)
                for particle in particles {
                    let px = particle.x * size.width + particle.vx * elapsed * 60
                    let py = -40 + particle.vy * elapsed * 60 + 120 * elapsed * elapsed
                    if py > size.height + 40 { continue }
                    let rect = CGRect(x: px, y: py, width: particle.size, height: particle.size * 1.6)
                    var ctx = context
                    ctx.translateBy(x: px, y: py)
                    ctx.rotate(by: .radians(particle.rotation + particle.spin * elapsed))
                    ctx.translateBy(x: -px, y: -py)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onChange(of: token) { _, _ in trigger() }
    }

    private func trigger() {
        var rng = SeededRandom(seed: UInt64(token) &* 2654435761 &+ 1)
        let palette: [Color] = [Palette.pink, Palette.cyan, Palette.yellow, Palette.violet, Palette.lime, Palette.orange]
        particles = (0..<70).map { _ in
            ConfettiParticle(
                x: rng.double(),
                vx: (rng.double() - 0.5) * 4,
                vy: rng.double() * 2 + 1,
                rotation: rng.double() * 6.28,
                spin: (rng.double() - 0.5) * 8,
                color: palette[rng.int(0...(palette.count - 1))],
                size: 5 + rng.double() * 5
            )
        }
        startDate = Date()
        active = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            active = false
        }
    }
}

struct ToastStack: View {
    var toasts: [ToastMessage]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(toasts) { toast in
                HStack(spacing: 9) {
                    Image(systemName: toast.symbol)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color(hex: toast.tintHex))
                    Text(toast.text)
                        .font(Typeface.bold(14))
                        .foregroundStyle(Palette.textPrimary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Palette.concrete)
                        .overlay(Capsule().strokeBorder(Color(hex: toast.tintHex).opacity(0.5), lineWidth: 1.5))
                )
                .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(Motion.snappy, value: toasts)
    }
}
