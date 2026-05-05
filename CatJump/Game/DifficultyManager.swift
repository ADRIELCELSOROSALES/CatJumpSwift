import CoreGraphics

class DifficultyManager {

    func calculateLevel(score: Int) -> Int {
        score / GameConstants.pointsPerLevel + 1
    }

    func getMaxPlatformGap(level: Int) -> CGFloat {
        let extra = CGFloat(min(level - 1, 10)) * 6.0
        return GameConstants.maxPlatformGap + extra
    }

    func getMinPlatformGap(level: Int) -> CGFloat {
        let extra = CGFloat(min(level - 1, 10)) * 3.0
        return GameConstants.minPlatformGap + extra
    }

    func selectPlatformType(level: Int) -> PlatformType {
        let roll = Double.random(in: 0..<1)
        switch level {
        case 1...2:
            return .normal
        case 3...4:
            return roll < 0.20 ? .moving : .normal
        case 5...6:
            if roll < 0.15 { return .fragile }
            if roll < 0.40 { return .moving }
            return .normal
        case 7...8:
            if roll < 0.10 { return .spring }
            if roll < 0.25 { return .fragile }
            if roll < 0.50 { return .moving }
            return .normal
        default:
            if roll < 0.12 { return .spring }
            if roll < 0.28 { return .fragile }
            if roll < 0.55 { return .moving }
            return .normal
        }
    }

    func shouldSpawnObstacle(level: Int) -> Bool {
        let chance: Double
        switch level {
        case 1:      chance = 0.00
        case 2:      chance = 0.10
        case 3:      chance = 0.18
        case 4:      chance = 0.25
        case 5...6:  chance = 0.32
        case 7...8:  chance = 0.40
        default:     chance = 0.50
        }
        return Double.random(in: 0..<1) < chance
    }

    func getMovingPlatformSpeed(level: Int) -> CGFloat {
        let extra = CGFloat(min(level - 1, 8)) * 0.25
        return GameConstants.movingPlatformSpeed + extra
    }
}
