import SwiftUI

struct MainShell: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        @Bindable var store = store
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HUDBar()
                    .padding(.horizontal, Metrics.md)
                    .padding(.top, 6)
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            StreetTabBar(selected: $store.selectedTab)
                .padding(.horizontal, Metrics.lg)
                .padding(.bottom, 6)
        }
        .fullScreenCover(item: $store.menuRoute) { route in
            MenuRouteView(route: route)
                .environment(store)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.selectedTab {
        case .home: HomeScreen()
        case .requests: RequestsScreen()
        case .build: BuildScreen()
        case .gear: GearScreen()
        case .codex: CodexScreen()
        }
    }
}

struct HUDBar: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        let level = store.state.progress.level
        let xpNeeded = Balance.xpToNext(level: level)
        let xpFraction = Double(store.state.progress.xp) / Double(max(1, xpNeeded))

        HStack(spacing: 10) {
            ZStack {
                CooldownRing(progress: xpFraction, tint: Palette.lime, lineWidth: 3)
                    .frame(width: 44, height: 44)
                VStack(spacing: -2) {
                    Text("LV")
                        .font(Typeface.label(8))
                        .foregroundStyle(Palette.textDim)
                    Text("\(level)")
                        .font(Typeface.numeric(17))
                        .foregroundStyle(Palette.textPrimary)
                }
            }

            Spacer(minLength: 4)

            CurrencyChip(symbol: "dollarsign.circle.fill", value: store.state.coins, tint: Palette.yellow)
            CurrencyChip(symbol: "flame.fill", value: store.state.cred, tint: Palette.pink)

            Menu {
                Button { store.menuRoute = .quests } label: { Label("Quests", systemImage: "flag.checkered") }
                Button { store.menuRoute = .achievements } label: { Label("Achievements", systemImage: "rosette") }
                Button { store.menuRoute = .statistics } label: { Label("Statistics", systemImage: "chart.bar.fill") }
                Button { store.menuRoute = .settings } label: { Label("Settings", systemImage: "gearshape.fill") }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Palette.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(Palette.concrete)
                            .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(Palette.violet.opacity(0.45), lineWidth: 1.5))
                    )
            }
        }
    }
}

struct StreetTabBar: View {
    @Binding var selected: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                let isOn = tab == selected
                Button {
                    withAnimation(Motion.snappy) { selected = tab }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .black))
                        Text(tab.title)
                            .font(Typeface.label(9))
                            .tracking(0.4)
                    }
                    .foregroundStyle(isOn ? Palette.ink : Palette.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(isOn ? AnyShapeStyle(tabTint) : AnyShapeStyle(Color.clear))
                            .neonGlow(isOn ? tabTint : .clear, radius: 7, opacity: 0.6)
                    )
                }
                .buttonStyle(PressScale(scale: 0.9))
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.concrete.opacity(0.96))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Palette.stroke, lineWidth: 1.5))
        )
        .shadow(color: .black.opacity(0.5), radius: 14, y: 8)
    }

    private var tabTint: Color {
        switch selected {
        case .home: return Palette.cyan
        case .requests: return Palette.yellow
        case .build: return Palette.pink
        case .gear: return Palette.violet
        case .codex: return Palette.lime
        }
    }
}

struct NavScaffold<Content: View>: View {
    var title: String
    var symbol: String
    var accent: Color
    var onClose: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            BackdropView()
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: symbol)
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(accent)
                    Text(title)
                        .font(Typeface.display(24))
                        .foregroundStyle(Palette.textPrimary)
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Palette.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Palette.concrete).overlay(Circle().strokeBorder(Palette.stroke, lineWidth: 1.5)))
                    }
                    .buttonStyle(PressScale())
                }
                .padding(.horizontal, Metrics.lg)
                .padding(.top, 16)
                .padding(.bottom, 10)

                content
            }
        }
    }
}

struct MenuRouteView: View {
    @Environment(GameStore.self) private var store
    let route: MenuRoute

    var body: some View {
        switch route {
        case .quests:
            NavScaffold(title: "Quests", symbol: "flag.checkered", accent: Palette.lime) { store.menuRoute = nil } content: { QuestsScreen() }
        case .achievements:
            NavScaffold(title: "Achievements", symbol: "rosette", accent: Palette.yellow) { store.menuRoute = nil } content: { AchievementsScreen() }
        case .statistics:
            NavScaffold(title: "Statistics", symbol: "chart.bar.fill", accent: Palette.cyan) { store.menuRoute = nil } content: { StatisticsScreen() }
        case .settings:
            NavScaffold(title: "Settings", symbol: "gearshape.fill", accent: Palette.violet) { store.menuRoute = nil } content: { SettingsScreen() }
        }
    }
}
