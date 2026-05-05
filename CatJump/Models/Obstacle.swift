import CoreGraphics
import Foundation

enum ObstacleType {
    case cactus, bird, bat, mouse, dog
}

struct Obstacle {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat = 70
    var height: CGFloat = 70
    var type: ObstacleType = .bird
    var velocityX: CGFloat = 0
    var velocityY: CGFloat = 0
    var platformMinX: CGFloat = 0
    var platformMaxX: CGFloat = .infinity
}
