import Foundation

enum ZoneID: String, Codable, CaseIterable, Identifiable, Hashable {
    case streetPlaza
    case bowl
    case vertPark
    case graffitiAlley
    case shopRow
    case nightStrip

    var id: String { rawValue }
}

struct DistrictState: Codable {
    var unlockedZones: Set<ZoneID>
    var placedStructures: [String]

    static var initial: DistrictState {
        DistrictState(unlockedZones: [.streetPlaza], placedStructures: [])
    }
}

struct PlayerProgress: Codable {
    var level: Int
    var xp: Int

    static var initial: PlayerProgress {
        PlayerProgress(level: 1, xp: 0)
    }
}

enum SkaterTrick: String, Codable, CaseIterable {
    case ollie
    case kickflip
    case grind
    case manual
    case airGrab
}
