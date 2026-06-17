import SwiftUI

struct AchievementsScreen: View {
    @Environment(GameStore.self) private var store

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                let unlocked = AchievementEngine.unlockedCount(progress: store.state.achievementProgress)
                HStack {
                    Text("\(unlocked) of \(GameContent.achievements.count) unlocked")
                        .font(Typeface.bold(14))
                        .foregroundStyle(Palette.textSecondary)
                    Spacer()
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(GameContent.achievements) { def in
                        AchievementCard(def: def)
                    }
                }
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
    }
}

struct AchievementCard: View {
    @Environment(GameStore.self) private var store
    let def: AchievementDef

    var body: some View {
        let progress = AchievementEngine.progressValue(def, progress: store.state.achievementProgress)
        let complete = AchievementEngine.isComplete(def, progress: store.state.achievementProgress)
        let fraction = Double(progress) / Double(max(1, def.goal.target))

        VStack(spacing: 9) {
            ZStack {
                Circle().fill((complete ? Palette.yellow : Palette.textDim).opacity(0.15)).frame(width: 60, height: 60)
                Image(systemName: def.symbol)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(complete ? Palette.yellow : Palette.textDim)
                if !complete {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Palette.textDim)
                        .offset(x: 20, y: 20)
                }
            }
            .neonGlow(complete ? Palette.yellow : .clear, radius: 10, opacity: 0.6)

            Text(def.title)
                .font(Typeface.heavy(14))
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(def.detail)
                .font(Typeface.medium(11))
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)

            if complete {
                Text("UNLOCKED")
                    .font(Typeface.heavy(11))
                    .foregroundStyle(Palette.yellow)
                    .tracking(1)
            } else {
                VStack(spacing: 3) {
                    ProgressBarView(value: fraction, tint: Palette.cyan, height: 7)
                    Text("\(progress)/\(def.goal.target)")
                        .font(Typeface.numeric(10))
                        .foregroundStyle(Palette.textDim)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .panel(stroke: complete ? Palette.yellow.opacity(0.5) : Palette.stroke)
    }
}
