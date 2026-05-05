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
        let cat = Cat(x: screenWidth / 2, y: screenHeight * 0.3)

        var platforms: [Platform] = []
        platforms.append(Platform(x: screenWidth / 2, y: 80, width: screenWidth * 0.8))
        platforms.append(Platform(x: screenWidth / 2, y: screenHeight * 0.3 - 90))

        let spacing = screenHeight / 6
        for i in 1...5 {
            let px = CGFloat.random(in: 80...(screenWidth - 80))
            let py = screenHeight * 0.3 + CGFloat(i) * spacing
            platforms.append(Platform(x: px, y: py))
        }

        return GameState(
            cat: cat,
            platforms: platforms,
            screenWidth: screenWidth,
            screenHeight: screenHeight
        )
    }
}
