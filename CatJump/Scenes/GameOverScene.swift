import SpriteKit

final class GameOverScene: SKScene {

    private let score:          Int
    private let highScore:      Int
    private let isNewHighScore: Bool
    private var services:       ServiceContainer

    // MARK: - Init

    init(score: Int, highScore: Int, isNewHighScore: Bool, services: ServiceContainer) {
        self.score          = score
        self.highScore      = highScore
        self.isNewHighScore = isNewHighScore
        self.services       = services
        super.init(size: .zero)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        if size == .zero { size = view.bounds.size }
        let cx = size.width / 2
        let h  = size.height

        // Background
        let bg = BackgroundNode()
        bg.configure(screenWidth: size.width, screenHeight: h)
        addChild(bg)

        // Dark overlay
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: h))
        overlay.fillColor   = SKColor(red: 0, green: 0, blue: 0, alpha: 0.55)
        overlay.strokeColor = .clear
        overlay.zPosition   = 1
        addChild(overlay)

        // Sad cat
        let skin    = CatSkins.getById(services.scoreStore.selectedSkinId)
        let catNode = CatNode()
        catNode.configure(skin: skin)
        var sadCat  = Cat(x: cx, y: 0)
        sadCat.isJumping = false
        catNode.update(cat: sadCat, cameraOffset: 0, screenHeight: h)
        catNode.position  = CGPoint(x: cx, y: h * 0.62)
        catNode.setScale(1.1)
        catNode.zPosition = 5
        addChild(catNode)

        // GAME OVER title
        let titleLbl = lbl("GAME OVER", size: 48, at: CGPoint(x: cx, y: h * 0.80))
        titleLbl.fontColor = SKColor(red: 0.898, green: 0.224, blue: 0.208, alpha: 1) // #E53935
        titleLbl.zPosition = 5
        addChild(titleLbl)

        // Score card
        buildScoreCard(cx: cx, h: h)

        // Encouragement
        let encourageLbl = lbl(encouragementText(), size: 15, at: CGPoint(x: cx, y: h * 0.30))
        encourageLbl.fontColor = SKColor.white.withAlphaComponent(0.7)
        encourageLbl.zPosition = 5
        addChild(encourageLbl)

        // Buttons
        buildTryAgainButton(cx: cx, h: h)
        buildMenuButton(cx: cx, h: h)
    }

    // MARK: - Layout helpers

    private func buildScoreCard(cx: CGFloat, h: CGFloat) {
        let cardW: CGFloat = 260
        let cardH: CGFloat = isNewHighScore ? 110 : 90
        let cardY = h * 0.46

        let card = SKShapeNode(rect: CGRect(x: -cardW/2, y: -cardH/2,
                                            width: cardW, height: cardH),
                               cornerRadius: 16)
        card.fillColor   = SKColor(red: 0.06, green: 0.25, blue: 0.50, alpha: 0.88)
        card.strokeColor = SKColor.white.withAlphaComponent(0.2)
        card.lineWidth   = 1.5
        card.position    = CGPoint(x: cx, y: cardY)
        card.zPosition   = 5
        addChild(card)

        let scoreLbl = lbl("SCORE  \(score)", size: 32, at: CGPoint(x: cx, y: cardY + cardH * 0.22))
        scoreLbl.fontColor = .white
        scoreLbl.zPosition = 6
        addChild(scoreLbl)

        if isNewHighScore {
            let newRecord = lbl("🏆  NEW RECORD!", size: 22, at: CGPoint(x: cx, y: cardY - cardH * 0.10))
            newRecord.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            newRecord.zPosition = 6
            newRecord.run(pulseAction())
            addChild(newRecord)
        } else {
            let bestLbl = lbl("BEST  \(highScore)", size: 18, at: CGPoint(x: cx, y: cardY - cardH * 0.18))
            bestLbl.fontColor = SKColor.white.withAlphaComponent(0.65)
            bestLbl.zPosition = 6
            addChild(bestLbl)
        }
    }

    private func buildTryAgainButton(cx: CGFloat, h: CGFloat) {
        let btn = buttonNode(text: "▶  TRY AGAIN", width: 200, height: 56,
                             fill: SKColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1),
                             at: CGPoint(x: cx, y: h * 0.19))
        btn.name      = "tryAgain"
        btn.zPosition = 5
        addChild(btn)
    }

    private func buildMenuButton(cx: CGFloat, h: CGFloat) {
        let btn = buttonNode(text: "MENU", width: 130, height: 44,
                             fill: SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 0.88),
                             at: CGPoint(x: cx, y: h * 0.10))
        btn.name      = "menu"
        btn.zPosition = 5
        addChild(btn)
    }

    private func encouragementText() -> String {
        switch score {
        case 0..<100:   return "¡Sigue intentándolo, campeón!"
        case 100..<300: return "¡Buen intento! Vas mejorando 🐱"
        case 300..<600: return "¡Nada mal! El gatito está orgulloso."
        case 600..<1000: return "¡Excelente salto! ¿Puedes más?"
        default:         return "¡Increíble! Eres una leyenda felina 🏆"
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
        let hit = nodes(at: location).compactMap(\.name)
        if hit.contains("tryAgain") { goToGame()  }
        else if hit.contains("menu") { goToMenu() }
        else { goToGame() }
    }

    private func goToGame() {
        services.scoreStore.highScore = highScore
        let scene = GameScene(services: services)
        scene.selectedSkin = CatSkins.getById(services.scoreStore.selectedSkinId)
        scene.scaleMode    = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
    }

    private func goToMenu() {
        let scene = MenuScene(services: services)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.35))
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
        bg.name        = container.name
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

    private func pulseAction() -> SKAction {
        let grow   = SKAction.scale(to: 1.12, duration: 0.55)
        let shrink = SKAction.scale(to: 0.92, duration: 0.55)
        grow.timingMode   = .easeInEaseOut
        shrink.timingMode = .easeInEaseOut
        return SKAction.repeatForever(SKAction.sequence([grow, shrink]))
    }
}
