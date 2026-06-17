import SwiftUI

enum Typeface {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func heavy(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func bold(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func medium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func numeric(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }

    static func label(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

extension Text {
    func displayStyle(_ size: CGFloat, color: Color = Palette.textPrimary) -> some View {
        self.font(Typeface.display(size))
            .foregroundStyle(color)
            .tracking(0.5)
    }
}

enum Metrics {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28

    static let radiusSmall: CGFloat = 10
    static let radius: CGFloat = 16
    static let radiusLarge: CGFloat = 24

    static let tileCorner: CGFloat = 12
}

enum Motion {
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.68)
    static let bouncy = Animation.spring(response: 0.42, dampingFraction: 0.55)
    static let smooth = Animation.easeInOut(duration: 0.32)
    static let pop = Animation.spring(response: 0.26, dampingFraction: 0.5)
}
