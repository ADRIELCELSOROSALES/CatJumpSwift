import SpriteKit

class CatNode: SKNode {

    // height = 0 → shapes are centered at origin → spriteKitY gives the cat's center
    private var height: CGFloat = 0

    private var bodyShape:  SKShapeNode = SKShapeNode()
    private var headShape:  SKShapeNode = SKShapeNode()
    private var earL:       SKShapeNode = SKShapeNode()
    private var earR:       SKShapeNode = SKShapeNode()
    private var earInnerL:  SKShapeNode = SKShapeNode()
    private var earInnerR:  SKShapeNode = SKShapeNode()
    private var eyeL:       SKShapeNode = SKShapeNode()
    private var eyeR:       SKShapeNode = SKShapeNode()
    private var pupilL:     SKShapeNode = SKShapeNode()
    private var pupilR:     SKShapeNode = SKShapeNode()
    private var noseShape:  SKShapeNode = SKShapeNode()
    private var tailShape:  SKShapeNode = SKShapeNode()
    private var whiskerL1:  SKShapeNode = SKShapeNode()
    private var whiskerL2:  SKShapeNode = SKShapeNode()
    private var whiskerR1:  SKShapeNode = SKShapeNode()
    private var whiskerR2:  SKShapeNode = SKShapeNode()
    private var bellyShape: SKShapeNode = SKShapeNode()
    private var auraShape:  SKShapeNode = SKShapeNode()
    var jetpackParticles:   SKEmitterNode?
    var superJumpParticles: SKEmitterNode?

    func spriteKitY(_ gameY: CGFloat, screenHeight: CGFloat) -> CGFloat {
        screenHeight - gameY - height   // height=0 → center-based conversion
    }

    // MARK: - Configure

    func configure(skin: CatSkin) {
        removeAllChildren()
        jetpackParticles   = nil
        superJumpParticles = nil
        height = 0

        buildAura()
        buildTail(skin: skin)
        buildBody(skin: skin)
        buildBelly(skin: skin)
        buildStripes(skin: skin)
        buildEars(skin: skin)
        buildHead(skin: skin)
        buildEyes(skin: skin)
        buildNose()
        buildWhiskers()

        applyBodyScale(skin.bodyScale)
    }

    // MARK: - Update

    func update(cat: Cat, cameraOffset: CGFloat, screenHeight: CGFloat) {
        let relativeY = cat.y - cameraOffset
        position = CGPoint(
            x: cat.x,
            y: spriteKitY(relativeY, screenHeight: screenHeight)
        )

        // Horizontal flip — preserve the body scale magnitude
        let s = abs(xScale)
        xScale = cat.facingRight ? s : -s

        // Invincibility blink (skip if a power-up is active)
        if cat.invincibilityFrames > 0 && !cat.hasPowerUp {
            alpha = (cat.invincibilityFrames / 5) % 2 == 0 ? 1.0 : 0.3
        } else {
            alpha = 1.0
        }

        // Power-up aura
        if cat.jetpackActive {
            auraShape.fillColor   = SKColor.cyan.withAlphaComponent(0.18)
            auraShape.strokeColor = SKColor.cyan.withAlphaComponent(0.55)
            auraShape.lineWidth   = 4
            auraShape.isHidden    = false
        } else if cat.superJumpActive {
            auraShape.fillColor   = SKColor.yellow.withAlphaComponent(0.22)
            auraShape.strokeColor = SKColor.orange.withAlphaComponent(0.6)
            auraShape.lineWidth   = 4
            auraShape.isHidden    = false
        } else {
            auraShape.isHidden = true
        }

        // Jetpack flame particles
        if cat.jetpackActive && jetpackParticles == nil {
            let emitter = ParticleFactory.jetpackFlame()
            emitter.position  = CGPoint(x: 0, y: -36)
            emitter.zPosition = -1
            addChild(emitter)
            jetpackParticles = emitter
        } else if !cat.jetpackActive, let particles = jetpackParticles {
            particles.removeFromParent()
            jetpackParticles = nil
        }

        // Super-jump aura particles
        if cat.superJumpActive && superJumpParticles == nil {
            let emitter = ParticleFactory.superJumpAura()
            emitter.position  = .zero
            emitter.zPosition = -1
            addChild(emitter)
            superJumpParticles = emitter
        } else if !cat.superJumpActive, let particles = superJumpParticles {
            particles.removeFromParent()
            superJumpParticles = nil
        }
    }

    // MARK: - Builders

    private func buildAura() {
        auraShape = SKShapeNode(circleOfRadius: 70)
        auraShape.fillColor   = .clear
        auraShape.strokeColor = .clear
        auraShape.isHidden    = true
        auraShape.zPosition   = -2
        addChild(auraShape)
    }

