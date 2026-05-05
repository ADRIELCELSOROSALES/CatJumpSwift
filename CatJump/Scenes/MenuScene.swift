import SpriteKit
import GameKit

class MenuScene: SKScene {

    var services: ServiceContainer

    private var catNode: CatNode!
    private var playButton: SKNode!
    private var skinsButton: SKNode!
    private var rankingButton: SKNode?
    private var backgroundNode: BackgroundNode!

    // MARK: - Init

    init(services: ServiceContainer) {
        self.services = services
        super.init(size: .zero)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        let cx = size.width / 2
        let h  = size.height

        backgroundNode = BackgroundNode()
        backgroundNode.configure(screenWidth: size.width, screenHeight: h)
        addChild(backgroundNode)

        buildTitle(cx: cx, h: h)
        buildAnimatedCat(cx: cx, h: h)
        buildBestScore(cx: cx, h: h)
        buildPlayButton(cx: cx, h: h)
        buildSkinsButton(h: h)
        buildInstructions(cx: cx, h: h)
        if GKLocalPlayer.local.isAuthenticated {
            buildRankingButton(cx: cx, h: h)
        }
    }

    // MARK: - Layout helpers

    private func buildTitle(cx: CGFloat, h: CGFloat) {
        let catLbl = lbl("CAT", size: 64, at: CGPoint(x: cx - 6, y: h * 0.82))
        catLbl.fontColor = hex(0xFF9800)
        catLbl.horizontalAlignmentMode = .right
        addChild(catLbl)

        let jumpLbl = lbl("JUMP", size: 64, at: CGPoint(x: cx + 6, y: h * 0.82))
        jumpLbl.fontColor = hex(0x4CAF50)
        jumpLbl.horizontalAlignmentMode = .left
        addChild(jumpLbl)

        let subtitle = lbl("🐱 El Gatito Saltarín 🐱", size: 16, at: CGPoint(x: cx, y: h * 0.74))
        subtitle.fontColor = SKColor.white.withAlphaComponent(0.65)
        addChild(subtitle)
    }

    private func buildAnimatedCat(cx: CGFloat, h: CGFloat) {
        let skin = CatSkins.getById(services.scoreStore.selectedSkinId)
        catNode = CatNode()
        catNode.configure(skin: skin)
        catNode.position = CGPoint(x: cx, y: h * 0.56)
        catNode.setScale(1.15)
        addChild(catNode)

        let up   = SKAction.moveBy(x: 0, y: 24, duration: 0.4)
        up.timingMode   = .easeOut
        let down = SKAction.moveBy(x: 0, y: -24, duration: 0.4)
        down.timingMode = .easeIn
        catNode.run(SKAction.repeatForever(SKAction.sequence([up, down])))
    }

    private func buildBestScore(cx: CGFloat, h: CGFloat) {
        let best = services.scoreStore.highScore
        guard best > 0 else { return }

        let titleLbl = lbl("MEJOR PUNTAJE", size: 14, at: CGPoint(x: cx, y: h * 0.43))
        titleLbl.fontColor = SKColor.white.withAlphaComponent(0.6)
        addChild(titleLbl)

        let scoreLbl = lbl("\(best)", size: 30, at: CGPoint(x: cx, y: h * 0.38))
        scoreLbl.fontColor = hex(0xFFD54F)
        addChild(scoreLbl)
    }

    private func buildPlayButton(cx: CGFloat, h: CGFloat) {
        playButton = buttonNode(text: "▶  JUGAR", width: 190, height: 58,
                                fill: hex(0x2E7D32), at: CGPoint(x: cx, y: h * 0.27))
        addChild(playButton)
    }

    private func buildRankingButton(cx: CGFloat, h: CGFloat) {
        rankingButton = buttonNode(text: "🏆 RANKING", width: 150, height: 44,
                                   fill: SKColor(red: 0.45, green: 0.28, blue: 0.0, alpha: 0.88),
                                   at: CGPoint(x: cx + 100, y: h * 0.10))
        addChild(rankingButton!)
    }

    private func buildSkinsButton(h: CGFloat) {
        skinsButton = buttonNode(text: "SKINS", width: 130, height: 44,
                                 fill: SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 0.88),
                                 at: CGPoint(x: 82, y: h * 0.10))
        addChild(skinsButton)

        // Mini dancing cat above the SKINS button
        let skin    = CatSkins.getById(services.scoreStore.selectedSkinId)
        let miniCat = CatNode()
        miniCat.configure(skin: skin)
        miniCat.setScale(0.28)
        miniCat.position = CGPoint(x: 82, y: h * 0.10 + 50)
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle:  0.18, duration: 0.22),
            SKAction.rotate(byAngle: -0.18, duration: 0.22)
        ])
        miniCat.run(SKAction.repeatForever(wiggle))
        addChild(miniCat)
    }

    private func buildInstructions(cx: CGFloat, h: CGFloat) {
        let lines = [
            "Toca izquierda / derecha para moverse",
            "¡Salta sobre las plataformas y sube!",
            "Evita los obstáculos y recoge power-ups"
        ]
        for (i, text) in lines.enumerated() {
            let l = lbl(text, size: 13, at: CGPoint(x: cx, y: h * 0.165 - CGFloat(i) * 18))
            l.fontColor = SKColor.white.withAlphaComponent(0.5)
            addChild(l)
        }
    }

    // MARK: - Input

#if os(iOS) || os(visionOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        handleTap(at: event.location(in: self))
    }
#endif

    private func handleTap(at location: CGPoint) {
        if playButton.frame.contains(location)           { goToGame()       }
        if skinsButton.frame.contains(location)          { goToSkins()      }
        if let rb = rankingButton, rb.frame.contains(location) { goToRanking() }
    }

    private func goToGame() {
        let scene = GameScene(services: services)
        scene.selectedSkin = CatSkins.getById(services.scoreStore.selectedSkinId)
        scene.scaleMode    = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func goToSkins() {
        let scene = SkinScene(services: services)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    private func goToRanking() {
        GameCenterManager.shared.showLeaderboard()
    }

    // MARK: - Factory helpers

    private func buttonNode(text: String, width: CGFloat, height: CGFloat,
                            fill: SKColor, at pos: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = pos

        let bg = SKShapeNode(rect: CGRect(x: -width/2, y: -height/2,
                                          width: width, height: height),
                             cornerRadius: height / 2)
        bg.fillColor   = fill
        bg.strokeColor = fill.withAlphaComponent(0.4)
        bg.lineWidth   = 2
        container.addChild(bg)

        let label = SKLabelNode(text: text)
        label.fontName  = "AvenirNext-Bold"
        label.fontSize  = 22
        label.fontColor = .white
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)

        return container
    }

    private func lbl(_ text: String, size: CGFloat, at pos: CGPoint) -> SKLabelNode {
        let n = SKLabelNode(text: text)
        n.fontName   = "AvenirNext-Bold"
        n.fontSize   = size
        n.position   = pos
        n.horizontalAlignmentMode = .center
        n.verticalAlignmentMode   = .center
        return n
    }

    private func hex(_ value: UInt32) -> SKColor {
        SKColor(red:   CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8)  & 0xFF) / 255,
                blue:  CGFloat( value        & 0xFF) / 255,
                alpha: 1)
    }
}
