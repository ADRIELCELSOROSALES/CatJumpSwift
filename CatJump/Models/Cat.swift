import CoreGraphics
import Foundation

struct Cat {
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat = 0
    var velocityY: CGFloat = 0
    var width: CGFloat = 78
    var height: CGFloat = 78
    var isJumping: Bool = false
    var facingRight: Bool = true
    var fatness: CGFloat = 0.0
    var birdsEaten: Int = 0
    var lives: Int = 3
    var invincibilityFrames: Int = 0
    var jetpackActive: Bool = false
    var jetpackEndTime: TimeInterval = 0
    var superJumpActive: Bool = false
    var superJumpEndTime: TimeInterval = 0
    var superJumpsRemaining: Int = 0

    var bottom: CGFloat { y - height / 2 }
    var right: CGFloat { x + width / 2 }
    var isInvincible: Bool { invincibilityFrames > 0 }
    var hasPowerUp: Bool { jetpackActive || superJumpActive }
}
