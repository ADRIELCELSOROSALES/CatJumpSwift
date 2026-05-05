import SpriteKit

enum ParticleFactory {

    // MARK: - Continuous emitters (managed by caller)

    static func jetpackFlame() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate          = 120
        e.particleLifetime           = 0.25
        e.particleLifetimeRange      = 0.1
        e.particlePositionRange      = CGVector(dx: 12, dy: 4)
        e.particleSpeed              = 80
        e.particleSpeedRange         = 30
        e.emissionAngle              = -.pi / 2   // downward in SpriteKit (y-up)
        e.emissionAngleRange         = 0.4
        e.particleScale              = 0.18
        e.particleScaleSpeed         = -0.5
        e.particleAlpha              = 1.0
        e.particleAlphaSpeed         = -3.5
        e.particleColor              = SKColor(red: 1, green: 0.35, blue: 0.05, alpha: 1)
        e.particleColorBlendFactor   = 1.0
        e.particleBlendMode          = .add
        return e
    }

    static func superJumpAura() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate          = 60
        e.particleLifetime           = 0.4
        e.particleLifetimeRange      = 0.1
        e.particlePositionRange      = CGVector(dx: 30, dy: 30)
        e.particleSpeed              = 40
        e.particleSpeedRange         = 20
        e.emissionAngle              = 0
        e.emissionAngleRange         = .pi * 2    // full circle burst
        e.particleScale              = 0.12
        e.particleScaleSpeed         = -0.25
        e.particleAlpha              = 0.9
        e.particleAlphaSpeed         = -2.0
        e.particleColor              = SKColor(red: 1, green: 0.85, blue: 0.1, alpha: 1)
        e.particleColorBlendFactor   = 1.0
        e.particleBlendMode          = .add
        return e
    }

    // MARK: - Burst emitters (use via burst(_:in:at:))

    static func eatEffect() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate          = 0          // activated by burst()
        e.particleLifetime           = 0.5
        e.particleLifetimeRange      = 0.2
        e.particlePositionRange      = CGVector(dx: 20, dy: 20)
        e.particleSpeed              = 100
        e.particleSpeedRange         = 50
        e.emissionAngle              = 0
        e.emissionAngleRange         = .pi * 2
        e.particleScale              = 0.15
        e.particleScaleSpeed         = -0.3
        e.particleAlpha              = 1.0
        e.particleAlphaSpeed         = -2.5
        e.particleColor              = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        e.particleColorBlendFactor   = 1.0
        e.particleBlendMode          = .add
        return e
    }

    static func platformBreak() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate          = 0
        e.particleLifetime           = 0.6
        e.particleLifetimeRange      = 0.2
        e.particlePositionRange      = CGVector(dx: 30, dy: 6)
        e.particleSpeed              = 60
        e.particleSpeedRange         = 40
        e.emissionAngle              = 0
        e.emissionAngleRange         = .pi * 2
        e.particleScale              = 0.2
        e.particleScaleSpeed         = -0.3
        e.particleAlpha              = 1.0
        e.particleAlphaSpeed         = -1.5
        e.particleColor              = SKColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1)
        e.particleColorBlendFactor   = 1.0
        e.particleBlendMode          = .alpha
        return e
    }

    static func loseLifeFlash() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleBirthRate          = 0
        e.particleLifetime           = 0.3
        e.particleLifetimeRange      = 0.05
        e.particlePositionRange      = CGVector(dx: 40, dy: 40)
        e.particleSpeed              = 120
        e.particleSpeedRange         = 40
        e.emissionAngle              = 0
        e.emissionAngleRange         = .pi * 2
        e.particleScale              = 0.25
        e.particleScaleSpeed         = -0.8
        e.particleAlpha              = 0.8
        e.particleAlphaSpeed         = -3.0
        e.particleColor              = SKColor(red: 1, green: 0.1, blue: 0.1, alpha: 1)
        e.particleColorBlendFactor   = 1.0
        e.particleBlendMode          = .add
        return e
    }

    // MARK: - Burst helper

    /// Adds `emitter` to `node` at `position`, fires a 200-particle burst for 0.05 s,
    /// then stops emission and auto-removes after `duration`.
    static func burst(
        _ emitter: SKEmitterNode,
        in node: SKNode,
        at position: CGPoint,
        duration: TimeInterval = 0.6
    ) {
        emitter.position  = position
        emitter.zPosition = 15
        emitter.particleBirthRate = 200
        node.addChild(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            emitter.particleBirthRate = 0
        }

        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ]))
    }
}
