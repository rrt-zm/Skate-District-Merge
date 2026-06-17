import Foundation

struct Requirement: Codable, Hashable, Identifiable {
    var id: UUID
    var kind: ItemKind
    var count: Int

    init(kind: ItemKind, count: Int, id: UUID = UUID()) {
        self.id = id
        self.kind = kind
        self.count = count
    }
}

struct Order: Codable, Identifiable, Hashable {
    var id: UUID
    var skaterName: String
    var portraitSeed: Int
    var requirements: [Requirement]
    var rewardCoins: Int
    var rewardXP: Int
    var rewardCred: Int
    var createdAt: Date

    init(skaterName: String,
         portraitSeed: Int,
         requirements: [Requirement],
         rewardCoins: Int,
         rewardXP: Int,
         rewardCred: Int,
         id: UUID = UUID(),
         createdAt: Date = Date()) {
        self.id = id
        self.skaterName = skaterName
        self.portraitSeed = portraitSeed
        self.requirements = requirements
        self.rewardCoins = rewardCoins
        self.rewardXP = rewardXP
        self.rewardCred = rewardCred
        self.createdAt = createdAt
    }
}
