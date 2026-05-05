import SpriteKit

class BackgroundNode: SKNode {

    private let bgSprite = SKSpriteNode()
    private var screenSize: CGSize = .zero
    private var cachedTextures: [Int: SKTexture] = [:]
    private var currentPaletteIndex = -1

    // MARK: - Configure

    func configure(screenWidth: CGFloat, screenHeight: CGFloat) {
        screenSize = CGSize(width: screenWidth, height: screenHeight)

        bgSprite.size      = screenSize
        bgSprite.position  = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        bgSprite.zPosition = -100
        addChild(bgSprite)

        // Pre-generate all 4 gradient textures once
        for i in 0...3 {
            cachedTextures[i] = makeGradient(index: i)
        }

        apply(index: 0, animated: false)
    }

    // MARK: - Update

    func update(score: Int) {
        let idx = paletteIndex(for: score)
        guard idx != currentPaletteIndex else { return }
        apply(index: idx, animated: true)
    }

    // MARK: - Private

    private func apply(index: Int, animated: Bool) {
        currentPaletteIndex = index
        guard let texture = cachedTextures[index] else { return }

        if animated {
            let fadeOut     = SKAction.fadeAlpha(to: 0, duration: 0.35)
            let swapTexture = SKAction.run { [weak self] in self?.bgSprite.texture = texture }
            let fadeIn      = SKAction.fadeAlpha(to: 1, duration: 0.45)
            bgSprite.run(SKAction.sequence([fadeOut, swapTexture, fadeIn]))
        } else {
            bgSprite.texture = texture
        }
    }

    private func paletteIndex(for score: Int) -> Int {
        switch score {
        case 0..<1000:   return 0
        case 1000..<3000: return 1
        case 3000..<6000: return 2
        default:          return 3
        }
    }

    /// Returns (topColor, bottomColor) for each palette
    private func palette(index: Int) -> (SKColor, SKColor) {
        switch index {
        case 0:  return (hex(0x1A237E), hex(0x3949AB))   // night blue
        case 1:  return (hex(0x1565C0), hex(0x42A5F5))   // clear blue
        case 2:  return (hex(0x4A148C), hex(0x7B1FA2))   // purple
        default: return (hex(0x0D0D0D), hex(0x1A237E))   // deep space
        }
    }

    // MARK: - Gradient texture (CoreGraphics, cross-platform)

    private func makeGradient(index: Int) -> SKTexture? {
        let (topColor, bottomColor) = palette(index: index)
        let size = screenSize
        guard size.width > 0, size.height > 0 else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let ctx = CGContext(data: nil,
                                  width:  Int(size.width),
                                  height: Int(size.height),
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo.rawValue)
        else { return nil }

        // In CGContext y=0 is at the bottom; topColor → y=height, bottomColor → y=0
        let colors = [bottomColor.cgColor, topColor.cgColor] as CFArray
        guard let gradient = CGGradient(colorsSpace: colorSpace,
                                        colors: colors,
                                        locations: [0, 1])
        else { return nil }

        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: 0),
                               end:   CGPoint(x: 0, y: size.height),
                               options: [])

        guard let image = ctx.makeImage() else { return nil }
        return SKTexture(cgImage: image)
    }

    // MARK: - Hex helper

    private func hex(_ value: UInt32) -> SKColor {
        SKColor(
            red:   CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8)  & 0xFF) / 255,
            blue:  CGFloat( value        & 0xFF) / 255,
            alpha: 1
        )
    }
}
