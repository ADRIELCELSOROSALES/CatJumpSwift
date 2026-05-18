import CoreGraphics
import Foundation

class GameEngine {

    private let platformGenerator: PlatformGenerator
    private let collisionHandler: CollisionHandler
    private let difficultyManager: DifficultyManager

    private var moveDirection: Int = 0
    private var platformsSinceLastDamagingObstacle: Int = 0

    init(
        platformGenerator: PlatformGenerator,
        collisionHandler: CollisionHandler,
        difficultyManager: DifficultyManager
    ) {
        self.platformGenerator = platformGenerator
        self.collisionHandler = collisionHandler
        self.difficultyManager = difficultyManager
    }

    func setMoveDirection(_ direction: Int) {
        moveDirection = direction
    }

    func initializeGame(screenWidth: CGFloat, screenHeight: CGFloat, highScore: Int) -> GameState {
        var state = GameState.initial(screenWidth: screenWidth, screenHeight: screenHeight)
        state.highScore = highScore
        platformsSinceLastDamagingObstacle = 0
        return state
    }

    func update(_ state: GameState) -> GameState {
        guard !state.isGameOver else { return state }
        var s = state

        s = step1_clearSoundEvents(s)
        s = step2_updatePowerUpTimers(s)
        s = step3_updateCatPhysics(s)
        s = step4_updatePlatforms(s)
        s = step5_updateObstacles(s)
        s = step6_checkCollisions(s)
        s = step7_updateCameraAndScore(s)
        s = step8_generateNewContent(s)
        s = step9_cleanupOffScreen(s)
        s = step10_checkGameOver(s)

        return s
    }

    // MARK: - Step 1

    private func step1_clearSoundEvents(_ state: GameState) -> GameState {
        var s = state
        s.soundEvents = []
        return s
    }

    // MARK: - Step 2

    private func step2_updatePowerUpTimers(_ state: GameState) -> GameState {
        var s = state
        if s.cat.jetpackActive && s.currentTime >= s.cat.jetpackEndTime {
            s.cat.jetpackActive = false
        }
        if s.cat.superJumpActive && s.currentTime >= s.cat.superJumpEndTime {
            s.cat.superJumpActive = false
            s.cat.superJumpsRemaining = 0
        }
        return s
    }

    // MARK: - Step 3
    // Coordinate system: y=0 at top, increases downward (Android/screen space).
    // jumpVelocity < 0 = upward, gravity > 0 = pull down, maxFallVelocity caps positive velocityY.

    private func step3_updateCatPhysics(_ state: GameState) -> GameState {
        var s = state
        var cat = s.cat

        if cat.invincibilityFrames > 0 {
            cat.invincibilityFrames -= 1
        }

        if cat.jetpackActive {
            cat.velocityY = GameConstants.jetpackBoost
        } else {
            cat.velocityY += GameConstants.gravity
            if cat.velocityY > GameConstants.maxFallVelocity {
                cat.velocityY = GameConstants.maxFallVelocity
            }
        }

        cat.velocityX = CGFloat(moveDirection) * GameConstants.horizontalSpeed
        if moveDirection > 0 { cat.facingRight = true }
        if moveDirection < 0 { cat.facingRight = false }

        cat.x += cat.velocityX
        cat.y += cat.velocityY

        // Horizontal screen wrap
        let halfW = cat.width / 2
        if cat.x + halfW < 0             { cat.x = s.screenWidth + halfW }
        if cat.x - halfW > s.screenWidth  { cat.x = -halfW }

        s.cat = cat
        return s
    }

    // MARK: - Step 4

    private func step4_updatePlatforms(_ state: GameState) -> GameState {
        var s = state
        for i in s.platforms.indices where s.platforms[i].type == .moving {
            s.platforms[i].x += s.platforms[i].velocityX
            let halfW = s.platforms[i].width / 2
            if s.platforms[i].x - halfW <= 0 {
                s.platforms[i].velocityX = abs(s.platforms[i].velocityX)
            } else if s.platforms[i].x + halfW >= s.screenWidth {
                s.platforms[i].velocityX = -abs(s.platforms[i].velocityX)
            }
        }
        return s
    }

