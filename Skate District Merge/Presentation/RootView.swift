import SwiftUI

struct RootView: View {
    @Environment(GameStore.self) private var store
    @State private var booting = true

    var body: some View {
        ZStack {
            BackdropView()

            if booting {
                BootView()
                    .transition(.opacity)
            } else if !store.state.settings.onboardingComplete {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainShell()
                    .transition(.opacity)
            }

            VStack {
                ToastStack(toasts: store.toasts)
                    .padding(.top, 58)
                Spacer()
            }
            .allowsHitTesting(false)

            ConfettiOverlay(token: store.celebrationToken)

            if let level = store.levelUpBanner {
                LevelUpBanner(level: level) {
                    withAnimation(Motion.snappy) { store.levelUpBanner = nil }
                }
                .zIndex(10)
            }

            if let achievement = store.achievementQueue.first {
                AchievementPopup(def: achievement) {
                    store.dequeueAchievement()
                }
                .zIndex(11)
            }

            if let summary = store.awaySummary {
                WhileAwayView(summary: summary) {
                    store.dismissAway()
                }
                .zIndex(12)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_100_000_000)
            withAnimation(Motion.smooth) { booting = false }
        }
    }
}

struct BootView: View {
    @State private var glow = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Palette.concrete)
                    .frame(width: 120, height: 120)
                    .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Palette.pink.opacity(0.5), lineWidth: 2))
                    .neonGlow(Palette.pink, radius: glow ? 26 : 10, opacity: 0.7)
                ItemSprite(kind: ItemKind(chain: .ramps, tier: 6))
                    .frame(width: 90, height: 90)
            }
            VStack(spacing: 4) {
                Text("SKATE DISTRICT")
                    .font(Typeface.display(30))
                    .foregroundStyle(Palette.textPrimary)
                Text("MERGE")
                    .font(Typeface.display(30))
                    .foregroundStyle(Palette.pink)
                    .tracking(6)
            }
            Spacer()
            PixelLoader()
            Text("Loading the lot…")
                .font(Typeface.medium(13))
                .foregroundStyle(Palette.textDim)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { glow = true }
        }
    }
}

struct LevelUpBanner: View {
    let level: Int
    var onDismiss: () -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            VStack(spacing: 16) {
                Text("LEVEL UP")
                    .font(Typeface.display(34))
                    .foregroundStyle(Palette.yellow)
                    .tracking(3)
                ZStack {
                    Circle().fill(Palette.yellow.opacity(0.16)).frame(width: 130, height: 130)
                    Text("\(level)")
                        .font(Typeface.numeric(60))
                        .foregroundStyle(Palette.textPrimary)
                }
                .neonGlow(Palette.yellow, radius: 24, opacity: 0.7)
                Text("New gear and zones may be ready.")
                    .font(Typeface.medium(14))
                    .foregroundStyle(Palette.textSecondary)
                StreetButton(title: "Keep Skating", symbol: "checkmark", tint: Palette.yellow, action: onDismiss)
                    .frame(width: 240)
            }
            .padding(28)
            .panel(corner: Metrics.radiusLarge)
            .padding(40)
            .scaleEffect(appear ? 1 : 0.6)
            .opacity(appear ? 1 : 0)
        }
        .onAppear { withAnimation(Motion.bouncy) { appear = true } }
    }
}

struct AchievementPopup: View {
    let def: AchievementDef
    var onDismiss: () -> Void
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
                .onTapGesture(perform: onDismiss)
            VStack(spacing: 14) {
                Text("ACHIEVEMENT")
                    .font(Typeface.heavy(15))
                    .foregroundStyle(Palette.textDim)
                    .tracking(2)
                ZStack {
                    Circle().fill(Palette.yellow.opacity(0.16)).frame(width: 104, height: 104)
                    Image(systemName: def.symbol)
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(Palette.yellow)
                }
                .neonGlow(Palette.yellow, radius: 20, opacity: 0.7)
                Text(def.title)
                    .font(Typeface.display(22))
                    .foregroundStyle(Palette.textPrimary)
                    .multilineTextAlignment(.center)
                Text(def.detail)
                    .font(Typeface.medium(13))
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
                RewardRow(reward: def.reward)
                StreetButton(title: "Nice!", symbol: "hand.thumbsup.fill", tint: Palette.yellow, action: onDismiss)
                    .frame(width: 220)
            }
            .padding(26)
            .panel(corner: Metrics.radiusLarge)
            .padding(40)
            .scaleEffect(appear ? 1 : 0.6)
            .opacity(appear ? 1 : 0)
        }
        .onAppear { withAnimation(Motion.bouncy) { appear = true } }
    }
}

struct RewardRow: View {
    let reward: Reward

    var body: some View {
        HStack(spacing: 14) {
            if reward.coins > 0 { rewardItem("dollarsign.circle.fill", EconomyService.format(reward.coins), Palette.yellow) }
            if reward.xp > 0 { rewardItem("star.fill", "\(reward.xp)", Palette.lime) }
            if reward.cred > 0 { rewardItem("flame.fill", "\(reward.cred)", Palette.pink) }
            if let boost = reward.boost { rewardItem(GameContent.boost(boost).symbol, "Boost", Palette.violet) }
        }
        .padding(.vertical, 4)
    }

    private func rewardItem(_ symbol: String, _ value: String, _ tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(tint)
            Text(value)
                .font(Typeface.numeric(14))
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Palette.asphalt))
    }
}
