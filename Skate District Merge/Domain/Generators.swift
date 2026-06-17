import Foundation

enum GeneratorID: String, Codable, CaseIterable, Identifiable, Hashable {
    case supplyCrate
    case rampKit
    case paintCan
    case lampCrate
    case shopCrate

    var id: String { rawValue }
}

struct GeneratorRuntime: Codable, Identifiable {
    var id: GeneratorID
    var energy: Int
    var capacityLevel: Int
    var rateLevel: Int
    var qualityLevel: Int
    var refillReference: Date
    var unlocked: Bool

    init(id: GeneratorID,
         energy: Int,
         capacityLevel: Int = 1,
         rateLevel: Int = 1,
         qualityLevel: Int = 1,
         refillReference: Date = Date(),
         unlocked: Bool) {
        self.id = id
        self.energy = energy
        self.capacityLevel = capacityLevel
        self.rateLevel = rateLevel
        self.qualityLevel = qualityLevel
        self.refillReference = refillReference
        self.unlocked = unlocked
    }
}
