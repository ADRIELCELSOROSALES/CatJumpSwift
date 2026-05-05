import SpriteKit

class ObstacleNode: SKNode {

    private var height: CGFloat = 0

    func spriteKitY(_ gameY: CGFloat, screenHeight: CGFloat) -> CGFloat {
        screenHeight - gameY - height
    }

    // MARK: - Configure

    func configure(type: ObstacleType) {
        removeAllChildren()
        height = 0
        switch type {
        case .cactus: buildCactus()
        case .bird:   buildBird()
        case .bat:    buildBat()
        case .mouse:  buildMouse()
        case .dog:    buildDog()
        }
    }

    // MARK: - Update

    func update(obstacle: Obstacle, cameraOffset: CGFloat, screenHeight: CGFloat) {
        let relativeY = obstacle.y - cameraOffset
        position = CGPoint(
            x: obstacle.x,
            y: spriteKitY(relativeY, screenHeight: screenHeight)
        )
        if obstacle.velocityX != 0 {
            xScale = obstacle.velocityX > 0 ? 1 : -1
        }
    }

    // MARK: - Cactus

    private func buildCactus() {
        // Trunk
        let trunk = rect(CGRect(x: -8, y: -35, width: 16, height: 70), fill: 0x2E7D32, radius: 3)
        addChild(trunk)

        // Left arm: horizontal + vertical end
        let leftH = rect(CGRect(x: -28, y: -4, width: 22, height: 8), fill: 0x2E7D32, radius: 2)
        addChild(leftH)
        let leftV = rect(CGRect(x: -30, y: -4, width: 9, height: 18), fill: 0x2E7D32, radius: 2)
        addChild(leftV)

        // Right arm: horizontal + vertical end (slightly higher)
        let rightH = rect(CGRect(x: 6, y: 4, width: 22, height: 8), fill: 0x2E7D32, radius: 2)
        addChild(rightH)
        let rightV = rect(CGRect(x: 21, y: 4, width: 9, height: 18), fill: 0x2E7D32, radius: 2)
        addChild(rightV)

        // Spines — small yellow triangles along trunk and arm tips
        for spine in spinePositions() {
            addChild(spine)
        }
    }

    private func spinePositions() -> [SKShapeNode] {
        var spines: [SKShapeNode] = []
        // Trunk sides
        for y: CGFloat in [-24, -8, 8, 24] {
            spines.append(spine(at: CGPoint(x: -12, y: y), angle: .pi))
            spines.append(spine(at: CGPoint(x:  12, y: y), angle: 0))
        }
        // Left arm tip
        spines.append(spine(at: CGPoint(x: -34, y: 5),  angle: -.pi/2))
        spines.append(spine(at: CGPoint(x: -34, y: 14), angle: -.pi/2))
        // Right arm tip
        spines.append(spine(at: CGPoint(x: 34, y: 9),  angle: .pi/2))
        spines.append(spine(at: CGPoint(x: 34, y: 18), angle: .pi/2))
        return spines
    }

