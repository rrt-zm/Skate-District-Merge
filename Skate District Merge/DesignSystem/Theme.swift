import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b, a: Double
        if cleaned.count == 8 {
            r = Double((value & 0xFF000000) >> 24) / 255
            g = Double((value & 0x00FF0000) >> 16) / 255
            b = Double((value & 0x0000FF00) >> 8) / 255
            a = Double(value & 0x000000FF) / 255
        } else {
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func blended(with other: Color, amount: Double) -> Color {
        let t = max(0, min(1, amount))
        let a = UIColor(self)
        let b = UIColor(other)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        return Color(
            .sRGB,
            red: Double(ar) * (1 - t) + Double(br) * t,
            green: Double(ag) * (1 - t) + Double(bg) * t,
            blue: Double(ab) * (1 - t) + Double(bb) * t,
            opacity: Double(aa) * (1 - t) + Double(ba) * t
        )
    }
}

enum Palette {
    static let ink = Color(hex: "0C0C12")
    static let backdrop = Color(hex: "14141D")
    static let asphalt = Color(hex: "1A1A24")
    static let concrete = Color(hex: "23232F")
    static let concreteLight = Color(hex: "2E2E3D")
    static let surface = Color(hex: "282836")
    static let stroke = Color(hex: "3B3B50")
    static let strokeSoft = Color(hex: "30303F")

    static let textPrimary = Color(hex: "F5F3FF")
    static let textSecondary = Color(hex: "ACA8CC")
    static let textDim = Color(hex: "6E6A8A")

    static let pink = Color(hex: "FF2E97")
    static let cyan = Color(hex: "20E0D6")
    static let yellow = Color(hex: "FFD23F")
    static let violet = Color(hex: "B14EFF")
    static let lime = Color(hex: "9BE564")
    static let orange = Color(hex: "FF7A3C")

    static let danger = Color(hex: "FF4D6D")
    static let success = Color(hex: "38E08B")

    static func accent(_ chain: ChainID) -> Color {
        Color(hex: GameContent.chain(chain).accentHex)
    }

    static let skyDusk = LinearGradient(
        colors: [Color(hex: "20183F"), Color(hex: "3A2160"), Color(hex: "7A3B6E"), Color(hex: "E0664F")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let skyNight = LinearGradient(
        colors: [Color(hex: "080612"), Color(hex: "141034"), Color(hex: "2A1A52")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let panelGradient = LinearGradient(
        colors: [Color(hex: "2B2B3B"), Color(hex: "20202C")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let neonGlow = RadialGradient(
        colors: [Color(hex: "FF2E97").opacity(0.55), Color(hex: "FF2E97").opacity(0)],
        center: .center,
        startRadius: 2,
        endRadius: 90
    )

    static func tileGradient(_ chain: ChainID) -> LinearGradient {
        let base = accent(chain)
        return LinearGradient(
            colors: [base.opacity(0.32), base.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
