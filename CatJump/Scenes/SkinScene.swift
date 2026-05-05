import SpriteKit

final class SkinScene: SKScene {

    var services: ServiceContainer

    private var selectedSkinId: String
    private var previewCatNode: CatNode!
    private var gridLayer:      SKNode!
    private var cellNodes:      [String: SKNode] = [:]

    private let columns:    Int     = 3
    private let cellW:      CGFloat = 100
    private let cellH:      CGFloat = 120
    private let cellGapX:   CGFloat = 12
    private let cellGapY:   CGFloat = 14

    // Scroll state
    private var scrollOffset:    CGFloat = 0
    private var dragStartY:      CGFloat = 0
    private var dragStartOffset: CGFloat = 0
    private var isDragging:      Bool    = false
    private var maxScrollOffset: CGFloat = 0

    // MARK: - Init

    init(services: ServiceContainer) {
        self.services       = services
        self.selectedSkinId = services.scoreStore.selectedSkinId
        super.init(size: .zero)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        let cx = size.width / 2
        let h  = size.height

        // Background
        let bg = BackgroundNode()
        bg.configure(screenWidth: size.width, screenHeight: h)
        addChild(bg)

        // Dark overlay for readability
        let overlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: h))
        overlay.fillColor   = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        overlay.strokeColor = .clear
        overlay.zPosition   = 1
        addChild(overlay)

        // Title
        let titleLbl = lbl("ELIGE TU GATITO", size: 26,
                           at: CGPoint(x: cx, y: h * 0.93))
        titleLbl.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        titleLbl.zPosition = 5
        addChild(titleLbl)

        // Preview cat
        buildPreview(cx: cx, h: h)

        // Scroll crop area (crop node acts as mask)
        buildGrid(cx: cx, h: h)

        // Back button
        buildBackButton(h: h)
    }

    // MARK: - Preview

    private func buildPreview(cx: CGFloat, h: CGFloat) {
        let skin    = CatSkins.getById(selectedSkinId)
        previewCatNode = CatNode()
        previewCatNode.configure(skin: skin)
        previewCatNode.position  = CGPoint(x: cx, y: h * 0.77)
        previewCatNode.setScale(0.85)
        previewCatNode.zPosition = 5
        addChild(previewCatNode)

        let up   = SKAction.moveBy(x: 0, y: 14, duration: 0.38)
        up.timingMode   = .easeOut
        let down = SKAction.moveBy(x: 0, y: -14, duration: 0.38)
        down.timingMode = .easeIn
        previewCatNode.run(SKAction.repeatForever(SKAction.sequence([up, down])))
    }

    // MARK: - Grid

    private func buildGrid(cx: CGFloat, h: CGFloat) {
        let skins  = CatSkins.all
        let rows   = Int(ceil(Double(skins.count) / Double(columns)))
        let totalW = CGFloat(columns) * cellW + CGFloat(columns - 1) * cellGapX
        let startX = cx - totalW / 2 + cellW / 2

        let gridAreaH: CGFloat = h * 0.46
        let gridBottom = h * 0.18

        // Crop node to clip grid to the visible area
        let cropNode = SKCropNode()
        cropNode.zPosition = 5

        let mask = SKShapeNode(rect: CGRect(x: -size.width / 2,
                                            y: -gridAreaH / 2,
                                            width: size.width,
                                            height: gridAreaH))
        mask.fillColor = .white
        cropNode.maskNode = mask
        cropNode.position = CGPoint(x: cx, y: gridBottom + gridAreaH / 2)
        addChild(cropNode)

        gridLayer = SKNode()
        cropNode.addChild(gridLayer)

        // Compute total grid height for scroll clamping
        let totalGridH = CGFloat(rows) * (cellH + cellGapY)
        maxScrollOffset = max(0, totalGridH - gridAreaH)

        for (index, skin) in skins.enumerated() {
            let col = index % columns
            let row = index / columns

            let cellX = startX + CGFloat(col) * (cellW + cellGapX) - cx
            // Rows grow downward from the top of the grid area
            let topY  = gridAreaH / 2 - cellH / 2 - cellGapY / 2
            let cellY = topY - CGFloat(row) * (cellH + cellGapY)

            let cell = buildCell(skin: skin, at: CGPoint(x: cellX, y: cellY))
            cell.name = skin.id
            gridLayer.addChild(cell)
            cellNodes[skin.id] = cell
        }
    }

    private func buildCell(skin: CatSkin, at pos: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = pos

        let isSelected = skin.id == selectedSkinId

        let bg = SKShapeNode(rect: CGRect(x: -cellW/2, y: -cellH/2,
                                          width: cellW, height: cellH),
                             cornerRadius: 14)
        bg.fillColor   = isSelected
            ? SKColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 0.85)
            : SKColor(red: 0.12, green: 0.12, blue: 0.25, alpha: 0.80)
        bg.strokeColor = isSelected
            ? SKColor(red: 0.56, green: 0.93, blue: 0.56, alpha: 1)
            : SKColor.white.withAlphaComponent(0.15)
        bg.lineWidth   = isSelected ? 2 : 1
        bg.name        = "bg"
        container.addChild(bg)

        let miniCat = CatNode()
        miniCat.configure(skin: skin)
        miniCat.setScale(0.22)
        miniCat.position  = CGPoint(x: 0, y: cellH * 0.12)
        miniCat.zPosition = 2
        container.addChild(miniCat)

        let nameLbl = SKLabelNode(text: skin.name)
        nameLbl.fontName   = "AvenirNext-Bold"
        nameLbl.fontSize   = 10
        nameLbl.fontColor  = .white
        nameLbl.position   = CGPoint(x: 0, y: -cellH / 2 + 14)
        nameLbl.horizontalAlignmentMode = .center
        nameLbl.verticalAlignmentMode   = .center
        container.addChild(nameLbl)

        if skin.price > 0 && !skin.isDefault {
            let priceLbl = SKLabelNode(text: "\(skin.price) 🐟")
            priceLbl.fontName  = "AvenirNext-Bold"
            priceLbl.fontSize  = 9
            priceLbl.fontColor = SKColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            priceLbl.position  = CGPoint(x: 0, y: -cellH / 2 + 4)
            priceLbl.horizontalAlignmentMode = .center
            priceLbl.verticalAlignmentMode   = .center
            container.addChild(priceLbl)
        }

        return container
    }

    // MARK: - Back button

    private func buildBackButton(h: CGFloat) {
        let btn = buttonNode(text: "← VOLVER", width: 150, height: 46,
                             fill: SKColor(red: 0.15, green: 0.15, blue: 0.30, alpha: 0.88),
                             at: CGPoint(x: size.width / 2, y: h * 0.06))
        btn.name      = "back"
        btn.zPosition = 5
        addChild(btn)
    }

    // MARK: - Refresh cell highlights

    private func refreshCellHighlights() {
        for (skinId, cell) in cellNodes {
            let isSelected = skinId == selectedSkinId
            if let bg = cell.children.first(where: { $0.name == "bg" }) as? SKShapeNode {
                bg.fillColor   = isSelected
                    ? SKColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 0.85)
                    : SKColor(red: 0.12, green: 0.12, blue: 0.25, alpha: 0.80)
                bg.strokeColor = isSelected
                    ? SKColor(red: 0.56, green: 0.93, blue: 0.56, alpha: 1)
                    : SKColor.white.withAlphaComponent(0.15)
                bg.lineWidth   = isSelected ? 2 : 1
            }
        }
    }

    private func refreshPreview() {
        let skin = CatSkins.getById(selectedSkinId)
        previewCatNode.configure(skin: skin)
    }

    // MARK: - Scroll helpers

    private func applyScroll(_ offset: CGFloat) {
        let clamped = max(0, min(maxScrollOffset, offset))
        scrollOffset           = clamped
        gridLayer.position.y   = -clamped
    }

    // MARK: - Input

