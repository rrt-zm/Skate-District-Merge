import Foundation

struct GameState: Codable {
    static let currentVersion = 1

    var version: Int
    var createdAt: Date
    var lastSeen: Date

    var board: Board
    var generators: [GeneratorRuntime]
    var coins: Int
    var cred: Int
    var progress: PlayerProgress

    var orders: [Order]
    var orderReference: Date

    var district: DistrictState
    var boosts: BoostInventory
    var statistics: Statistics
    var settings: GameSettings

    var questProgress: [String: Int]
    var questsClaimed: Set<String>
    var achievementProgress: [String: Int]
    var achievementsClaimed: Set<String>

    var discovered: Set<String>
    var attractedSkaters: Int

    func generator(_ id: GeneratorID) -> GeneratorRuntime? {
        generators.first(where: { $0.id == id })
    }

    mutating func updateGenerator(_ id: GeneratorID, _ transform: (inout GeneratorRuntime) -> Void) {
        guard let index = generators.firstIndex(where: { $0.id == id }) else { return }
        transform(&generators[index])
    }
}
