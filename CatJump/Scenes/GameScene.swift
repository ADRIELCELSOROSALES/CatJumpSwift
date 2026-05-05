import SpriteKit
import GameKit

class GameScene: SKScene {

    // MARK: - Properties

    var services: ServiceContainer
    var selectedSkin: CatSkin = CatSkins.ORANGE

    private var currentState: GameState?
    private var catNode: CatNode!
    private var platformNodes:  [UUID: PlatformNode]  = [:]
    private var obstacleNodes:  [UUID: ObstacleNode]  = [:]
    private var obstacleTypes:  [UUID: ObstacleType]  = [:]
    private var powerUpNodes:   [UUID: PowerUpNode]   = [:]
    private var backgroundNode: BackgroundNode!
    private var moveDirection:  Int = 0
    private var hudLayer:       SKNode!

    private var scoreLabel:     SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var levelLabel:     SKLabelNode!
    private var livesContainer: SKNode!
    private var gameOverHandled = false
    private var knownInactivePlatformIds: Set<UUID> = []
    private var frameCount: Int = 0

    // MARK: - Init

    init(services: ServiceContainer) {
        self.services = services
        super.init(size: .zero)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        if size == .zero { size = view.bounds.size }
        backgroundColor = .clear

        // Background
        backgroundNode = BackgroundNode()
        backgroundNode.configure(screenWidth: size.width, screenHeight: size.height)
        addChild(backgroundNode)

        // Cat
        catNode = CatNode()
        catNode.zPosition = 10
        addChild(catNode)
        catNode.configure(skin: selectedSkin)

        // HUD
        hudLayer = SKNode()
        hudLayer.zPosition = 100
        addChild(hudLayer)
        setupHUD()

        // Audio
        SoundManager.shared.startBackgroundMusic()

        // Game state
        let highScore = services.scoreStore.highScore
        currentState = services.gameEngine.initializeGame(
            screenWidth: size.width,
            screenHeight: size.height,
            highScore: highScore
        )

        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.start(playerName: "Player")
        }
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        guard var state = currentState else { return }

        if state.isGameOver {
            if !gameOverHandled { handleGameOver() }
            return
        }

        state.currentTime = currentTime
        services.gameEngine.setMoveDirection(moveDirection)

        let newState = services.gameEngine.update(state)
        currentState = newState

        syncNodes(to: newState)
        handleGameEvents(newState)
        SoundManager.shared.process(newState.soundEvents)
        updateHUD(state: newState)

        frameCount += 1
        if frameCount % 60 == 0 {
            if #available(iOS 16.2, *) {
                LiveActivityManager.shared.update(
                    score: newState.score,
                    lives: newState.cat.lives,
                    level: newState.level
                )
            }
        }
    }

    // MARK: - Input

#if os(iOS) || os(visionOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        moveDirection = x < size.width / 2 ? -1 : 1
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveDirection = 0
    }
