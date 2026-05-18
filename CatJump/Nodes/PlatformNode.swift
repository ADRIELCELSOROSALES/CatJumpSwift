import SpriteKit

class PlatformNode: SKNode {

    // height of the drawn content — used by spriteKitY to give the node's bottom edge
    private var height: CGFloat = GameConstants.platformHeight

    func spriteKitY(_ gameY: CGFloat, screenHeight: CGFloat) -> CGFloat {
        screenHeight - gameY - height
    }

    // MARK: - Configure

    func configure(type: PlatformType, width: CGFloat = GameConstants.platformWidth) {
        removeAllChildren()
        let w = width
        let h = GameConstants.platformHeight
        height = h

        switch type {
        case .normal:  buildNormal(w: w, h: h)
        case .moving:  buildMoving(w: w, h: h)
        case .fragile: buildFragile(w: w, h: h)
        case .spring:  buildSpring(w: w, h: h)
        }
    }

    // MARK: - Update

    func update(platform: Platform, cameraOffset: CGFloat, screenHeight: CGFloat) {
        // cameraOffset = state.cameraY (game-space Y of camera top, negative when scrolled up)
        let relativeY = platform.y - cameraOffset
        position = CGPoint(x: platform.x, y: spriteKitY(relativeY, screenHeight: screenHeight))
        alpha = platform.isActive ? 1 : 0
    }

    // MARK: - Builders

    private func buildNormal(w: CGFloat, h: CGFloat) {
        let dirtH  = h * 0.65
        let grassH = h - dirtH

        let dirt = shape(rect: CGRect(x: -w/2, y: 0, width: w, height: dirtH),
                         fill: 0x8D6E63, radius: 2)
        addChild(dirt)

        let grass = shape(rect: CGRect(x: -w/2, y: dirtH, width: w, height: grassH),
                          fill: 0x4CAF50, radius: 3)
        addChild(grass)
    }

    private func buildMoving(w: CGFloat, h: CGFloat) {
        let base = shape(rect: CGRect(x: -w/2, y: 0, width: w, height: h),
                         fill: 0xE3F2FD, radius: h / 2)
        base.strokeColor = hex(0x90CAF9)
        base.lineWidth = 1
        addChild(base)

        // Three cloud puffs along the top edge
        let puffR = h * 0.75
        for px: CGFloat in [-w * 0.3, 0, w * 0.3] {
            let puff = SKShapeNode(circleOfRadius: puffR)
            puff.position = CGPoint(x: px, y: h * 0.85)
            puff.fillColor = hex(0xE3F2FD)
            puff.strokeColor = .clear
            addChild(puff)
        }
    }

    private func buildFragile(w: CGFloat, h: CGFloat) {
        let base = shape(rect: CGRect(x: -w/2, y: 0, width: w, height: h),
                         fill: 0xBCAAA4, radius: 2)
        addChild(base)

        // Three diagonal crack lines
        for (i, ox) in ([-w * 0.2, 0.0 as CGFloat, w * 0.2]).enumerated() {
            let _ = i
            let crack = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: ox,     y: h))
            path.addLine(to: CGPoint(x: ox - 4, y: h * 0.5))
            path.addLine(to: CGPoint(x: ox + 3, y: 0))
            crack.path = path
            crack.strokeColor = hex(0x5D4037).withAlphaComponent(0.7)
            crack.lineWidth = 1.5
            crack.lineCap = .round
            addChild(crack)
        }
    }

    private func buildSpring(w: CGFloat, h: CGFloat) {
        // Metal base
        let metal = shape(rect: CGRect(x: -w/2, y: 0, width: w, height: h * 0.6),
                          fill: 0x78909C, radius: 2)
        addChild(metal)

        // Spring coil (simplified as a compressed orange rectangle)
        let sw = w * 0.28
        let spring = shape(rect: CGRect(x: -sw/2, y: h * 0.6, width: sw, height: h * 0.28),
                           fill: 0xFF5722, radius: 1)
        addChild(spring)

        // Spring top cap (wider, brighter)
        let cap = shape(rect: CGRect(x: -sw/2 - 5, y: h * 0.86, width: sw + 10, height: h * 0.14),
                        fill: 0xFF7043, radius: 2)
        addChild(cap)
    }

    // MARK: - Helpers

    private func shape(rect: CGRect, fill: UInt32, radius: CGFloat = 0) -> SKShapeNode {
        let node = SKShapeNode(rect: rect, cornerRadius: radius)
        node.fillColor = hex(fill)
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