    private func buildTail(skin: CatSkin) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 28, y: -14))
        path.addCurve(to:       CGPoint(x: 58,  y:  22),
                      control1: CGPoint(x: 50,  y: -28),
                      control2: CGPoint(x: 70,  y:   2))
        tailShape = SKShapeNode(path: path)
        tailShape.strokeColor = skin.bodyColor
        tailShape.lineWidth   = 8
        tailShape.lineCap     = .round
        tailShape.fillColor   = .clear
        tailShape.zPosition   = -1
        addChild(tailShape)
    }

    private func buildBody(skin: CatSkin) {
        bodyShape = SKShapeNode(ellipseIn: CGRect(x: -34, y: -30, width: 68, height: 58))
        bodyShape.fillColor   = skin.bodyColor
        bodyShape.strokeColor = .clear
        addChild(bodyShape)
    }

    private func buildBelly(skin: CatSkin) {
        let hasBelly = [PatternType.tuxedo, .bicolor, .colorpoint, .calico]
            .contains(skin.patternType)
        guard hasBelly else { return }
        bellyShape = SKShapeNode(ellipseIn: CGRect(x: -16, y: -22, width: 32, height: 34))
        bellyShape.fillColor   = skin.bellyColor
        bellyShape.strokeColor = .clear
        addChild(bellyShape)
    }

    private func buildStripes(skin: CatSkin) {
        let hasStripes = skin.patternType == .tabby || skin.patternType == .marbled
        guard hasStripes else { return }
        for i in 0..<3 {
            let ox = CGFloat(i - 1) * 18.0
            let path = CGMutablePath()
            path.move(to:     CGPoint(x: ox - 5, y:  22))
            path.addLine(to:  CGPoint(x: ox + 5, y:  22))
            path.addLine(to:  CGPoint(x: ox + 7, y: -12))
            path.addLine(to:  CGPoint(x: ox - 7, y: -12))
            path.closeSubpath()
            let stripe = SKShapeNode(path: path)
            stripe.fillColor   = skin.patternColor.withAlphaComponent(0.5)
            stripe.strokeColor = .clear
            addChild(stripe)
        }
    }

    private func buildEars(skin: CatSkin) {
        earL = ear(side: -1, color: skin.bodyColor)
        earR = ear(side:  1, color: skin.bodyColor)
        addChild(earL)
        addChild(earR)

        earInnerL = earInner(side: -1)
        earInnerR = earInner(side:  1)
        addChild(earInnerL)
        addChild(earInnerR)
    }

    private func buildHead(skin: CatSkin) {
        headShape = SKShapeNode(circleOfRadius: 30)
        headShape.position    = CGPoint(x: 0, y: 26)
        headShape.fillColor   = skin.bodyColor
        headShape.strokeColor = .clear
        addChild(headShape)
    }

    private func buildEyes(skin: CatSkin) {
        eyeL    = circle(r: 7.5, at: CGPoint(x: -11, y: 32), fill: .white)
        eyeR    = circle(r: 7.5, at: CGPoint(x:  11, y: 32), fill: .white)
        pupilL  = circle(r: 5,   at: CGPoint(x: -11, y: 32), fill: skin.eyeColor)
        pupilR  = circle(r: 5,   at: CGPoint(x:  11, y: 32), fill: skin.eyeColor)
        let shineL = circle(r: 1.8, at: CGPoint(x: -9, y: 34), fill: .white)
        let shineR = circle(r: 1.8, at: CGPoint(x: 13, y: 34), fill: .white)
        addChild(eyeL); addChild(eyeR)
        addChild(pupilL); addChild(pupilR)
        addChild(shineL); addChild(shineR)
    }

    private func buildNose() {
        noseShape = SKShapeNode(ellipseIn: CGRect(x: -4, y: 16, width: 8, height: 6))
        noseShape.fillColor   = SKColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1)
        noseShape.strokeColor = .clear
        addChild(noseShape)
    }

    private func buildWhiskers() {
        (whiskerL1, whiskerL2) = whiskerPair(side: -1)
        (whiskerR1, whiskerR2) = whiskerPair(side:  1)
        addChild(whiskerL1); addChild(whiskerL2)
        addChild(whiskerR1); addChild(whiskerR2)
    }

    private func applyBodyScale(_ scale: BodyScale) {
        switch scale {
        case .slim:   xScale = 0.85
        case .chonky: xScale = 1.15; yScale = 1.05
        case .normal: xScale = 1.0;  yScale = 1.0
        }
    }

    // MARK: - Shape helpers

    private func ear(side: CGFloat, color: SKColor) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: side * 12, y: 48))
        path.addLine(to: CGPoint(x: side * 30, y: 72))
        path.addLine(to: CGPoint(x: side *  4, y: 60))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = color
        node.strokeColor = .clear
        return node
    }

    private func earInner(side: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: side * 14, y: 52))
        path.addLine(to: CGPoint(x: side * 26, y: 68))
        path.addLine(to: CGPoint(x: side *  8, y: 60))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor   = SKColor(red: 1.0, green: 0.76, blue: 0.80, alpha: 0.65)
        node.strokeColor = .clear
        return node
    }

    private func circle(r: CGFloat, at pos: CGPoint, fill: SKColor) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: r)
        node.position    = pos
        node.fillColor   = fill
        node.strokeColor = .clear
        return node
    }

    private func whiskerPair(side: CGFloat) -> (SKShapeNode, SKShapeNode) {
        let w1 = line(from: CGPoint(x: side * 5,  y: 21),
                      to:   CGPoint(x: side * 32, y: 24))
        let w2 = line(from: CGPoint(x: side * 5,  y: 18),
                      to:   CGPoint(x: side * 32, y: 14))
        return (w1, w2)
    }

    private func line(from: CGPoint, to: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let node = SKShapeNode(path: path)
        node.strokeColor = SKColor.white.withAlphaComponent(0.85)
        node.lineWidth   = 1.2
        node.lineCap     = .round
        return node
    }
}