#endif

    // MARK: - Node sync

    private func syncNodes(to state: GameState) {
        let cameraY = state.cameraY
        let h = size.height

        // Cat
        catNode.update(cat: state.cat, cameraOffset: cameraY, screenHeight: h)

        // Platforms (specialized sync to detect fragile platform breaks)
        syncPlatforms(state: state, cameraY: cameraY, h: h)

        // Obstacles (specialized sync to detect eaten bird/bat/mouse)
        syncObstacles(state: state, cameraY: cameraY, h: h)

        // Power-ups
        sync(
            entities: state.powerUps,
            nodes: &powerUpNodes,
            makeNode: { [weak self] p -> PowerUpNode in
                let n = PowerUpNode()
                n.configure(type: p.type)
                n.zPosition = 7
                self?.addChild(n)
                return n
            },
            updateNode: { n, p in n.update(powerUp: p, cameraOffset: cameraY, screenHeight: h) }
        )

        backgroundNode.update(score: state.score)
    }

    private func syncObstacles(state: GameState, cameraY: CGFloat, h: CGFloat) {
        let activeIds = Set(state.obstacles.map(\.id))

        for id in obstacleNodes.keys where !activeIds.contains(id) {
            if let type = obstacleTypes[id],
               (type == .bird || type == .bat || type == .mouse),
               let node = obstacleNodes[id] {
                ParticleFactory.burst(ParticleFactory.eatEffect(), in: self, at: node.position)
            }
            obstacleNodes[id]?.removeFromParent()
            obstacleNodes.removeValue(forKey: id)
            obstacleTypes.removeValue(forKey: id)
        }

        for obstacle in state.obstacles {
            if obstacleNodes[obstacle.id] == nil {
                let n = ObstacleNode()
                n.configure(type: obstacle.type)
                n.zPosition = 8
                addChild(n)
                obstacleNodes[obstacle.id] = n
                obstacleTypes[obstacle.id] = obstacle.type
            }
            obstacleNodes[obstacle.id]!.update(obstacle: obstacle, cameraOffset: cameraY, screenHeight: h)
        }
    }

    private func syncPlatforms(state: GameState, cameraY: CGFloat, h: CGFloat) {
        let activeIds = Set(state.platforms.map(\.id))

        // Detect newly-broken fragile platforms before their nodes are removed
        for platform in state.platforms where !platform.isActive {
            if !knownInactivePlatformIds.contains(platform.id),
               let node = platformNodes[platform.id] {
                ParticleFactory.burst(ParticleFactory.platformBreak(), in: self, at: node.position)
                knownInactivePlatformIds.insert(platform.id)
            }
        }

        for id in platformNodes.keys where !activeIds.contains(id) {
            platformNodes[id]?.removeFromParent()
            platformNodes.removeValue(forKey: id)
            knownInactivePlatformIds.remove(id)
        }

        for platform in state.platforms {
            if platformNodes[platform.id] == nil {
                let n = PlatformNode()
                n.configure(type: platform.type)
                n.zPosition = 5
                addChild(n)
                platformNodes[platform.id] = n
            }
            platformNodes[platform.id]!.update(platform: platform, cameraOffset: cameraY, screenHeight: h)
        }
    }

    private func handleGameEvents(_ state: GameState) {
        if state.soundEvents.contains(.loseLife) {
            ParticleFactory.burst(ParticleFactory.loseLifeFlash(), in: self, at: catNode.position)
        }
    }

    /// Generic pool sync: removes stale nodes, creates missing ones, updates all.
    private func sync<E: Identifiable, N: SKNode>(
        entities: [E],
        nodes: inout [UUID: N],
        makeNode: (E) -> N,
        updateNode: (N, E) -> Void
    ) where E.ID == UUID {
        let activeIds = Set(entities.map(\.id))

        // Remove nodes for entities that no longer exist
        for id in nodes.keys where !activeIds.contains(id) {
            nodes[id]?.removeFromParent()
            nodes.removeValue(forKey: id)
        }

        // Create or update
        for entity in entities {
            if nodes[entity.id] == nil {
                nodes[entity.id] = makeNode(entity)
            }
            updateNode(nodes[entity.id]!, entity)
        }
    }

    // MARK: - HUD

    private func setupHUD() {
        let w = size.width
        let h = size.height

        scoreLabel = hud(text: "0", size: 30, pos: CGPoint(x: w / 2, y: h - 52))
        scoreLabel.fontColor = .white

        highScoreLabel = hud(text: "Best: 0", size: 16, pos: CGPoint(x: w / 2, y: h - 74))
        highScoreLabel.fontColor = SKColor.white.withAlphaComponent(0.7)

        levelLabel = hud(text: "Lv 1", size: 18, pos: CGPoint(x: w - 52, y: h - 50))
        levelLabel.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        levelLabel.horizontalAlignmentMode = .right

        livesContainer = SKNode()
        livesContainer.position = CGPoint(x: 16, y: h - 52)

        hudLayer.addChild(scoreLabel)
        hudLayer.addChild(highScoreLabel)
        hudLayer.addChild(levelLabel)
        hudLayer.addChild(livesContainer)
    }

    private func updateHUD(state: GameState) {
        scoreLabel.text = "\(state.score)"
        highScoreLabel.text = "Best: \(state.highScore)"
        levelLabel.text = "Lv \(state.level)"

        // Rebuild hearts
        livesContainer.removeAllChildren()
        for i in 0..<max(0, state.cat.lives) {
            let heart = SKLabelNode(text: "❤️")
            heart.fontSize = 18
            heart.position = CGPoint(x: CGFloat(i) * 22, y: 0)
            heart.verticalAlignmentMode = .center
            livesContainer.addChild(heart)
        }
    }

    private func hud(text: String, size: CGFloat, pos: CGPoint) -> SKLabelNode {
        let n = SKLabelNode(text: text)
        n.fontSize   = size
        n.fontName   = "AvenirNext-Bold"
        n.position   = pos
        n.horizontalAlignmentMode = .center
        n.verticalAlignmentMode   = .center
        return n
    }

    // MARK: - Game Over

    private func handleGameOver() {
        gameOverHandled = true
        guard let state = currentState else { return }

        if #available(iOS 16.2, *) {
            LiveActivityManager.shared.end(score: state.score)
        }

        SoundManager.shared.stopBackgroundMusic()

        if state.isNewHighScore {
            services.scoreStore.highScore = state.score
            GameCenterManager.shared.submitScore(state.score)
        }

        let gameOverScene = GameOverScene(
            score: state.score,
            highScore: state.highScore,
            isNewHighScore: state.isNewHighScore,
            services: services
        )
        gameOverScene.scaleMode = scaleMode
        view?.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}

// MARK: - Identifiable conformances (enables the generic sync helper)

extension Platform: Identifiable {}
extension Obstacle: Identifiable {}
extension PowerUp:  Identifiable {}
