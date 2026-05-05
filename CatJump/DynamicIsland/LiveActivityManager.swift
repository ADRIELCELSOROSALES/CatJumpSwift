import ActivityKit
import Foundation

@available(iOS 16.2, *)
final class LiveActivityManager {

    static let shared = LiveActivityManager()
    private var activity: Activity<CatJumpAttributes>?
    private init() {}

    // MARK: - Lifecycle

    func start(playerName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        guard activity == nil else { return }

        let attributes = CatJumpAttributes(playerName: playerName)
        let state = CatJumpAttributes.ContentState(
            score: 0, lives: 3, level: 1, isGameOver: false
        )
        let content = ActivityContent(state: state, staleDate: nil)
        activity = try? Activity.request(attributes: attributes, content: content)
    }

    func update(score: Int, lives: Int, level: Int) {
        guard let activity else { return }
        let state = CatJumpAttributes.ContentState(
            score: score, lives: lives, level: level, isGameOver: false
        )
        let content = ActivityContent(state: state, staleDate: nil)
        Task { await activity.update(content) }
    }

    func end(score: Int) {
        guard let activity else { return }
        let state = CatJumpAttributes.ContentState(
            score: score, lives: 0, level: 0, isGameOver: true
        )
        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.end(content, dismissalPolicy: .after(Date().addingTimeInterval(5)))
        }
        self.activity = nil
    }
}
