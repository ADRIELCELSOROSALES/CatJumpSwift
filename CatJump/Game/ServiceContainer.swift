import Foundation

struct ServiceContainer {

    let scoreStore        = ScoreStore()
    let difficultyManager = DifficultyManager()
    let collisionHandler  = CollisionHandler()

    lazy var platformGenerator = PlatformGenerator(difficultyManager: difficultyManager)

    lazy var gameEngine = GameEngine(
        platformGenerator: platformGenerator,
        collisionHandler:  collisionHandler,
        difficultyManager: difficultyManager
    )
}
