import SwiftUI

struct SettingsScreen: View {
    @Environment(GameStore.self) private var store
    @State private var showResetConfirm = false
    @State private var showPrivacy = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                VStack(spacing: 2) {
                    SettingToggle(title: "Sound Effects", symbol: "speaker.wave.2.fill", tint: Palette.cyan,
                                  isOn: store.state.settings.soundEnabled) { store.setSound($0) }
                    divider
                    SettingToggle(title: "Music", symbol: "music.note", tint: Palette.pink,
                                  isOn: store.state.settings.musicEnabled) { store.setMusic($0) }
                    divider
                    SettingToggle(title: "Haptics", symbol: "iphone.radiowaves.left.and.right", tint: Palette.yellow,
                                  isOn: store.state.settings.hapticsEnabled) { store.setHaptics($0) }
                    divider
                    SettingToggle(title: "High Quality", symbol: "sparkles", tint: Palette.violet,
                                  isOn: store.state.settings.highQuality) { store.setHighQuality($0) }
                }
                .padding(6)
                .panel()

                VStack(spacing: 10) {
                    SettingAction(title: "Replay Tutorial", symbol: "graduationcap.fill", tint: Palette.lime) {
                        store.menuRoute = nil
                        store.resetTutorial()
                    }
                    SettingAction(title: "Privacy Policy", symbol: "hand.raised.fill", tint: Palette.cyan) {
                        showPrivacy = true
                    }
                    SettingAction(title: "Reset Progress", symbol: "trash.fill", tint: Palette.danger) {
                        showResetConfirm = true
                    }
                }

                aboutCard
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
        .alert("Reset all progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetProgress()
                store.menuRoute = nil
            }
        } message: {
            Text("This wipes your board, district, levels, and collection. This cannot be undone.")
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
    }

    private var divider: some View {
        Rectangle().fill(Palette.strokeSoft).frame(height: 1).padding(.horizontal, 8)
    }

    private var aboutCard: some View {
        VStack(spacing: 8) {
            ItemSprite(kind: ItemKind(chain: .graffiti, tier: 6)).frame(width: 54, height: 54)
            Text("Skate District Merge")
                .font(Typeface.heavy(17))
                .foregroundStyle(Palette.textPrimary)
            Text("Merge gear, fill orders, and build a buzzing street-sports hub from a bare lot. Plays fully offline.")
                .font(Typeface.medium(12))
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Text("Version 1.0")
                .font(Typeface.numeric(11))
                .foregroundStyle(Palette.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .panel()
    }
}

struct SettingToggle: View {
    var title: String
    var symbol: String
    var tint: Color
    var isOn: Bool
    var onChange: (Bool) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 28)
            Text(title)
                .font(Typeface.bold(15))
                .foregroundStyle(Palette.textPrimary)
            Spacer()
            Toggle("", isOn: Binding(get: { isOn }, set: { onChange($0) }))
                .labelsHidden()
                .tint(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}

struct SettingAction: View {
    var title: String
    var symbol: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(tint)
                    .frame(width: 28)
                Text(title)
                    .font(Typeface.bold(15))
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Palette.textDim)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 15)
            .panel()
        }
        .buttonStyle(PressScale(scale: 0.97))
    }
}
