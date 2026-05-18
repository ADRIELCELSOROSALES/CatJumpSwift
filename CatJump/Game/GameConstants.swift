import CoreGraphics

enum GameConstants {
    static let gravity: CGFloat               = 0.5
    static let jumpVelocity: CGFloat          = -22
    static let springJumpVelocity: CGFloat    = -30
    static let horizontalSpeed: CGFloat       = 12
    static let maxFallVelocity: CGFloat       = 18

    static let catSize: CGFloat               = 120
    static let catDisplayScale: CGFloat       = 0.65
    static let fatnessGainPerBird: CGFloat    = 0.1
    static let maxFatness: CGFloat            = 1.0

    static let mouseSize: CGFloat             = 35
    static let mouseSpawnChance: Double       = 0.15
    static let dogSize: CGFloat               = 60
    static let dogSpawnChance: Double         = 0.18
    static let dogWalkSpeed: CGFloat          = 1.5
    static let cactusSize: CGFloat            = 44
    static let cactusSpawnChance: Double      = 0.12

    static let minDamagingObstacleGap: Int    = 3
    static let initialLives: Int              = 3
    static let invincibilityFrames: Int       = 60

    static let obstacleSize: CGFloat          = 70
    static let powerUpSize: CGFloat           = 50
    static let powerUpSpawnChance: Double     = 0.08

    static let jetpackBoost: CGFloat          = -40.0
    static let jetpackDuration: Double        = 2.5

    static let superJumpVelocity: CGFloat     = -35
    static let superJumpCount: Int            = 3
    static let superJumpDuration: Double      = 8.0

    static let pointsPerLevel: Int            = 1000
    static let movingPlatformSpeed: CGFloat   = 2.5
    static let obstacleSpeed: CGFloat         = 4.0

    static let minPlatformGap: CGFloat        = 100
    static let maxPlatformGap: CGFloat        = 160
    static let platformWidth: CGFloat         = 140
    static let platformHeight: CGFloat        = 22
}
