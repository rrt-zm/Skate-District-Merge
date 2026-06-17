import SwiftUI

private struct SkaterLayout: Identifiable {
    let id: Int
    let seed: Int
    let x: Double
    let y: Double
    let skaterSize: Double
    let phase: Double
    let trick: Bool
}

struct DistrictSceneView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        let zones = store.state.district.unlockedZones
        let night = zones.contains(.nightStrip)
        let skaterCount = store.liveSkaterCount

        GeometryReader { geo in
            let size = geo.size
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    Canvas { context, canvasSize in
                        drawScene(context: context, size: canvasSize, t: t, zones: zones, night: night)
                    }
                    skaterLayer(size: size, t: t, count: skaterCount, zones: zones)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous)
                .strokeBorder(Palette.stroke, lineWidth: 1.5)
        )
    }

    private func skaterLayer(size: CGSize, t: Double, count: Int, zones: Set<ZoneID>) -> some View {
        let layouts = skaterLayouts(size: size, t: t, count: count, zones: zones)
        return ZStack {
            ForEach(layouts) { layout in
                SkaterSprite(seed: layout.seed, phase: layout.phase, doingTrick: layout.trick)
                    .frame(width: layout.skaterSize, height: layout.skaterSize)
                    .position(x: layout.x, y: layout.y)
                    .opacity(0.96)
            }
        }
    }

    private func skaterLayouts(size: CGSize, t: Double, count: Int, zones: Set<ZoneID>) -> [SkaterLayout] {
        let ground: Double = Double(size.height) * 0.74
        let skaterSize: Double = max(26, Double(size.height) * 0.2)
        let hasVert = zones.contains(.vertPark)
        var result: [SkaterLayout] = []
        for i in 0..<count {
            let speed: Double = 26.0 + Double((i * 7) % 22)
            let span: Double = Double(size.width) + skaterSize
            let raw: Double = (t * speed + Double(i) * 57).truncatingRemainder(dividingBy: span)
            let x: Double = raw - skaterSize / 2
            let lane: Double = Double((i * 3) % 3)
            let y: Double = ground - lane * (skaterSize * 0.22) - skaterSize * 0.1
            let ratio: Double = raw / span
            let trick: Bool = ratio > 0.4 && ratio < 0.6 && hasVert
            let phase: Double = (t * 1.6 + Double(i)).truncatingRemainder(dividingBy: 1)
            result.append(SkaterLayout(id: i, seed: i * 13 + 1, x: x, y: y, skaterSize: skaterSize, phase: phase, trick: trick))
        }
        return result
    }

    private func drawScene(context: GraphicsContext, size: CGSize, t: Double, zones: Set<ZoneID>, night: Bool) {
        let skyColors: [Color] = night
            ? [Color(hex: "080612"), Color(hex: "151038"), Color(hex: "32195C")]
            : [Color(hex: "241A45"), Color(hex: "543070"), Color(hex: "B5556B"), Color(hex: "E89A5C")]
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(Gradient(colors: skyColors), startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height))
        )

        let moonX = size.width * 0.78
        let moonY = size.height * 0.2
        context.fill(Path(ellipseIn: CGRect(x: moonX, y: moonY, width: 34, height: 34)),
                     with: .color(night ? Color(hex: "F4F0D0") : Color(hex: "FFD9A0").opacity(0.9)))

        var starRng = SeededRandom(seed: 0x5A7E)
        for _ in 0..<40 {
            let sx = starRng.double() * size.width
            let sy = starRng.double() * size.height * 0.55
            let tw = (sin(t * 3 + sx) + 1) / 2
            context.fill(Path(ellipseIn: CGRect(x: sx, y: sy, width: 1.6, height: 1.6)),
                         with: .color(.white.opacity((night ? 0.5 : 0.25) * (0.4 + 0.6 * tw))))
        }

        let cloudColor = (night ? Color(hex: "201A3C") : Color(hex: "6A4070")).opacity(0.5)
        for i in 0..<3 {
            let cw = size.width * 0.4
            let cx = ((t * (8 + Double(i) * 4) + Double(i) * 220).truncatingRemainder(dividingBy: size.width + cw)) - cw
            let cy = size.height * (0.16 + Double(i) * 0.07)
            context.fill(Path(roundedRect: CGRect(x: cx, y: cy, width: cw, height: 16), cornerRadius: 8), with: .color(cloudColor))
        }

        drawSkyline(context: context, size: size, night: night)
        drawGround(context: context, size: size, night: night)
        drawStructures(context: context, size: size, t: t, zones: zones, night: night)
    }

    private func drawSkyline(context: GraphicsContext, size: CGSize, night: Bool) {
        let baseY = size.height * 0.74
        let back = night ? Color(hex: "100D24") : Color(hex: "2C1E44")
        var x: CGFloat = 0
        var rng = SeededRandom(seed: 0xB17D5)
        while x < size.width {
            let w = 26 + CGFloat(rng.double()) * 30
            let h = 40 + CGFloat(rng.double()) * size.height * 0.3
            let rect = CGRect(x: x, y: baseY - h, width: w, height: h)
            context.fill(Path(rect), with: .color(back))
            var wy = rect.minY + 6
            while wy < baseY - 6 {
                var wx = rect.minX + 4
                while wx < rect.maxX - 4 {
                    if rng.chance(0.5) {
                        context.fill(Path(CGRect(x: wx, y: wy, width: 3, height: 3)),
                                     with: .color(Color(hex: "FFD23F").opacity(night ? 0.7 : 0.35)))
                    }
                    wx += 8
                }
                wy += 9
            }
            x += w + 3
        }
    }

    private func drawGround(context: GraphicsContext, size: CGSize, night: Bool) {
        let groundY = size.height * 0.74
        context.fill(Path(CGRect(x: 0, y: groundY, width: size.width, height: size.height - groundY)),
                     with: .color(Color(hex: night ? "16161F" : "1F1B28")))
        var lx: CGFloat = 0
        while lx < size.width {
            context.fill(Path(CGRect(x: lx, y: groundY, width: size.width * 0.06, height: 2)),
                         with: .color(.white.opacity(0.08)))
            lx += size.width * 0.14
        }
    }

    private func drawStructures(context: GraphicsContext, size: CGSize, t: Double, zones: Set<ZoneID>, night: Bool) {
        let groundY = size.height * 0.74

        if zones.contains(.streetPlaza) {
            context.fill(Path(roundedRect: CGRect(x: size.width * 0.06, y: groundY - 14, width: 54, height: 14), cornerRadius: 3),
                         with: .color(Color(hex: "3A3A4D")))
        }
        if zones.contains(.graffitiAlley) {
            let wall = CGRect(x: size.width * 0.0, y: groundY - 60, width: 46, height: 60)
            context.fill(Path(wall), with: .color(Color(hex: "2A2438")))
            context.fill(Path(ellipseIn: CGRect(x: wall.minX + 6, y: wall.minY + 12, width: 18, height: 18)), with: .color(Palette.pink.opacity(0.85)))
            context.fill(Path(CGRect(x: wall.minX + 20, y: wall.minY + 30, width: 22, height: 8)), with: .color(Palette.cyan.opacity(0.85)))
        }
        if zones.contains(.bowl) {
            let bowl = CGRect(x: size.width * 0.34, y: groundY - 10, width: 90, height: 26)
            context.stroke(Path(ellipseIn: bowl), with: .color(Color(hex: "44445C")), lineWidth: 5)
        }
        if zones.contains(.shopRow) {
            let shop = CGRect(x: size.width * 0.62, y: groundY - 46, width: 60, height: 46)
            context.fill(Path(shop), with: .color(Color(hex: "33293F")))
            for i in 0..<5 {
                let stripe = CGRect(x: shop.minX + CGFloat(i) * 12, y: shop.minY, width: 6, height: 10)
                context.fill(Path(stripe), with: .color(i % 2 == 0 ? Palette.orange : .white))
            }
        }
        if zones.contains(.vertPark) {
            var ramp = Path()
            let baseX = size.width * 0.2
            ramp.move(to: CGPoint(x: baseX, y: groundY))
            ramp.addQuadCurve(to: CGPoint(x: baseX + 60, y: groundY - 56), control: CGPoint(x: baseX + 60, y: groundY))
            ramp.addLine(to: CGPoint(x: baseX + 60, y: groundY))
            ramp.closeSubpath()
            context.fill(ramp, with: .color(Color(hex: "3C3450")))
        }
        if zones.contains(.nightStrip) {
            let flicker = (sin(t * 9) > -0.6) ? 1.0 : 0.4
            let signRect = CGRect(x: size.width * 0.5, y: groundY - 96, width: 70, height: 26)
            context.fill(Path(roundedRect: signRect, cornerRadius: 5), with: .color(Palette.violet.opacity(0.25 * flicker)))
            context.stroke(Path(roundedRect: signRect, cornerRadius: 5), with: .color(Palette.violet.opacity(flicker)), lineWidth: 2)
            context.draw(Text("SK8").font(Typeface.display(16)).foregroundColor(Palette.cyan.opacity(flicker)),
                         at: CGPoint(x: signRect.midX, y: signRect.midY))
        }
    }
}
