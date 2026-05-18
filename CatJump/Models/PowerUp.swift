import CoreGraphics
import Foundation

enum PowerUpType {
    case jetpack, kibble
}

struct PowerUp {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat = GameConstants.powerUpSize
    var height: CGFloat = GameConstants.powerUpSize
    var type: PowerUpType
}
