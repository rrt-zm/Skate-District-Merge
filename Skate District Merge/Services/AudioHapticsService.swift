import Foundation
import AVFoundation
import UIKit

enum SoundEffect {
    case tap
    case merge
    case spawn
    case reward
    case levelUp
    case error
    case unlock
}

final class AudioHapticsService {
    var soundEnabled = true
    var musicEnabled = true
    var hapticsEnabled = true

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var musicRunning = false
    private var phase: [Float] = [0, 0, 0]
    private let sampleRate: Float = 44100
    private var lfoPhase: Float = 0

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()

    func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        lightImpact.prepare()
        mediumImpact.prepare()
        rigidImpact.prepare()
    }

    func play(_ effect: SoundEffect) {
        guard soundEnabled else { return }
        let id: SystemSoundID
        switch effect {
        case .tap: id = 1104
        case .merge: id = 1105
        case .spawn: id = 1103
        case .reward: id = 1057
        case .levelUp: id = 1025
        case .error: id = 1053
        case .unlock: id = 1322
        }
        AudioServicesPlaySystemSound(id)
    }

    func impact(_ strength: ImpactStrength) {
        guard hapticsEnabled else { return }
        switch strength {
        case .light: lightImpact.impactOccurred(intensity: 0.7)
        case .medium: mediumImpact.impactOccurred()
        case .rigid: rigidImpact.impactOccurred()
        }
    }

    func success() {
        guard hapticsEnabled else { return }
        notification.notificationOccurred(.success)
    }

    func warning() {
        guard hapticsEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    func syncMusic() {
        if musicEnabled {
            startMusic()
        } else {
            stopMusic()
        }
    }

    func startMusic() {
        guard musicEnabled, !musicRunning else { return }
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2)
        guard let format else { return }
        let frequencies: [Float] = [110.0, 164.81, 220.0]
        let node = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let increment = (2.0 * Float.pi) / self.sampleRate
            for frame in 0..<Int(frameCount) {
                self.lfoPhase += 0.6 * increment
                if self.lfoPhase > 2 * Float.pi { self.lfoPhase -= 2 * Float.pi }
                let swell = 0.5 + 0.5 * sinf(self.lfoPhase)
                var sample: Float = 0
                for voice in 0..<frequencies.count {
                    self.phase[voice] += frequencies[voice] * increment
                    if self.phase[voice] > 2 * Float.pi { self.phase[voice] -= 2 * Float.pi }
                    sample += sinf(self.phase[voice])
                }
                sample = sample / Float(frequencies.count) * 0.06 * (0.6 + 0.4 * swell)
                for buffer in buffers {
                    let pointer = buffer.mData?.assumingMemoryBound(to: Float.self)
                    pointer?[frame] = sample
                }
            }
            return noErr
        }
        sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.5
        do {
            try engine.start()
            musicRunning = true
        } catch {
            musicRunning = false
        }
    }

    func stopMusic() {
        guard musicRunning else { return }
        engine.stop()
        if let node = sourceNode {
            engine.detach(node)
            sourceNode = nil
        }
        musicRunning = false
    }
}

enum ImpactStrength {
    case light
    case medium
    case rigid
}
