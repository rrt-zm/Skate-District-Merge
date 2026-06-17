import Foundation

final class SaveService {
    private let filename = "skate_district_save.json"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
    }

    private var fileURL: URL? {
        guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory.appendingPathComponent(filename)
    }

    func load() -> GameState? {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
        guard var state = try? decoder.decode(GameState.self, from: data) else { return nil }
        state = Migration.migrate(state)
        return state
    }

    func save(_ state: GameState) {
        guard let url = fileURL, let data = try? encoder.encode(state) else { return }
        try? data.write(to: url, options: .atomic)
    }

    func clear() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}

enum Migration {
    static func migrate(_ state: GameState) -> GameState {
        var migrated = state
        if migrated.board.columns != Balance.boardColumns {
            migrated.board.columns = Balance.boardColumns
        }
        if migrated.version < GameState.currentVersion {
            migrated.version = GameState.currentVersion
        }
        return migrated
    }
}