    private func spine(at pos: CGPoint, angle: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x:  4, y:  2))
        path.addLine(to: CGPoint(x:  4, y: -2))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = hex(0xFFB300)
        node.strokeColor = .clear
        node.position    = pos
        node.zRotation   = angle
        return node
    }

    // MARK: - Bird

    private func buildBird() {
        // Wing (behind body)
        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: 0, y: 0))
        wingPath.addLine(to: CGPoint(x: -26, y: 12))
        wingPath.addLine(to: CGPoint(x: -24, y: -6))
        wingPath.closeSubpath()
        let wing = SKShapeNode(path: wingPath)
        wing.fillColor   = hex(0xB71C1C)
        wing.strokeColor = .clear
        wing.zPosition   = -1
        addChild(wing)

        // Body
        let body = SKShapeNode(ellipseIn: CGRect(x: -18, y: -12, width: 36, height: 26))
        body.fillColor   = hex(0xE53935)
        body.strokeColor = .clear
        addChild(body)

        // Beak
        let beakPath = CGMutablePath()
        beakPath.move(to: CGPoint(x: 16, y: 4))
        beakPath.addLine(to: CGPoint(x: 28, y: 1))
        beakPath.addLine(to: CGPoint(x: 16, y: -4))
        beakPath.closeSubpath()
        let beak = SKShapeNode(path: beakPath)
        beak.fillColor   = hex(0xFFB300)
        beak.strokeColor = .clear
        addChild(beak)

        // Eye
        let eye = SKShapeNode(circleOfRadius: 5)
        eye.position    = CGPoint(x: 10, y: 6)
        eye.fillColor   = .white
        eye.strokeColor = .clear
        addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: 2.5)
        pupil.position    = CGPoint(x: 11, y: 6)
        pupil.fillColor   = .black
        pupil.strokeColor = .clear
        addChild(pupil)
    }

    // MARK: - Bat

    private func buildBat() {
        // Left wing
        addChild(batWing(side: -1))
        // Right wing
        addChild(batWing(side:  1))

        // Body
        let body = SKShapeNode(ellipseIn: CGRect(x: -10, y: -14, width: 20, height: 26))
        body.fillColor   = hex(0x37474F)
        body.strokeColor = .clear
        addChild(body)

        // Ears
        addChild(batEar(side: -1))
        addChild(batEar(side:  1))

        // Eyes
        for ex: CGFloat in [-4, 4] {
            let eye = SKShapeNode(circleOfRadius: 3)
            eye.position    = CGPoint(x: ex, y: 6)
            eye.fillColor   = hex(0xEF5350)
            eye.strokeColor = .clear
            addChild(eye)
        }
    }

    private func batWing(side: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: side * 8,  y: 0))
        path.addCurve(to:       CGPoint(x: side * 32, y: -8),
                      control1: CGPoint(x: side * 20, y: 16),
                      control2: CGPoint(x: side * 30, y: 10))
        path.addCurve(to:       CGPoint(x: side * 10, y: -10),
                      control1: CGPoint(x: side * 28, y: -20),
                      control2: CGPoint(x: side * 18, y: -16))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = hex(0x37474F)
        node.strokeColor = hex(0x263238)
        node.lineWidth   = 0.5
        return node
    }

    private func batEar(side: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: side * 4,  y: 10))
        path.addLine(to: CGPoint(x: side * 10, y: 22))
        path.addLine(to: CGPoint(x: side * 2,  y: 16))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = hex(0x37474F)
        node.strokeColor = .clear
        return node
    }

    // MARK: - Mouse

    private func buildMouse() {
        // Tail (behind body)
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: -18, y: -10))
        tailPath.addCurve(to:       CGPoint(x: -42, y:  10),
                          control1: CGPoint(x: -30, y: -22),
                          control2: CGPoint(x: -48, y: -2))
        let tail = SKShapeNode(path: tailPath)
        tail.strokeColor = hex(0x9E9E9E)
        tail.lineWidth   = 3
        tail.lineCap     = .round
        tail.fillColor   = .clear
        tail.zPosition   = -1
        addChild(tail)

        // Body
        let body = SKShapeNode(ellipseIn: CGRect(x: -18, y: -18, width: 36, height: 30))
        body.fillColor   = hex(0x9E9E9E)
        body.strokeColor = .clear
        addChild(body)

        // Ears (outer)
        for ex: CGFloat in [-14, 14] {
            let ear = SKShapeNode(circleOfRadius: 10)
            ear.position    = CGPoint(x: ex, y: 16)
            ear.fillColor   = hex(0x9E9E9E)
            ear.strokeColor = .clear
            addChild(ear)
        }

        // Ears (inner pink)
        for ex: CGFloat in [-14, 14] {
            let inner = SKShapeNode(circleOfRadius: 6)
            inner.position    = CGPoint(x: ex, y: 16)
            inner.fillColor   = SKColor(red: 1.0, green: 0.72, blue: 0.75, alpha: 0.85)
            inner.strokeColor = .clear
            addChild(inner)
        }

        // Head
        let head = SKShapeNode(circleOfRadius: 16)
        head.position    = CGPoint(x: 0, y: 6)
        head.fillColor   = hex(0x9E9E9E)
        head.strokeColor = .clear
        addChild(head)

        // Nose
        let nose = SKShapeNode(ellipseIn: CGRect(x: -3, y: 12, width: 6, height: 5))
        nose.fillColor   = SKColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1)
        nose.strokeColor = .clear
        addChild(nose)

        // Whiskers
        for (from, to) in mouseWhiskers() {
            let w = line(from: from, to: to)
            addChild(w)
        }
    }

    private func mouseWhiskers() -> [(CGPoint, CGPoint)] {
        [
            (CGPoint(x: -4, y: 12), CGPoint(x: -26, y: 14)),
            (CGPoint(x: -4, y: 11), CGPoint(x: -26, y:  8)),
            (CGPoint(x:  4, y: 12), CGPoint(x:  26, y: 14)),
            (CGPoint(x:  4, y: 11), CGPoint(x:  26, y:  8)),
        ]
    }

    // MARK: - Dog

    private func buildDog() {
        // Tail
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: 24, y: 0))
        tailPath.addCurve(to:       CGPoint(x: 38, y: 24),
                          control1: CGPoint(x: 38, y: -8),
                          control2: CGPoint(x: 44, y: 14))
        let tail = SKShapeNode(path: tailPath)
        tail.strokeColor = hex(0x8B4513)
        tail.lineWidth   = 7
        tail.lineCap     = .round
        tail.fillColor   = .clear
        tail.zPosition   = -1
        addChild(tail)

        // Body
        let body = SKShapeNode(ellipseIn: CGRect(x: -22, y: -18, width: 44, height: 32))
        body.fillColor   = hex(0x8B4513)
        body.strokeColor = .clear
        addChild(body)

        // Collar
        let collar = rect(CGRect(x: -18, y: 8, width: 36, height: 8), fill: 0xE53935, radius: 2)
        addChild(collar)

        // Head
        let head = SKShapeNode(circleOfRadius: 20)
        head.position    = CGPoint(x: 0, y: 24)
        head.fillColor   = hex(0x8B4513)
        head.strokeColor = .clear
        addChild(head)

        // Floppy ears
        addChild(dogEar(side: -1))
        addChild(dogEar(side:  1))

        // Eyes (white + pupil)
        for ex: CGFloat in [-8, 8] {
            let eye = SKShapeNode(circleOfRadius: 6)
            eye.position    = CGPoint(x: ex, y: 28)
            eye.fillColor   = .white
            eye.strokeColor = .clear
            addChild(eye)

            let pupil = SKShapeNode(circleOfRadius: 3.5)
            pupil.position    = CGPoint(x: ex + 1, y: 28)
            pupil.fillColor   = .black
            pupil.strokeColor = .clear
            addChild(pupil)
        }

        // Angry eyebrows
        for ex: CGFloat in [-8, 8] {
            let brow = line(
                from: CGPoint(x: ex - 5 * (ex < 0 ? -1 : 1), y: 36),
                to:   CGPoint(x: ex + 5 * (ex < 0 ? -1 : 1), y: 34)
            )
            brow.strokeColor = hex(0x4E342E)
            brow.lineWidth   = 2
            addChild(brow)
        }

        // Snout
        let snout = SKShapeNode(ellipseIn: CGRect(x: -10, y: 14, width: 20, height: 12))
        snout.fillColor   = hex(0xA0522D)
        snout.strokeColor = .clear
        addChild(snout)

        // Teeth
        for tx: CGFloat in [-5, 5] {
            let tooth = rect(CGRect(x: tx - 3, y: 12, width: 6, height: 6), fill: 0xFFFFFF, radius: 1)
            addChild(tooth)
        }

        // Tongue
        let tongue = SKShapeNode(ellipseIn: CGRect(x: -6, y: 6, width: 12, height: 10))
        tongue.fillColor   = SKColor(red: 1.0, green: 0.45, blue: 0.55, alpha: 1)
        tongue.strokeColor = .clear
        addChild(tongue)
    }

    private func dogEar(side: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: side * 14, y: 36))
        path.addCurve(to:       CGPoint(x: side * 24,  y: 14),
                      control1: CGPoint(x: side * 28,  y: 36),
                      control2: CGPoint(x: side * 28,  y: 20))
        path.addLine(to: CGPoint(x: side * 12, y: 22))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = hex(0x6D3B0A)
        node.strokeColor = .clear
        return node
    }

    // MARK: - Shared helpers

    private func rect(_ frame: CGRect, fill: UInt32, radius: CGFloat = 0) -> SKShapeNode {
        let node = SKShapeNode(rect: frame, cornerRadius: radius)
        node.fillColor   = hex(fill)
        node.strokeColor = .clear
        return node
    }

    private func line(from: CGPoint, to: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let node = SKShapeNode(path: path)
        node.strokeColor = SKColor.white.withAlphaComponent(0.8)
        node.lineWidth   = 1.2
        node.lineCap     = .round
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
