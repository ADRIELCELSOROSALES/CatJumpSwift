#if os(iOS) || os(visionOS)
import UIKit

final class HapticManager {

    static let shared = HapticManager()
    private init() {
        light.prepare()
        heavy.prepare()
        notify.prepare()
    }

    private let light  = UIImpactFeedbackGenerator(style: .light)
    private let heavy  = UIImpactFeedbackGenerator(style: .heavy)
    private let notify = UINotificationFeedbackGenerator()

    func jumpFeedback()    { light.impactOccurred() }
    func loseLifeFeedback() { heavy.impactOccurred() }
    func powerUpFeedback() { notify.notificationOccurred(.success) }
    func gameOverFeedback() { notify.notificationOccurred(.error) }
}
#endif
