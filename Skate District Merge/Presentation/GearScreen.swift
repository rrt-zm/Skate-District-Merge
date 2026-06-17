import SwiftUI

struct GearScreen: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                SectionHeader(title: "Board Space", symbol: "square.grid.3x3.fill", accent: Palette.cyan)
                BoardExpansionCard()

                SectionHeader(title: "Boosts", symbol: "bolt.fill", accent: Palette.orange)
                BoostsPanel()

                SectionHeader(title: "Generators", symbol: "shippingbox.fill", accent: Palette.violet)
                ForEach(store.state.generators) { runtime in
                    GeneratorUpgradeCard(runtime: runtime)
                }
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
    }
}

struct BoardExpansionCard: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        let board = store.state.board
        let maxed = board.unlockedRows >= board.maxRows
        let cost = Balance.boardExpansionCost(currentRows: board.unlockedRows)
        let affordable = store.state.coins >= cost

        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Board Rows")
                    .font(Typeface.heavy(16))
                    .foregroundStyle(Palette.textPrimary)
                Text("\(board.unlockedRows) of \(board.maxRows) rows unlocked")
                    .font(Typeface.medium(12))
                    .foregroundStyle(Palette.textSecondary)
                ProgressBarView(value: Double(board.unlockedRows) / Double(board.maxRows), tint: Palette.cyan, height: 8)
                    .frame(width: 150)
            }
            Spacer()
            if maxed {
                Text("MAX")
                    .font(Typeface.heavy(14))
                    .foregroundStyle(Palette.lime)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Capsule().fill(Palette.asphalt))
            } else {
                Button { store.expandBoard() } label: {
                    VStack(spacing: 1) {
                        Image(systemName: "plus.square.fill.on.square.fill").font(.system(size: 16, weight: .black))
                        Text(EconomyService.format(cost)).font(Typeface.numeric(12))
                    }
                    .foregroundStyle(affordable ? Palette.ink : Palette.textDim)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 13).fill(affordable ? AnyShapeStyle(Palette.cyan) : AnyShapeStyle(Palette.asphalt)))
                }
                .buttonStyle(PressScale())
                .disabled(!affordable)
            }
        }
        .padding(14)
        .panel()
    }
}

struct BoostsPanel: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        VStack(spacing: 10) {
            ForEach(GameContent.boosts) { boost in
                BoostRow(boost: boost)
            }
        }
    }
}

struct BoostRow: View {
    @Environment(GameStore.self) private var store
    let boost: BoostDef

    var body: some View {
        let owned = store.state.boosts.owned[boost.id] ?? 0
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Palette.orange.opacity(0.16)).frame(width: 48, height: 48)
                Image(systemName: boost.symbol).font(.system(size: 22, weight: .black)).foregroundStyle(Palette.orange)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(boost.title).font(Typeface.heavy(15)).foregroundStyle(Palette.textPrimary)
                Text(boost.blurb).font(Typeface.medium(11)).foregroundStyle(Palette.textSecondary).lineLimit(2)
            }
            Spacer(minLength: 4)
            TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
                let remaining = BoostService.remaining(boost.id, state: store.state, now: timeline.date)
                if remaining > 0 {
                    Text("\(Int(remaining))s")
                        .font(Typeface.numeric(14))
                        .foregroundStyle(Palette.lime)
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .background(Capsule().fill(Palette.asphalt))
                } else {
                    Button { store.activateBoost(boost.id) } label: {
                        VStack(spacing: 0) {
                            Text(owned > 0 ? "Use" : "None")
                                .font(Typeface.heavy(13))
                            Text("x\(owned)")
                                .font(Typeface.numeric(11))
                        }
                        .foregroundStyle(owned > 0 ? Palette.ink : Palette.textDim)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(owned > 0 ? AnyShapeStyle(Palette.orange) : AnyShapeStyle(Palette.asphalt)))
                    }
                    .buttonStyle(PressScale())
                    .disabled(owned == 0)
                }
            }
        }
        .padding(12)
        .panel()
    }
}

struct GeneratorUpgradeCard: View {
    @Environment(GameStore.self) private var store
    let runtime: GeneratorRuntime

    var body: some View {
        let def = GameContent.generator(runtime.id)
        let accent = Palette.accent(def.chain)

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(accent.opacity(0.16)).frame(width: 50, height: 50)
                    ItemSprite(kind: ItemKind(chain: def.chain, tier: 1)).frame(width: 34, height: 34)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(def.title).font(Typeface.heavy(16)).foregroundStyle(Palette.textPrimary)
                    Text(def.blurb).font(Typeface.medium(11)).foregroundStyle(Palette.textSecondary).lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            if runtime.unlocked {
                HStack(spacing: 8) {
                    upgradeButton(.capacity, label: "Storage", level: runtime.capacityLevel, max: def.maxUpgradeLevel,
                                  cost: Balance.capacityUpgradeCost(level: runtime.capacityLevel), symbol: "tray.full.fill", tint: accent)
                    upgradeButton(.rate, label: "Speed", level: runtime.rateLevel, max: def.maxUpgradeLevel,
                                  cost: Balance.rateUpgradeCost(level: runtime.rateLevel), symbol: "bolt.fill", tint: accent)
                    upgradeButton(.quality, label: "Quality", level: runtime.qualityLevel, max: def.maxUpgradeLevel,
                                  cost: Balance.qualityUpgradeCost(level: runtime.qualityLevel), symbol: "sparkles", tint: accent)
                }
            } else {
                HStack(spacing: 7) {
                    Image(systemName: "lock.fill").font(.system(size: 13, weight: .black))
                    Text("Unlocks at level \(def.unlockLevel)").font(Typeface.bold(14))
                    Spacer()
                }
                .foregroundStyle(Palette.textDim)
                .padding(.vertical, 10).padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Palette.asphalt))
            }
        }
        .padding(14)
        .panel()
    }

    private func upgradeButton(_ kind: UpgradeKind, label: String, level: Int, max: Int, cost: Int, symbol: String, tint: Color) -> some View {
        let maxed = level >= max
        let affordable = store.state.coins >= cost
        return Button { store.upgrade(runtime.id, kind: kind) } label: {
            VStack(spacing: 3) {
                Image(systemName: symbol).font(.system(size: 14, weight: .black)).foregroundStyle(tint)
                Text(label).font(Typeface.label(10)).foregroundStyle(Palette.textSecondary)
                Text("Lv \(level)").font(Typeface.numeric(11)).foregroundStyle(Palette.textPrimary)
                if maxed {
                    Text("MAX").font(Typeface.label(10)).foregroundStyle(Palette.lime)
                } else {
                    Text(EconomyService.format(cost)).font(Typeface.numeric(11)).foregroundStyle(affordable ? Palette.yellow : Palette.textDim)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 12).fill(Palette.asphalt).overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(tint.opacity(maxed ? 0.1 : 0.35), lineWidth: 1.5)))
        }
        .buttonStyle(PressScale(scale: 0.94))
        .disabled(maxed || !affordable)
    }
}
