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
        buildAccessory(skin: skin)
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

    private func buildAccessory(skin: CatSkin) {
        guard skin.accessory != .none else { return }
        let ac = skin.accessoryColor
        let pc = skin.patternColor

        switch skin.accessory {

        case .none: break

        case .topHat:
            let brim = SKShapeNode(rect: CGRect(x: -28, y: 52, width: 56, height: 7), cornerRadius: 3)
            brim.fillColor = ac; brim.strokeColor = .clear; brim.zPosition = 8
            addChild(brim)
            let crown = SKShapeNode(rect: CGRect(x: -17, y: 59, width: 34, height: 30), cornerRadius: 3)
            crown.fillColor = ac; crown.strokeColor = .clear; crown.zPosition = 8
            addChild(crown)
            let band = SKShapeNode(rect: CGRect(x: -17, y: 59, width: 34, height: 6))
            band.fillColor = pc; band.strokeColor = .clear; band.zPosition = 9
            addChild(band)

        case .crownGold:
            let path = CGMutablePath()
            path.move(to:    CGPoint(x: -24, y: 54))
            path.addLine(to: CGPoint(x: -24, y: 76))
            path.addLine(to: CGPoint(x: -10, y: 66))
            path.addLine(to: CGPoint(x:   0, y: 82))
            path.addLine(to: CGPoint(x:  10, y: 66))
            path.addLine(to: CGPoint(x:  24, y: 76))
            path.addLine(to: CGPoint(x:  24, y: 54))
            path.closeSubpath()
            let crown = SKShapeNode(path: path)
            crown.fillColor = ac; crown.strokeColor = pc; crown.lineWidth = 1.5; crown.zPosition = 8
            addChild(crown)
            for gx: CGFloat in [-14, 0, 14] {
                let gem = circle(r: 3.5, at: CGPoint(x: gx, y: 58), fill: pc)
                gem.zPosition = 9
                addChild(gem)
            }

        case .crownGem:
            let path = CGMutablePath()
            path.move(to:    CGPoint(x: -26, y: 54))
            path.addLine(to: CGPoint(x: -22, y: 78))
            path.addLine(to: CGPoint(x:  -8, y: 64))
            path.addLine(to: CGPoint(x:   0, y: 84))
            path.addLine(to: CGPoint(x:   8, y: 64))
            path.addLine(to: CGPoint(x:  22, y: 78))
            path.addLine(to: CGPoint(x:  26, y: 54))
            path.closeSubpath()
            let crown = SKShapeNode(path: path)
            crown.fillColor = ac; crown.strokeColor = .clear; crown.zPosition = 8
            addChild(crown)
            for (gx, gy): (CGFloat, CGFloat) in [(-14, 58), (0, 68), (14, 58)] {
                let gem = circle(r: 5, at: CGPoint(x: gx, y: gy), fill: pc)
                gem.zPosition = 9
                addChild(gem)
            }

        case .cap:
            let body = SKShapeNode(ellipseIn: CGRect(x: -24, y: 48, width: 48, height: 26))
            body.fillColor = ac; body.strokeColor = .clear; body.zPosition = 8
            addChild(body)
            let billPath = CGMutablePath()
            billPath.move(to: CGPoint(x: -20, y: 52))
            billPath.addLine(to: CGPoint(x: -32, y: 44))
            billPath.addLine(to: CGPoint(x:  10, y: 42))
            billPath.addLine(to: CGPoint(x:  20, y: 52))
            billPath.closeSubpath()
            let bill = SKShapeNode(path: billPath)
            bill.fillColor = ac; bill.strokeColor = .clear; bill.zPosition = 8
            addChild(bill)
            let logo = circle(r: 5, at: CGPoint(x: 2, y: 60), fill: pc)
            logo.zPosition = 9
            addChild(logo)

        case .beanie:
            let body = SKShapeNode(ellipseIn: CGRect(x: -25, y: 48, width: 50, height: 32))
            body.fillColor = ac; body.strokeColor = .clear; body.zPosition = 8
            addChild(body)
            let cuff = SKShapeNode(rect: CGRect(x: -24, y: 48, width: 48, height: 8), cornerRadius: 2)
            cuff.fillColor = pc; cuff.strokeColor = .clear; cuff.zPosition = 9
            addChild(cuff)
            let pom = circle(r: 8, at: CGPoint(x: 0, y: 78), fill: .white)
            pom.zPosition = 9
            addChild(pom)

        case .witchHat:
            let brim = SKShapeNode(ellipseIn: CGRect(x: -30, y: 50, width: 60, height: 14))
            brim.fillColor = ac; brim.strokeColor = .clear; brim.zPosition = 8
            addChild(brim)
            let hatPath = CGMutablePath()
            hatPath.move(to:    CGPoint(x: -20, y: 57))
            hatPath.addLine(to: CGPoint(x:   0, y: 98))
            hatPath.addLine(to: CGPoint(x:  20, y: 57))
            hatPath.closeSubpath()
            let hat = SKShapeNode(path: hatPath)
            hat.fillColor = ac; hat.strokeColor = .clear; hat.zPosition = 8
            addChild(hat)
            let band = SKShapeNode(rect: CGRect(x: -18, y: 57, width: 36, height: 6))
            band.fillColor = pc; band.strokeColor = .clear; band.zPosition = 9
            addChild(band)

        case .cowboyHat:
            let crownShape = SKShapeNode(ellipseIn: CGRect(x: -20, y: 50, width: 40, height: 24))
            crownShape.fillColor = ac; crownShape.strokeColor = .clear; crownShape.zPosition = 8
            addChild(crownShape)
            let brimPath = CGMutablePath()
            brimPath.move(to: CGPoint(x: -38, y: 56))
            brimPath.addCurve(to:       CGPoint(x:  38, y: 56),
                              control1: CGPoint(x: -38, y: 46),
                              control2: CGPoint(x:  38, y: 46))
            brimPath.addLine(to: CGPoint(x:  24, y: 62))
            brimPath.addLine(to: CGPoint(x: -24, y: 62))
            brimPath.closeSubpath()
            let brim = SKShapeNode(path: brimPath)
            brim.fillColor = ac; brim.strokeColor = .clear; brim.zPosition = 7
            addChild(brim)
            let band = SKShapeNode(rect: CGRect(x: -18, y: 51, width: 36, height: 5))
            band.fillColor = pc; band.strokeColor = .clear; band.zPosition = 9
            addChild(band)

        case .vikingHelmet:
            let dome = SKShapeNode(ellipseIn: CGRect(x: -26, y: 48, width: 52, height: 30))
            dome.fillColor = ac; dome.strokeColor = pc; dome.lineWidth = 2; dome.zPosition = 8
            addChild(dome)
            for side: CGFloat in [-1, 1] {
                let horn = hornPath(side: side)
                horn.fillColor = .white; horn.strokeColor = ac; horn.lineWidth = 1.5; horn.zPosition = 7
                addChild(horn)
            }

        case .monocle:
            let lens = SKShapeNode(circleOfRadius: 11)
            lens.position = CGPoint(x: 12, y: 32)
            lens.fillColor = ac.withAlphaComponent(0.25)
            lens.strokeColor = ac; lens.lineWidth = 2.5; lens.zPosition = 8
            addChild(lens)
            let chainPath = CGMutablePath()
            chainPath.move(to: CGPoint(x: 23, y: 26))
            chainPath.addLine(to: CGPoint(x: 28, y: 14))
            let chain = SKShapeNode(path: chainPath)
            chain.strokeColor = ac; chain.lineWidth = 1.5; chain.zPosition = 8
            addChild(chain)

        case .glasses:
            for sx: CGFloat in [-1, 1] {
                let lens = SKShapeNode(circleOfRadius: 10)
                lens.position = CGPoint(x: sx * 11, y: 32)
                lens.fillColor = ac.withAlphaComponent(0.2)
                lens.strokeColor = ac; lens.lineWidth = 2; lens.zPosition = 8
                addChild(lens)
            }
            let bridgePath = CGMutablePath()
            bridgePath.move(to: CGPoint(x: -1, y: 32))
            bridgePath.addLine(to: CGPoint(x: 1, y: 32))
            bridgePath.move(to: CGPoint(x: -21, y: 32))
            bridgePath.addLine(to: CGPoint(x: -30, y: 28))
            bridgePath.move(to: CGPoint(x:  21, y: 32))
            bridgePath.addLine(to: CGPoint(x:  30, y: 28))
            let bridge = SKShapeNode(path: bridgePath)
            bridge.strokeColor = ac; bridge.lineWidth = 2; bridge.zPosition = 8
            addChild(bridge)

        case .sunglasses:
            let lLens = SKShapeNode(rect: CGRect(x: -22, y: 26, width: 19, height: 12), cornerRadius: 3)
            lLens.fillColor = ac; lLens.strokeColor = .clear; lLens.zPosition = 8
            addChild(lLens)
            let rLens = SKShapeNode(rect: CGRect(x: 3, y: 26, width: 19, height: 12), cornerRadius: 3)
            rLens.fillColor = ac; rLens.strokeColor = .clear; rLens.zPosition = 8
            addChild(rLens)
            let templePath = CGMutablePath()
            templePath.move(to: CGPoint(x: -3, y: 32)); templePath.addLine(to: CGPoint(x: 3, y: 32))
            templePath.move(to: CGPoint(x: -22, y: 32)); templePath.addLine(to: CGPoint(x: -32, y: 26))
            templePath.move(to: CGPoint(x:  22, y: 32)); templePath.addLine(to: CGPoint(x:  32, y: 26))
            let temples = SKShapeNode(path: templePath)
            temples.strokeColor = ac.withAlphaComponent(0.7); temples.lineWidth = 2; temples.zPosition = 8
            addChild(temples)

        case .piratePatch:
            let patch = SKShapeNode(ellipseIn: CGRect(x: -23, y: 25, width: 24, height: 18))
            patch.fillColor = ac; patch.strokeColor = .clear; patch.zPosition = 8
            addChild(patch)
            let strapPath = CGMutablePath()
            strapPath.move(to: CGPoint(x: -21, y: 34)); strapPath.addLine(to: CGPoint(x: -30, y: 26))
            strapPath.move(to: CGPoint(x:  -1, y: 34)); strapPath.addLine(to: CGPoint(x:  10, y: 26))
            let strap = SKShapeNode(path: strapPath)
            strap.strokeColor = ac; strap.lineWidth = 2; strap.zPosition = 8
            addChild(strap)

        case .halo:
            let halo = SKShapeNode(ellipseIn: CGRect(x: -22, y: 70, width: 44, height: 14))
            halo.fillColor = ac.withAlphaComponent(0.25)
            halo.strokeColor = ac; halo.lineWidth = 4; halo.zPosition = 8
            addChild(halo)

        case .antenna:
            let stemPath = CGMutablePath()
            stemPath.move(to: CGPoint(x: 0, y: 54))
            stemPath.addLine(to: CGPoint(x: 0, y: 80))
            let stem = SKShapeNode(path: stemPath)
            stem.strokeColor = ac; stem.lineWidth = 3; stem.zPosition = 8
            addChild(stem)
            let ball = circle(r: 6, at: CGPoint(x: 0, y: 86), fill: ac)
            ball.zPosition = 9
            addChild(ball)

        case .alienAntenna:
            for sx: CGFloat in [-1, 1] {
                let stemPath = CGMutablePath()
                stemPath.move(to: CGPoint(x: sx * 10, y: 58))
                stemPath.addLine(to: CGPoint(x: sx * 20, y: 82))
                let stem = SKShapeNode(path: stemPath)
                stem.strokeColor = ac; stem.lineWidth = 2.5; stem.zPosition = 8
                addChild(stem)
                let ball = circle(r: 6, at: CGPoint(x: sx * 20, y: 88), fill: pc)
                ball.zPosition = 9
                addChild(ball)
            }

        case .bowtie:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -2, y: 10))
            path.addLine(to: CGPoint(x: -22, y: 18))
            path.addLine(to: CGPoint(x: -22, y:  2))
            path.closeSubpath()
            path.move(to: CGPoint(x:  2, y: 10))
            path.addLine(to: CGPoint(x:  22, y: 18))
            path.addLine(to: CGPoint(x:  22, y:  2))
            path.closeSubpath()
            let tie = SKShapeNode(path: path)
            tie.fillColor = ac; tie.strokeColor = .clear; tie.zPosition = 8
            addChild(tie)
            let knot = circle(r: 5, at: CGPoint(x: 0, y: 10), fill: pc)
            knot.zPosition = 9
            addChild(knot)

        case .ribbon:
            let path = CGMutablePath()
            path.move(to: CGPoint(x:   0, y: 62))
            path.addLine(to: CGPoint(x: -24, y: 78))
            path.addLine(to: CGPoint(x: -18, y: 60))
            path.closeSubpath()
            path.move(to: CGPoint(x:   0, y: 62))
            path.addLine(to: CGPoint(x:  24, y: 78))
            path.addLine(to: CGPoint(x:  18, y: 60))
            path.closeSubpath()
            let bow = SKShapeNode(path: path)
            bow.fillColor = ac; bow.strokeColor = pc; bow.lineWidth = 1; bow.zPosition = 8
            addChild(bow)
            let center = circle(r: 6, at: CGPoint(x: 0, y: 62), fill: pc)
            center.zPosition = 9
            addChild(center)

        case .headphones:
            let bandPath = CGMutablePath()
            bandPath.move(to: CGPoint(x: -28, y: 40))
            bandPath.addCurve(to:       CGPoint(x:  28, y: 40),
                              control1: CGPoint(x: -28, y: 84),
                              control2: CGPoint(x:  28, y: 84))
            let band = SKShapeNode(path: bandPath)
            band.strokeColor = ac; band.lineWidth = 4.5; band.fillColor = .clear; band.zPosition = 8
            addChild(band)
            for sx: CGFloat in [-1, 1] {
                let cup = SKShapeNode(ellipseIn: CGRect(x: sx * 34 - 10, y: 26, width: 20, height: 24))
                cup.fillColor = ac; cup.strokeColor = .clear; cup.zPosition = 8
                addChild(cup)
                let cushion = SKShapeNode(ellipseIn: CGRect(x: sx * 34 - 8, y: 28, width: 16, height: 20))
                cushion.fillColor = pc; cushion.strokeColor = .clear; cushion.zPosition = 9
                addChild(cushion)
            }
        }
    }

    private func hornPath(side: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: side * 20, y: 56))
        path.addLine(to: CGPoint(x: side * 36, y: 84))
        path.addLine(to: CGPoint(x: side * 28, y: 56))
        path.closeSubpath()
        return SKShapeNode(path: path)
    }

    private func applyBodyScale(_ scale: BodyScale) {
        let base = GameConstants.catDisplayScale
        switch scale {
        case .slim:   xScale = base * 0.85; yScale = base
        case .chonky: xScale = base * 1.15; yScale = base * 1.05
        case .normal: xScale = base;        yScale = base
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
