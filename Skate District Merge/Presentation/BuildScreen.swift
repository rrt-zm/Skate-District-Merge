import SwiftUI

struct BuildScreen: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                DistrictSceneView()
                    .frame(height: 140)

                SectionHeader(title: "District Zones", symbol: "map.fill", accent: Palette.pink)

                ForEach(GameContent.zones, id: \.id) { zone in
                    ZoneCard(zone: zone)
                }
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 10)
            .padding(.bottom, 110)
        }
    }
}

struct ZoneCard: View {
    @Environment(GameStore.self) private var store
    let zone: ZoneDef

    var body: some View {
        let unlocked = store.state.district.unlockedZones.contains(zone.id)
        let levelOK = store.state.progress.level >= zone.unlockLevel
        let affordable = store.state.cred >= zone.cost
        let accent: Color = unlocked ? Palette.success : Palette.pink

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accent.opacity(0.16))
                        .frame(width: 52, height: 52)
                    Image(systemName: zoneSymbol)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(accent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(zone.title)
                        .font(Typeface.heavy(17))
                        .foregroundStyle(Palette.textPrimary)
                    Text(zone.blurb)
                        .font(Typeface.medium(12))
                        .foregroundStyle(Palette.textSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Label("\(zone.skaterBonus) skaters", systemImage: "figure.skating")
                    .font(Typeface.bold(11))
                    .foregroundStyle(Palette.cyan)
                Label("Lv \(zone.unlockLevel)", systemImage: "star.fill")
                    .font(Typeface.bold(11))
                    .foregroundStyle(levelOK || unlocked ? Palette.lime : Palette.textDim)
                Spacer()
            }

            if unlocked {
                statusBar(text: "Built", symbol: "checkmark.seal.fill", tint: Palette.success)
            } else if !levelOK {
                statusBar(text: "Reach level \(zone.unlockLevel)", symbol: "lock.fill", tint: Palette.textDim)
            } else {
                Button {
                    store.unlockZone(zone.id)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill").font(.system(size: 13, weight: .black))
                        Text("Build for \(EconomyService.format(zone.cost))")
                            .font(Typeface.heavy(15))
                    }
                    .foregroundStyle(affordable ? Palette.ink : Palette.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: Metrics.radius, style: .continuous)
                            .fill(affordable ? AnyShapeStyle(Palette.pink) : AnyShapeStyle(Palette.asphalt))
                    )
                }
                .buttonStyle(PressScale())
                .disabled(!affordable)
            }
        }
        .padding(14)
        .panel(stroke: unlocked ? Palette.success.opacity(0.5) : Palette.stroke)
    }

    private func statusBar(text: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol).font(.system(size: 13, weight: .black))
            Text(text).font(Typeface.bold(14))
            Spacer()
        }
        .foregroundStyle(tint)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Palette.asphalt))
    }

    private var zoneSymbol: String {
        switch zone.id {
        case .streetPlaza: return "square.split.bottomrightquarter.fill"
        case .graffitiAlley: return "paintbrush.pointed.fill"
        case .bowl: return "circle.bottomhalf.filled"
        case .shopRow: return "bag.fill"
        case .vertPark: return "triangle.fill"
        case .nightStrip: return "moon.stars.fill"
        }
    }
}
