import CoreGraphics

class PlatformGenerator {

    private let difficulty: DifficultyManager

    init(difficultyManager: DifficultyManager = DifficultyManager()) {
        self.difficulty = difficultyManager
    }

    // MARK: - Platform generation

    func generateInitialPlatforms(screenWidth: CGFloat, screenHeight: CGFloat) -> [Platform] {
        var platforms: [Platform] = []

        // Ground-level starter platform always centered
        let ground = Platform(x: screenWidth / 2, y: screenHeight * 0.15,
                              width: GameConstants.platformWidth)
        platforms.append(ground)

        var highestY = ground.y
        var lastX = ground.x

        while highestY < screenHeight * 1.5 {
            let gap = CGFloat.random(
                in: GameConstants.minPlatformGap...GameConstants.maxPlatformGap
            )
            highestY += gap
            let newPlatform = generateNewPlatform(
                screenWidth: screenWidth,
                highestPlatformY: highestY,
                level: 1,
                lastPlatformX: lastX
            )
            platforms.append(newPlatform)
            lastX = newPlatform.x
        }
        return platforms
    }

    func generateNewPlatform(
        screenWidth: CGFloat,
        highestPlatformY: CGFloat,
        level: Int,
        lastPlatformX: CGFloat
    ) -> Platform {
        let type = difficulty.selectPlatformType(level: level)
        let speed = type == .moving ? difficulty.getMovingPlatformSpeed(level: level) : 0
        let x = generateReachableX(
            screenWidth: screenWidth,
            lastX: lastPlatformX,
            platformWidth: GameConstants.platformWidth
        )
        return Platform(x: x, y: highestPlatformY, type: type, velocityX: speed)
    }

    // MARK: - Obstacle generation

    func generateObstacle(
        screenWidth: CGFloat,
        y: CGFloat,
        level: Int
    ) -> Obstacle? {
        guard difficulty.shouldSpawnObstacle(level: level) else { return nil }

        let roll = Double.random(in: 0..<1)
        let dogChance    = min(GameConstants.dogSpawnChance    * Double(level) * 0.5, 0.35)
        let mouseChance  = GameConstants.mouseSpawnChance
        let cactusChance = GameConstants.cactusSpawnChance

        let x = CGFloat.random(in: GameConstants.obstacleSize / 2...(screenWidth - GameConstants.obstacleSize / 2))

        if roll < dogChance {
            return Obstacle(x: x, y: y, width: GameConstants.dogSize, height: GameConstants.dogSize,
                            type: .dog, velocityX: GameConstants.dogWalkSpeed,
                            platformMinX: 0, platformMaxX: screenWidth)
        } else if roll < dogChance + mouseChance {
            return Obstacle(x: x, y: y, width: GameConstants.mouseSize, height: GameConstants.mouseSize,
                            type: .mouse, velocityX: GameConstants.obstacleSpeed)
        } else if roll < dogChance + mouseChance + cactusChance {
            return Obstacle(x: x, y: y, width: GameConstants.cactusSize, height: GameConstants.cactusSize,
                            type: .cactus)
        } else {
            let isBat = Bool.random()
            return Obstacle(x: x, y: y, type: isBat ? .bat : .bird,
                            velocityX: GameConstants.obstacleSpeed * (Bool.random() ? 1 : -1))
        }
    }

    func generateMouseOnPlatform(_ platform: Platform) -> Obstacle? {
        guard Double.random(in: 0..<1) < GameConstants.mouseSpawnChance else { return nil }
        return Obstacle(
            x: platform.x, y: platform.y + platform.height / 2 + GameConstants.mouseSize / 2,
            width: GameConstants.mouseSize, height: GameConstants.mouseSize,
            type: .mouse, velocityX: GameConstants.obstacleSpeed,
            platformMinX: platform.x - platform.width / 2,
            platformMaxX: platform.x + platform.width / 2
        )
    }

    func generateCactusOnPlatform(_ platform: Platform) -> Obstacle? {
        guard Double.random(in: 0..<1) < GameConstants.cactusSpawnChance else { return nil }
        return Obstacle(
            x: platform.x, y: platform.y + platform.height / 2 + GameConstants.cactusSize / 2,
            width: GameConstants.cactusSize, height: GameConstants.cactusSize,
            type: .cactus
        )
    }

    func generateDogOnPlatform(_ platform: Platform) -> Obstacle? {
        guard Double.random(in: 0..<1) < GameConstants.dogSpawnChance else { return nil }
        return Obstacle(
            x: platform.x, y: platform.y + platform.height / 2 + GameConstants.dogSize / 2,
            width: GameConstants.dogSize, height: GameConstants.dogSize,
            type: .dog, velocityX: GameConstants.dogWalkSpeed,
            platformMinX: platform.x - platform.width / 2,
            platformMaxX: platform.x + platform.width / 2
        )
    }

    func generatePowerUpOnPlatform(_ platform: Platform) -> PowerUp? {
        guard Double.random(in: 0..<1) < GameConstants.powerUpSpawnChance else { return nil }
        let type: PowerUpType = Double.random(in: 0..<1) < 0.5 ? .jetpack : .kibble
        return PowerUp(
            x: platform.x,
            y: platform.y + platform.height / 2 + GameConstants.powerUpSize / 2,
            type: type
        )
    }

    // MARK: - Cleanup

    func cleanupPlatforms(_ platforms: [Platform], cameraY: CGFloat, screenHeight: CGFloat) -> [Platform] {
        platforms.filter { $0.y >= cameraY - screenHeight * 0.1 }
    }

    func cleanupObstacles(_ obstacles: [Obstacle], cameraY: CGFloat, screenHeight: CGFloat) -> [Obstacle] {
        obstacles.filter { $0.y >= cameraY - screenHeight * 0.1 }
    }

    func cleanupPowerUps(_ powerUps: [PowerUp], cameraY: CGFloat, screenHeight: CGFloat) -> [PowerUp] {
        powerUps.filter { $0.y >= cameraY - screenHeight * 0.1 }
    }

    // MARK: - Private helpers

    /// Computes a reachable X for the next platform using the same jump-physics formula
    /// as the Kotlin original: maxHorizontalReach = horizontalSpeed * (2 * |jumpVelocity| / gravity)
    private func generateReachableX(screenWidth: CGFloat, lastX: CGFloat, platformWidth: CGFloat) -> CGFloat {
        let airTime = 2.0 * abs(GameConstants.jumpVelocity) / GameConstants.gravity
        let maxReach = GameConstants.horizontalSpeed * airTime * 0.6
        let half = platformWidth / 2
        let minX = max(half, lastX - maxReach)
        let maxX = min(screenWidth - half, lastX + maxReach)
        return CGFloat.random(in: minX...maxX)
    }
}
