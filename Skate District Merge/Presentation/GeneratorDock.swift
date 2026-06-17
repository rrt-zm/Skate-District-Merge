import SwiftUI

struct GeneratorDock: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        HStack(spacing: 10) {
            ForEach(store.state.generators) { runtime in
                GeneratorButton(runtime: runtime)
            }
        }
    }
}

struct GeneratorButton: View {
    @Environment(GameStore.self) private var store
    let runtime: GeneratorRuntime

    var body: some View {
        let def = GameContent.generator(runtime.id)
        let accent = Palette.accent(def.chain)

        Group {
            if runtime.unlocked {
                unlockedButton(def: def, accent: accent)
            } else {
                lockedButton(def: def, accent: accent)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func unlockedButton(def: GeneratorDef, accent: Color) -> some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { timeline in
            let now = timeline.date
            let cap = EnergyService.capacity(runtime)
            let speed = store.generatorSpeedMultiplier
            let partial = EnergyService.progressToNext(runtime, now: now, speedMultiplier: speed)
            let fraction = min(1, (Double(runtime.energy) + partial) / Double(max(1, cap)))
            let canTap = runtime.energy > 0 && store.state.board.firstEmptyPlayableIndex != nil

            Button {
                store.tapGenerator(runtime.id)
            } label: {
                VStack(spacing: 4) {
                    ZStack {
                        CooldownRing(progress: fraction, tint: accent, lineWidth: 3.5)
                            .frame(width: 50, height: 50)
                        ItemSprite(kind: ItemKind(chain: def.chain, tier: 1))
                            .frame(width: 30, height: 30)
                    }
                    Text("\(runtime.energy)/\(cap)")
                        .font(Typeface.numeric(11))
                        .foregroundStyle(runtime.energy > 0 ? Palette.textPrimary : Palette.textDim)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Palette.concrete)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(canTap ? 0.6 : 0.2), lineWidth: 1.5))
                )
                .opacity(canTap ? 1 : 0.55)
            }
            .buttonStyle(PressScale())
            .disabled(!canTap)
        }
    }

    private func lockedButton(def: GeneratorDef, accent: Color) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(Palette.asphalt).frame(width: 50, height: 50)
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Palette.textDim)
            }
            Text("Lv \(def.unlockLevel)")
                .font(Typeface.numeric(11))
                .foregroundStyle(Palette.textDim)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Palette.concrete.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Palette.strokeSoft, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])))
        )
    }
}
