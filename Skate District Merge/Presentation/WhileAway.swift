import SwiftUI

struct WhileAwayView: View {
    let summary: AwaySummary
    var onCollect: () -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            Palette.ink.opacity(0.78).ignoresSafeArea()
            VStack(spacing: 18) {
                Text("WHILE YOU WERE AWAY")
                    .font(Typeface.display(20))
                    .foregroundStyle(Palette.cyan)
                    .tracking(1.5)
                    .multilineTextAlignment(.center)

                Text(timeAway)
                    .font(Typeface.medium(14))
                    .foregroundStyle(Palette.textSecondary)

                VStack(spacing: 10) {
                    ForEach(orderedGenerators, id: \.self) { id in
                        let amount = summary.energyByGenerator[id] ?? 0
                        HStack(spacing: 12) {
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(Palette.accent(GameContent.generator(id).chain))
                            Text(GameContent.generator(id).title)
                                .font(Typeface.bold(14))
                                .foregroundStyle(Palette.textPrimary)
                            Spacer()
                            Text("+\(amount)")
                                .font(Typeface.numeric(16))
                                .foregroundStyle(Palette.lime)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(Palette.yellow)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Palette.asphalt))
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill").foregroundStyle(Palette.yellow)
                    Text("Generators recharged \(summary.totalEnergy) energy")
                        .font(Typeface.bold(13))
                        .foregroundStyle(Palette.textSecondary)
                }

                StreetButton(title: "Let's Skate", symbol: "play.fill", tint: Palette.cyan, action: onCollect)
                    .frame(maxWidth: 260)
            }
            .padding(24)
            .panel(corner: Metrics.radiusLarge)
            .padding(28)
            .scaleEffect(appear ? 1 : 0.7)
            .opacity(appear ? 1 : 0)
        }
        .onAppear { withAnimation(Motion.bouncy) { appear = true } }
    }

    private var orderedGenerators: [GeneratorID] {
        GameContent.generators.map { $0.id }.filter { summary.energyByGenerator[$0] != nil }
    }

    private var timeAway: String {
        let total = Int(summary.seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "You were gone \(hours)h \(minutes)m" }
        if minutes > 0 { return "You were gone \(minutes)m" }
        return "You just stepped out"
    }
}
