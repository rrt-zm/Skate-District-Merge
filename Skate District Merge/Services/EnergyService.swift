import Foundation

enum EnergyService {
    static func capacity(_ runtime: GeneratorRuntime) -> Int {
        GameContent.generator(runtime.id).capacity(level: runtime.capacityLevel)
    }

    static func refillSeconds(_ runtime: GeneratorRuntime, speedMultiplier: Double) -> Double {
        let base = GameContent.generator(runtime.id).refillSeconds(level: runtime.rateLevel)
        return max(0.4, base / max(0.1, speedMultiplier))
    }

    static func advance(_ runtime: inout GeneratorRuntime, now: Date, speedMultiplier: Double) {
        guard runtime.unlocked else {
            runtime.refillReference = now
            return
        }
        let cap = capacity(runtime)
        if runtime.energy >= cap {
            runtime.refillReference = now
            return
        }
        let seconds = refillSeconds(runtime, speedMultiplier: speedMultiplier)
        let elapsed = now.timeIntervalSince(runtime.refillReference)
        guard elapsed > 0 else {
            if elapsed < 0 { runtime.refillReference = now }
            return
        }
        let gained = Int(elapsed / seconds)
        if gained <= 0 { return }
        let applied = min(gained, cap - runtime.energy)
        runtime.energy += applied
        runtime.refillReference = runtime.refillReference.addingTimeInterval(Double(gained) * seconds)
        if runtime.energy >= cap {
            runtime.refillReference = now
        }
    }

    static func progressToNext(_ runtime: GeneratorRuntime, now: Date, speedMultiplier: Double) -> Double {
        let cap = capacity(runtime)
        if runtime.energy >= cap { return 1 }
        let seconds = refillSeconds(runtime, speedMultiplier: speedMultiplier)
        let elapsed = now.timeIntervalSince(runtime.refillReference)
        let fraction = (elapsed.truncatingRemainder(dividingBy: seconds)) / seconds
        return min(1, max(0, fraction))
    }

    static func secondsToNext(_ runtime: GeneratorRuntime, now: Date, speedMultiplier: Double) -> Double {
        let cap = capacity(runtime)
        if runtime.energy >= cap { return 0 }
        let seconds = refillSeconds(runtime, speedMultiplier: speedMultiplier)
        let elapsed = now.timeIntervalSince(runtime.refillReference)
        let remainder = seconds - elapsed.truncatingRemainder(dividingBy: seconds)
        return max(0, remainder)
    }
}
