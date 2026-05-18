import CoreGraphics
import Foundation

enum PlatformType {
    case normal, moving, fragile, spring
}

struct Platform {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat = GameConstants.platformWidth
    var height: CGFloat = 22
    var type: PlatformType = .normal
    var velocityX: CGFloat = 0
    var isActive: Bool = true
}
