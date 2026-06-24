import SwiftUI

@main
struct Skate_District_MergeApp: App {
    @State private var store: GameStore
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let environment = AppEnvironment()
        _store = State(initialValue: environment.store)
    }

    var body: some Scene {
        WindowGroup {
            LaunchRouterView()
                .environment(store)
                .task { store.start() }
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
        }
        .onChange(of: scenePhase) { _, phase in
            store.handleScenePhase(phase)
        }
    }
}
