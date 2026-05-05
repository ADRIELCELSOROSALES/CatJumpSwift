import CoreGraphics
import Foundation

enum PowerUpType {
    case jetpack, kibble
}

struct PowerUp {
    let id: UUID = UUID()
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat = 70
    var height: CGFloat = 70
    var type: PowerUpType
}
