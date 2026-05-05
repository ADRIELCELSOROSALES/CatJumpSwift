import SpriteKit

class PowerUpNode: SKNode {

    private var height: CGFloat = 0

    func spriteKitY(_ gameY: CGFloat, screenHeight: CGFloat) -> CGFloat {
        screenHeight - gameY - height
    }

    // MARK: - Configure

    func configure(type: PowerUpType) {
        removeAllChildren()
        height = 0

        buildBubble()

        switch type {
        case .jetpack: buildJetpack()
        case .kibble:  buildKibble()
        }

        startFloatAnimation()
    }

    // MARK: - Update

    func update(powerUp: PowerUp, cameraOffset: CGFloat, screenHeight: CGFloat) {
        let relativeY = powerUp.y - cameraOffset
        position = CGPoint(
            x: powerUp.x,
            y: spriteKitY(relativeY, screenHeight: screenHeight)
        )
    }

    // MARK: - Bubble

    private func buildBubble() {
        let bubble = SKShapeNode(circleOfRadius: 32)
        bubble.fillColor   = SKColor(red: 0xAD/255.0, green: 0xD8/255.0, blue: 0xE6/255.0, alpha: 0.5)
        bubble.strokeColor = SKColor(red: 0xAD/255.0, green: 0xD8/255.0, blue: 0xE6/255.0, alpha: 0.8)
        bubble.lineWidth   = 1.5
        bubble.zPosition   = -1
        addChild(bubble)

        // Shine in top-left
        let shine = SKShapeNode(ellipseIn: CGRect(x: -22, y: 14, width: 12, height: 8))
        shine.fillColor   = SKColor.white.withAlphaComponent(0.65)
        shine.strokeColor = .clear
        shine.zRotation   = -0.5
        addChild(shine)
    }

    // MARK: - Jetpack

    private func buildJetpack() {
        // Central tank
        let tank = rectNode(CGRect(x: -10, y: -18, width: 20, height: 36),
                            fill: 0x1565C0, radius: 5)
        addChild(tank)

        // Side tanks
        for tx: CGFloat in [-18, 18] {
            let side = rectNode(CGRect(x: tx - 6, y: -14, width: 12, height: 28),
                                fill: 0x0D47A1, radius: 4)
            addChild(side)
        }

        // Nozzles
        for tx: CGFloat in [-18, 0, 18] {
            let nozzle = rectNode(CGRect(x: tx - 4, y: -22, width: 8, height: 6),
                                  fill: 0x546E7A, radius: 1)
            addChild(nozzle)
        }

        // Flames
        for (tx, col) in [(-18, 0xFF5722 as UInt32), (0, 0xFF9800), (18, 0xFF5722)] {
            addChild(flame(at: CGFloat(tx), color: col))
        }

        // Strap detail
        let strap = rectNode(CGRect(x: -12, y: 2, width: 24, height: 5),
                             fill: 0xFFFFFF, radius: 1)
        strap.alpha = 0.3
        addChild(strap)
    }

    private func flame(at x: CGFloat, color: UInt32) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x - 4, y: -22))
        path.addLine(to: CGPoint(x: x,     y: -34))
        path.addLine(to: CGPoint(x: x + 4, y: -22))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = hex(color)
        node.strokeColor = .clear
        return node
    }

    // MARK: - Kibble

    private func buildKibble() {
        // Main kibble piece (rounded cross / star shape)
        for angle in stride(from: 0.0, to: .pi * 2, by: .pi / 3) {
            let lobe = SKShapeNode(circleOfRadius: 10)
            lobe.position    = CGPoint(x: cos(angle) * 10, y: sin(angle) * 10)
            lobe.fillColor   = hex(0x6D4C41)
            lobe.strokeColor = .clear
            addChild(lobe)
        }

        let center = SKShapeNode(circleOfRadius: 11)
        center.fillColor   = hex(0x8D6E63)
        center.strokeColor = .clear
        addChild(center)

        // Highlight
        let highlight = SKShapeNode(ellipseIn: CGRect(x: -6, y: 4, width: 10, height: 6))
        highlight.fillColor   = SKColor.white.withAlphaComponent(0.35)
        highlight.strokeColor = .clear
        addChild(highlight)

        // Stars around kibble
        for (i, angle) in [0.6, 1.6, 2.6, 3.6, 4.6, 5.6].enumerated() {
            let _ = i
            let star = starShape(radius: 4)
            star.position    = CGPoint(x: cos(CGFloat(angle)) * 26, y: sin(CGFloat(angle)) * 26)
            star.fillColor   = hex(0xFFD54F)
            star.strokeColor = .clear
            addChild(star)
        }
    }

    private func starShape(radius: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        let pts  = 5
        for i in 0..<(pts * 2) {
            let r     = i.isMultiple(of: 2) ? radius : radius * 0.45
            let angle = CGFloat(i) * .pi / CGFloat(pts) - .pi / 2
            let pt    = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return SKShapeNode(path: path)
    }

    // MARK: - Float animation

    private func startFloatAnimation() {
        let up   = SKAction.moveBy(x: 0, y: 6, duration: 0.55)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        run(SKAction.repeatForever(SKAction.sequence([up, down])))
    }

    // MARK: - Helpers

    private func rectNode(_ frame: CGRect, fill: UInt32, radius: CGFloat = 0) -> SKShapeNode {
        let node = SKShapeNode(rect: frame, cornerRadius: radius)
        node.fillColor   = hex(fill)
        node.strokeColor = .clear
        return node
    }

    private func hex(_ value: UInt32) -> SKColor {
        SKColor(
            red:   CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8)  & 0xFF) / 255,
            blue:  CGFloat( value        & 0xFF) / 255,
            alpha: 1
        )
    }
}
