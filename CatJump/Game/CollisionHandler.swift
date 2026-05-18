import CoreGraphics

class CollisionHandler {

    private let catMargin: CGFloat      = 8
    private let obstacleMargin: CGFloat = 5
    private let powerUpMargin: CGFloat  = 5

    // MARK: - Platform

    func checkPlatformCollision(cat: Cat, platform: Platform) -> Bool {
        guard platform.isActive else { return false }

        let catLeft  = cat.x - cat.width  / 2 + catMargin
        let catRight = cat.x + cat.width  / 2 - catMargin

        // Body bottom is at local y = -30 in CatNode; scaled by catDisplayScale (0.65) → 20 pts below center
        let catFeetY = cat.y + 20

        let platLeft  = platform.x - platform.width  / 2
        let platRight = platform.x + platform.width  / 2
        // platform.y is the visual TOP edge of the platform
        let platTopY  = platform.y

        let overlapX = catRight > platLeft && catLeft < platRight
        // Cat must be falling and its feet just reached the platform's top surface this frame
        let overlapY = cat.velocityY > 0
            && catFeetY >= platTopY
            && catFeetY <= platTopY + cat.velocityY + 1

        return overlapX && overlapY
    }

    func findCollidingPlatform(cat: Cat, platforms: [Platform]) -> Platform? {
        platforms.first { checkPlatformCollision(cat: cat, platform: $0) }
    }

    // MARK: - Obstacles

    func checkObstacleCollision(cat: Cat, obstacle: Obstacle) -> Bool {
        let m = catMargin + obstacleMargin
        return abs(cat.x - obstacle.x) < (cat.width  + obstacle.width)  / 2 - m
            && abs(cat.y - obstacle.y) < (cat.height + obstacle.height) / 2 - m
    }

    func findDamagingObstacle(cat: Cat, obstacles: [Obstacle]) -> Obstacle? {
        guard !cat.isInvincible else { return nil }
        return obstacles.first { obs in
            obs.type != .mouse && obs.type != .bird && checkObstacleCollision(cat: cat, obstacle: obs)
        }
    }

    func findEdibleObstacle(cat: Cat, obstacles: [Obstacle]) -> Obstacle? {
        obstacles.first { obs in
            (obs.type == .mouse || obs.type == .bird) && checkObstacleCollision(cat: cat, obstacle: obs)
        }
    }

    // MARK: - Power-ups

    func checkPowerUpCollision(cat: Cat, powerUp: PowerUp) -> Bool {
        let m = catMargin + powerUpMargin
        return abs(cat.x - powerUp.x) < (cat.width  + powerUp.width)  / 2 - m
            && abs(cat.y - powerUp.y) < (cat.height + powerUp.height) / 2 - m
    }

    func findCollidingPowerUp(cat: Cat, powerUps: [PowerUp]) -> PowerUp? {
        powerUps.first { checkPowerUpCollision(cat: cat, powerUp: $0) }
    }
}
