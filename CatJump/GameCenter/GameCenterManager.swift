import GameKit

final class GameCenterManager {

    static let shared = GameCenterManager()
    private init() {}

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, _ in
            guard let vc = viewController else { return }
            self?.presentViewController(vc)
        }
    }

    // MARK: - Leaderboard

    func submitScore(_ score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["catjump.highscore"]
        ) { error in
            if let error { print("GameCenter submitScore error: \(error)") }
        }
    }

    func showLeaderboard() {
        guard GKLocalPlayer.local.isAuthenticated else { return }
#if os(iOS) || os(visionOS)
        let gcVC = GKGameCenterViewController(leaderboardID: "catjump.highscore",
                                              playerScope: .global,
                                              timeScope: .allTime)
        gcVC.gameCenterDelegate = GameCenterDismissDelegate.shared
        presentViewController(gcVC)
#endif
    }

    // MARK: - Private

    private func presentViewController(_ vc: AnyObject) {
#if os(iOS) || os(visionOS)
        guard let uiVC = vc as? UIViewController else { return }
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .rootViewController?
                .present(uiVC, animated: true)
        }
#endif
    }
}

// MARK: - Dismiss delegate

#if os(iOS) || os(visionOS)
private final class GameCenterDismissDelegate: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDismissDelegate()
    func gameCenterViewControllerDidFinish(_ controller: GKGameCenterViewController) {
        controller.dismiss(animated: true)
    }
}
#endif
