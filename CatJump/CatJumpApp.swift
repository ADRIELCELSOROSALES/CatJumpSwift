import SwiftUI

@main
struct CatJumpApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    GameCenterManager.shared.authenticate()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                SoundManager.shared.pauseForBackground()
            case .active:
                SoundManager.shared.resumeFromBackground()
            default:
                break
            }
        }
    }
}
