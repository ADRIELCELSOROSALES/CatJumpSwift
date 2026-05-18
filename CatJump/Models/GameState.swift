import CoreGraphics
import Foundation

struct GameState {
    var cat: Cat
    var platforms: [Platform]
    var obstacles: [Obstacle] = []
    var powerUps: [PowerUp] = []
    var score: Int = 0
    var highScore: Int = 0
    var level: Int = 1
    var isGameOver: Bool = false
    var isNewHighScore: Bool = false
    var cameraY: CGFloat = 0.0
    var screenWidth: CGFloat
    var screenHeight: CGFloat
    var currentTime: TimeInterval = 0
    var soundEvents: [SoundEvent] = []
    var activeDogCount: Int = 0

    static func initial(screenWidth: CGFloat, screenHeight: CGFloat) -> GameState {
        // Cat starts in lower portion; velocity already set to jump so it bounces immediately.
        let catY = screenHeight * 0.72
        var cat = Cat(x: screenWidth / 2, y: catY)
        cat.velocityY = GameConstants.jumpVelocity

        var platforms: [Platform] = []
        let margin = GameConstants.platformWidth / 2 + 12

        // platform.y = top edge; cat body bottom is 30 pts below cat.y (from CatNode local y=-30)
        // Collision triggers when catFeetY (cat.y + 30) reaches platform.y, so:
        // startPlatY = catY + 30  →  cat appears standing on the platform at launch
        let startPlatY = catY + 30
        platforms.append(Platform(x: screenWidth / 2, y: startPlatY))

        // Pre-generate platforms upward (decreasing Y) to cover 2.5 screens above the cat.
        // step8 will top this up proactively during gameplay so no "pop-in" occurs.
        var y = startPlatY - CGFloat.random(in: GameConstants.minPlatformGap...GameConstants.maxPlatformGap)
        let topLimit = catY - screenHeight * 2.5
        while y > topLimit {
            let px = CGFloat.random(in: margin...(screenWidth - margin))
            platforms.append(Platform(x: px, y: y))
            y -= CGFloat.random(in: GameConstants.minPlatformGap...GameConstants.maxPlatformGap)
        }

        return GameState(
            cat: cat,
            platforms: platforms,
            screenWidth: screenWidth,
            screenHeight: screenHeight
        )
    }
}
