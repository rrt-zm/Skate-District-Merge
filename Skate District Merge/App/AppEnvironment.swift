import Foundation

final class AppEnvironment {
    let store: GameStore

    init() {
        let save = SaveService()
        let audio = AudioHapticsService()
        store = GameStore(save: save, audio: audio)
    }
}
