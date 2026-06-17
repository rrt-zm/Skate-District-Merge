import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let accent: Color
    let kind: PageArt
}

private enum PageArt {
    case logo
    case merge
    case generator
    case request
    case build
}

struct OnboardingView: View {
    @Environment(GameStore.self) private var store
    @State private var index = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to the Lot", body: "Turn a cracked concrete lot into a buzzing skate district. Merge gear, fill orders, and grow the scene.", accent: Palette.pink, kind: .logo),
        OnboardingPage(title: "Drag to Merge", body: "Drag two identical pieces together to merge them into the next tier. Planks become decks, decks become custom boards.", accent: Palette.cyan, kind: .merge),
        OnboardingPage(title: "Tap Generators", body: "Tap your supply crate and other generators to spawn fresh pieces. They recharge over time, even while you're away.", accent: Palette.yellow, kind: .generator),
        OnboardingPage(title: "Fill the Orders", body: "Skaters request specific items. Deliver them for coins, XP, and street cred to grow your district.", accent: Palette.lime, kind: .request),
        OnboardingPage(title: "Build the District", body: "Spend cred to unlock new zones. Each one fills the scene with ramps, color, neon, and more skaters.", accent: Palette.violet, kind: .build)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .font(Typeface.bold(15))
                    .foregroundStyle(Palette.textDim)
            }
            .padding(.horizontal, Metrics.lg)
            .padding(.top, 14)

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { offset, page in
                    pageView(page)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(Motion.smooth, value: index)

            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? pages[index].accent : Palette.stroke)
                        .frame(width: i == index ? 26 : 8, height: 8)
                        .animation(Motion.snappy, value: index)
                }
            }
            .padding(.bottom, 18)

            StreetButton(
                title: index == pages.count - 1 ? "Start Skating" : "Next",
                symbol: index == pages.count - 1 ? "play.fill" : "arrow.right",
                tint: pages[index].accent
            ) {
                if index == pages.count - 1 {
                    finish()
                } else {
                    withAnimation(Motion.snappy) { index += 1 }
                }
            }
            .padding(.horizontal, Metrics.xl)
            .padding(.bottom, 30)
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 26) {
            Spacer()
            onboardingArt(page)
                .frame(height: 200)
            VStack(spacing: 12) {
                Text(page.title)
                    .font(Typeface.display(28))
                    .foregroundStyle(Palette.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.body)
                    .font(Typeface.medium(15))
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func onboardingArt(_ page: OnboardingPage) -> some View {
        switch page.kind {
        case .logo:
            ZStack {
                Circle().fill(page.accent.opacity(0.14)).frame(width: 170, height: 170)
                ItemSprite(kind: ItemKind(chain: .ramps, tier: 8))
                    .frame(width: 130, height: 130)
            }
            .neonGlow(page.accent, radius: 26, opacity: 0.6)
        case .merge:
            HStack(spacing: 6) {
                ItemSprite(kind: ItemKind(chain: .boards, tier: 1)).frame(width: 64, height: 64)
                Image(systemName: "plus").font(.system(size: 20, weight: .black)).foregroundStyle(Palette.textDim)
                ItemSprite(kind: ItemKind(chain: .boards, tier: 1)).frame(width: 64, height: 64)
                Image(systemName: "arrow.right").font(.system(size: 20, weight: .black)).foregroundStyle(page.accent)
                ItemSprite(kind: ItemKind(chain: .boards, tier: 2)).frame(width: 74, height: 74)
            }
        case .generator:
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(Palette.concrete).frame(width: 130, height: 130)
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(page.accent.opacity(0.6), lineWidth: 2))
                Image(systemName: "shippingbox.fill").font(.system(size: 58, weight: .black)).foregroundStyle(page.accent)
                Image(systemName: "hand.tap.fill").font(.system(size: 30, weight: .black)).foregroundStyle(Palette.textPrimary)
                    .offset(x: 40, y: 44)
            }
        case .request:
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    SkaterAvatar(seed: 7, size: 48)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Rio wants").font(Typeface.bold(13)).foregroundStyle(Palette.textSecondary)
                        ItemSprite(kind: ItemKind(chain: .graffiti, tier: 3)).frame(width: 40, height: 40)
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 28, weight: .black)).foregroundStyle(page.accent)
                }
                .padding(14)
                .frame(width: 250)
                .panel()
            }
        case .build:
            ZStack {
                Circle().fill(page.accent.opacity(0.14)).frame(width: 170, height: 170)
                Image(systemName: "building.2.crop.circle.fill").font(.system(size: 96, weight: .black)).foregroundStyle(page.accent)
            }
            .neonGlow(page.accent, radius: 22, opacity: 0.6)
        }
    }

    private func finish() {
        store.completeOnboarding()
    }
}