#if os(iOS) || os(visionOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        dragStartY      = loc.y
        dragStartOffset = scrollOffset
        isDragging      = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let dy = dragStartY - touch.location(in: self).y
        if abs(dy) > 6 { isDragging = true }
        if isDragging { applyScroll(dragStartOffset + dy) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if !isDragging { handleTap(at: touch.location(in: self)) }
        isDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
#elseif os(macOS)
    override func mouseDown(with event: NSEvent) {
        let loc = event.location(in: self)
        dragStartY      = loc.y
        dragStartOffset = scrollOffset
        isDragging      = false
    }

    override func mouseDragged(with event: NSEvent) {
        let dy = dragStartY - event.location(in: self).y
        if abs(dy) > 6 { isDragging = true }
        if isDragging { applyScroll(dragStartOffset + dy) }
    }

    override func mouseUp(with event: NSEvent) {
        if !isDragging { handleTap(at: event.location(in: self)) }
        isDragging = false
    }
#endif

    private func handleTap(at location: CGPoint) {
        // Check back button
        let hitNames = nodes(at: location).compactMap(\.name)
        if hitNames.contains("back") { goToMenu(); return }

        // Check skin cells — convert location to gridLayer coordinate space
        let gridLoc = convert(location, to: gridLayer)
        for (skinId, cell) in cellNodes {
            let localLoc = gridLayer.convert(gridLoc, to: cell)
            if abs(localLoc.x) <= cellW / 2 && abs(localLoc.y) <= cellH / 2 {
                selectSkin(id: skinId)
                return
            }
        }
    }

    private func selectSkin(id: String) {
        selectedSkinId                    = id
        services.scoreStore.selectedSkinId = id
        refreshCellHighlights()
        refreshPreview()
    }

    private func goToMenu() {
        let scene = MenuScene(services: services)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
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
        label.fontSize  = 20
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
}
