import SwiftUI

struct QuestsScreen: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(QuestEngine.chapters, id: \.self) { chapter in
                    chapterSection(chapter)
                }
            }
            .padding(.horizontal, Metrics.md)
            .padding(.top, 6)
            .padding(.bottom, 40)
        }
    }

    private func chapterSection(_ chapter: Int) -> some View {
        let quests = GameContent.quests.filter { $0.chapter == chapter }.sorted { $0.order < $1.order }
        let done = quests.filter { store.state.questsClaimed.contains($0.id) }.count
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("CHAPTER \(chapter)")
                    .font(Typeface.heavy(13))
                    .foregroundStyle(Palette.lime)
                    .tracking(1.5)
                Spacer()
                Text("\(done)/\(quests.count)")
                    .font(Typeface.numeric(12))
                    .foregroundStyle(Palette.textDim)
            }
            ForEach(quests) { quest in
                QuestCard(quest: quest)
            }
        }
    }
}

struct QuestCard: View {
    @Environment(GameStore.self) private var store
    let quest: QuestDef

    var body: some View {
        let progress = QuestEngine.progressValue(quest, progress: store.state.questProgress)
        let complete = QuestEngine.isComplete(quest, progress: store.state.questProgress)
        let claimed = store.state.questsClaimed.contains(quest.id)
        let fraction = Double(progress) / Double(max(1, quest.goal.target))

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11).fill((claimed ? Palette.success : Palette.lime).opacity(0.16)).frame(width: 44, height: 44)
                    Image(systemName: claimed ? "checkmark.seal.fill" : "flag.checkered")
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(claimed ? Palette.success : Palette.lime)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(quest.title).font(Typeface.heavy(16)).foregroundStyle(Palette.textPrimary)
                    Text(quest.detail).font(Typeface.medium(12)).foregroundStyle(Palette.textSecondary).lineLimit(2)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                ProgressBarView(value: fraction, tint: claimed ? Palette.success : Palette.lime, height: 9)
                Text("\(progress)/\(quest.goal.target)")
                    .font(Typeface.numeric(12))
                    .foregroundStyle(Palette.textSecondary)
            }

            HStack(spacing: 10) {
                RewardRow(reward: quest.reward)
                Spacer()
                if claimed {
                    Text("Claimed").font(Typeface.bold(13)).foregroundStyle(Palette.textDim)
                } else if complete {
                    Button { store.claimQuest(quest.id) } label: {
                        Text("Claim")
                            .font(Typeface.heavy(14))
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .background(Capsule().fill(Palette.lime))
                            .neonGlow(Palette.lime, radius: 8, opacity: 0.6)
                    }
                    .buttonStyle(PressScale())
                } else {
                    Text("In progress").font(Typeface.bold(12)).foregroundStyle(Palette.textDim)
                }
            }
        }
        .padding(14)
        .panel(stroke: complete && !claimed ? Palette.lime.opacity(0.6) : Palette.stroke)
    }
}