    // MARK: - Step 5

    private func step5_updateObstacles(_ state: GameState) -> GameState {
        var s = state
        for i in s.obstacles.indices {
            var obs = s.obstacles[i]
            obs.x += obs.velocityX
            obs.y += obs.velocityY

            switch obs.type {
            case .dog:
                if obs.x <= obs.platformMinX { obs.velocityX =  abs(obs.velocityX) }
                if obs.x >= obs.platformMaxX { obs.velocityX = -abs(obs.velocityX) }
            case .mouse, .cactus:
                let half = obs.width / 2
                if obs.x - half <= 0            { obs.velocityX =  abs(obs.velocityX) }
                if obs.x + half >= s.screenWidth { obs.velocityX = -abs(obs.velocityX) }
            case .bird, .bat:
                // Fly across; wrap horizontally
                let half = obs.width / 2
                if obs.x + half < 0             { obs.x = s.screenWidth + half }
                if obs.x - half > s.screenWidth  { obs.x = -half }
            }

            s.obstacles[i] = obs
        }
        return s
    }

    // MARK: - Step 6

    private func step6_checkCollisions(_ state: GameState) -> GameState {
        var s = state

        // --- Power-ups ---
        if let pwrUp = collisionHandler.findCollidingPowerUp(cat: s.cat, powerUps: s.powerUps) {
            s.powerUps.removeAll { $0.x == pwrUp.x && $0.y == pwrUp.y }
            switch pwrUp.type {
            case .jetpack:
                s.cat.jetpackActive  = true
                s.cat.jetpackEndTime = s.currentTime + GameConstants.jetpackDuration
                s.cat.velocityY      = GameConstants.jetpackBoost
            case .kibble:
                s.cat.superJumpActive    = true
                s.cat.superJumpEndTime   = s.currentTime + GameConstants.superJumpDuration
                s.cat.superJumpsRemaining = GameConstants.superJumpCount
            }
            s.soundEvents.append(.powerUp)
        }

        // --- Damaging obstacles (dog, cactus, bat) ---
        if let harmful = collisionHandler.findDamagingObstacle(cat: s.cat, obstacles: s.obstacles) {
            s.cat.lives -= 1
            s.cat.invincibilityFrames = GameConstants.invincibilityFrames
            s.soundEvents.append(.loseLife)
            if harmful.type == .dog { s.soundEvents.append(.dogAppeared) }
            if s.cat.lives <= 0 {
                s.isGameOver = true
                s.soundEvents.append(.gameOver)
                return s
            }
        }

        // --- Edible obstacles (bird, mouse): fatness + life every 5 ---
        if let edible = collisionHandler.findEdibleObstacle(cat: s.cat, obstacles: s.obstacles) {
            s.obstacles.removeAll { $0.x == edible.x && $0.y == edible.y }
            s.cat.birdsEaten += 1
            s.cat.fatness = min(
                s.cat.fatness + GameConstants.fatnessGainPerBird,
                GameConstants.maxFatness
            )
            if s.cat.birdsEaten % 5 == 0 {
                s.cat.lives += 1
            }
        }

        // --- Platforms ---
        if let platform = collisionHandler.findCollidingPlatform(cat: s.cat, platforms: s.platforms) {
            // Snap feet to platform surface so the cat never visually sinks into the platform
            s.cat.y = platform.y - 20

            let jumpVel: CGFloat
            if s.cat.superJumpActive && s.cat.superJumpsRemaining > 0 {
                jumpVel = GameConstants.superJumpVelocity
                s.cat.superJumpsRemaining -= 1
            } else if platform.type == .spring {
                jumpVel = GameConstants.springJumpVelocity
            } else {
                jumpVel = GameConstants.jumpVelocity
            }
            s.cat.velocityY  = jumpVel
            s.cat.isJumping  = true
            s.soundEvents.append(.jump)

            if platform.type == .fragile,
               let idx = s.platforms.firstIndex(where: { $0.x == platform.x && $0.y == platform.y }) {
                s.platforms[idx].isActive = false
            }
        }

        return s
    }

