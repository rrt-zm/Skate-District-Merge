import Foundation

struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed != 0 ? seed : 0x9E3779B97F4A7C15
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func int(_ range: ClosedRange<Int>) -> Int {
        Int.random(in: range, using: &self)
    }

    mutating func double() -> Double {
        Double(next() >> 11) * (1.0 / 9007199254740992.0)
    }

    mutating func chance(_ probability: Double) -> Bool {
        double() < probability
    }
}
