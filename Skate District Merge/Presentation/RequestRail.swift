import SwiftUI

struct RequestRail: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard.fill")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Palette.yellow)
                Text("ORDERS")
                    .font(Typeface.heavy(13))
                    .foregroundStyle(Palette.textPrimary)
                    .tracking(1)
                Spacer()
                Button { store.selectedTab = .requests } label: {
                    Text("See all")
                        .font(Typeface.bold(12))
                        .foregroundStyle(Palette.cyan)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.state.orders) { order in
                        CompactOrderCard(order: order)
                    }
                    if store.state.orders.isEmpty {
                        Text("New orders rolling in…")
                            .font(Typeface.medium(13))
                            .foregroundStyle(Palette.textDim)
                            .padding(.vertical, 22)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

struct CompactOrderCard: View {
    @Environment(GameStore.self) private var store
    let order: Order

    var body: some View {
        let canFulfill = OrderService.canFulfill(order, board: store.state.board)
        VStack(spacing: 8) {
            HStack(spacing: 7) {
                SkaterAvatar(seed: order.portraitSeed, size: 32)
                VStack(alignment: .leading, spacing: 0) {
                    Text(order.skaterName)
                        .font(Typeface.bold(13))
                        .foregroundStyle(Palette.textPrimary)
                    HStack(spacing: 3) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Palette.yellow)
                        Text(EconomyService.format(order.rewardCoins))
                            .font(Typeface.numeric(11))
                            .foregroundStyle(Palette.textSecondary)
                    }
                }
            }

            HStack(spacing: 6) {
                ForEach(order.requirements) { req in
                    RequirementChip(requirement: req, have: store.state.board.count(of: req.kind))
                }
            }

            Button {
                store.fulfill(order)
            } label: {
                Text(canFulfill ? "Deliver" : "Need items")
                    .font(Typeface.heavy(12))
                    .foregroundStyle(canFulfill ? Palette.ink : Palette.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(canFulfill ? AnyShapeStyle(Palette.success) : AnyShapeStyle(Palette.asphalt))
                    )
            }
            .buttonStyle(PressScale())
            .disabled(!canFulfill)
        }
        .padding(11)
        .frame(width: 168)
        .panel()
    }
}
