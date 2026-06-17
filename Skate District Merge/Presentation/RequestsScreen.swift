import SwiftUI

struct RequestsScreen: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                SectionHeader(title: "Skater Orders", symbol: "list.bullet.clipboard.fill", accent: Palette.yellow)

                if store.state.orders.isEmpty {
                    EmptyStateView(
                        symbol: "clock.badge.checkmark",
                        title: "No orders yet",
                        message: "Skaters are on their way. New requests roll in every few seconds.",
                        tint: Palette.yellow
                    )
                    .panel()
                } else {
                    ForEach(store.state.orders) { order in
                        FullOrderCard(order: order)
                    }
                }

                ForEach(0..<max(0, Balance.maxActiveOrders - store.state.orders.count), id: \.self) { _ in
                    incomingSlot
                }
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
    }

    private var incomingSlot: some View {
        HStack(spacing: 10) {
            Image(systemName: "hourglass")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Palette.textDim)
            Text("Incoming order…")
                .font(Typeface.medium(14))
                .foregroundStyle(Palette.textDim)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous)
                .fill(Palette.concrete.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: Metrics.radius).strokeBorder(Palette.strokeSoft, style: StrokeStyle(lineWidth: 1.5, dash: [5, 5])))
        )
    }
}

struct FullOrderCard: View {
    @Environment(GameStore.self) private var store
    let order: Order

    var body: some View {
        let canFulfill = OrderService.canFulfill(order, board: store.state.board)
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SkaterAvatar(seed: order.portraitSeed, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(order.skaterName)
                        .font(Typeface.heavy(17))
                        .foregroundStyle(Palette.textPrimary)
                    Text("wants some gear")
                        .font(Typeface.medium(12))
                        .foregroundStyle(Palette.textDim)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    rewardTag("dollarsign.circle.fill", EconomyService.format(order.rewardCoins), Palette.yellow)
                    HStack(spacing: 6) {
                        rewardTag("star.fill", "\(order.rewardXP)", Palette.lime)
                        rewardTag("flame.fill", "\(order.rewardCred)", Palette.pink)
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(order.requirements) { req in
                    RequirementChip(requirement: req, have: store.state.board.count(of: req.kind))
                }
                Spacer()
            }

            Button {
                store.fulfill(order)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: canFulfill ? "checkmark.seal.fill" : "shippingbox")
                        .font(.system(size: 15, weight: .black))
                    Text(canFulfill ? "Deliver Order" : "Collect the items first")
                        .font(Typeface.heavy(15))
                }
                .foregroundStyle(canFulfill ? Palette.ink : Palette.textDim)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous)
                        .fill(canFulfill ? AnyShapeStyle(Palette.success) : AnyShapeStyle(Palette.asphalt))
                )
            }
            .buttonStyle(PressScale())
            .disabled(!canFulfill)
        }
        .padding(14)
        .panel()
    }

    private func rewardTag(_ symbol: String, _ value: String, _ tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(tint)
            Text(value)
                .font(Typeface.numeric(13))
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Palette.asphalt))
    }
}