    // MARK: - Step 7
    // cameraY = world-space Y of the top of the viewport (y-downward system).
    // Camera only follows cat upward (cameraY only decreases).

    private func step7_updateCameraAndScore(_ state: GameState) -> GameState {
        var s = state

        let targetCameraY = s.cat.y - s.screenHeight * 0.4
        if targetCameraY < s.cameraY {
            s.cameraY = targetCameraY
        }

        // Score proportional to camera height (-cameraY grows as cat goes higher)
        let heightScore = max(0, Int(-s.cameraY / 3))
        if heightScore > s.score {
            s.score = heightScore
        }
        if s.score > s.highScore {
            s.highScore = s.score
            s.isNewHighScore = true
        }

        s.level = difficultyManager.calculateLevel(score: s.score)
        return s
    }

    // MARK: - Step 8
    // Generate content when the uppermost platform is more than 80 % of screen height
    // away from the camera top (i.e., the top area of the view is empty).

    private func step8_generateNewContent(_ state: GameState) -> GameState {
        var s = state

        // Fill platforms until they extend at least 0.5 screens above the camera top.
        // This prevents the "platforms popping in" UX issue during fast upward movement.
        let fillTarget = s.cameraY - s.screenHeight * 0.5
        var safety = 0

        while safety < 15,
              let topPlatform = s.platforms.min(by: { $0.y < $1.y }),
              topPlatform.y > fillTarget {

            safety += 1

            let minGap = difficultyManager.getMinPlatformGap(level: s.level)
            let maxGap = difficultyManager.getMaxPlatformGap(level: s.level)
            let gap = CGFloat.random(in: minGap...maxGap)

            let newPlatform = platformGenerator.generateNewPlatform(
                screenWidth: s.screenWidth,
                highestPlatformY: topPlatform.y - gap,
                level: s.level,
                lastPlatformX: topPlatform.x
            )
            s.platforms.append(newPlatform)
            platformsSinceLastDamagingObstacle += 1

            // No obstacles or power-ups on fragile / spring platforms
            guard newPlatform.type == .normal || newPlatform.type == .moving else { continue }

            if let powerUp = platformGenerator.generatePowerUpOnPlatform(newPlatform) {
                s.powerUps.append(powerUp)
                continue
            }

            let canSpawnDamaging = platformsSinceLastDamagingObstacle > GameConstants.minDamagingObstacleGap

            if canSpawnDamaging {
                if let dog = platformGenerator.generateDogOnPlatform(newPlatform) {
                    s.obstacles.append(dog)
                    s.activeDogCount += 1
                    s.soundEvents.append(.dogAppeared)
                    platformsSinceLastDamagingObstacle = 0
                } else if let cactus = platformGenerator.generateCactusOnPlatform(newPlatform) {
                    s.obstacles.append(cactus)
                    platformsSinceLastDamagingObstacle = 0
                } else if let mouse = platformGenerator.generateMouseOnPlatform(newPlatform) {
                    s.obstacles.append(mouse)
                }
            } else if let mouse = platformGenerator.generateMouseOnPlatform(newPlatform) {
                s.obstacles.append(mouse)
            }
        }

        return s
    }

    // MARK: - Step 9

    private func step9_cleanupOffScreen(_ state: GameState) -> GameState {
        var s = state
        let cutoff = s.cameraY + s.screenHeight * 1.2
        s.platforms = s.platforms.filter { $0.y < cutoff }
        s.obstacles = s.obstacles.filter { $0.y < cutoff }
        s.powerUps  = s.powerUps.filter  { $0.y < cutoff }
        s.activeDogCount = s.obstacles.filter { $0.type == .dog }.count
        return s
    }

    // MARK: - Step 10

    private func step10_checkGameOver(_ state: GameState) -> GameState {
        var s = state
        guard !s.isGameOver else { return s }
        if s.cat.y > s.cameraY + s.screenHeight + 100 {
            s.isGameOver = true
            if !s.soundEvents.contains(.gameOver) {
                s.soundEvents.append(.gameOver)
            }
        }
        return s
    }
}
