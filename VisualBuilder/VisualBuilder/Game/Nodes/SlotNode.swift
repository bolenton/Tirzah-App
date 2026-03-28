import SpriteKit

/// A target placement position on the grid where a specific piece type can be placed
class SlotNode: SKNode {
    let slotId: String
    let acceptsPieceType: String
    let slotLabel: String
    let slotSize: CGSize
    let gridPosition: CGPoint

    private let outlineNode: SKShapeNode
    private let labelNode: SKLabelNode
    private let highlightNode: SKShapeNode

    private(set) var isOccupied: Bool = false
    private(set) var placedPieceId: String?

    // Visual states
    private let defaultColor = SKColor(red: 0.25, green: 0.3, blue: 0.35, alpha: 0.4)
    private let highlightColor = SKColor(red: 0.31, green: 0.76, blue: 0.97, alpha: 0.6) // vbAccent
    private let compatibleColor = SKColor(red: 0.25, green: 0.72, blue: 0.31, alpha: 0.5) // vbGreen
    private let occupiedColor = SKColor(red: 0.2, green: 0.24, blue: 0.3, alpha: 0.2)

    init(slot: Slot, cellSize: CGFloat, gridOrigin: CGPoint) {
        self.slotId = slot.id
        self.acceptsPieceType = slot.acceptsPieceType
        self.slotLabel = slot.label
        self.gridPosition = slot.gridPosition
        self.slotSize = slot.sceneSize(cellSize: cellSize)

        let rect = CGSize(width: slotSize.width - 4, height: slotSize.height - 4)

        // Dashed outline showing where the piece should go
        outlineNode = SKShapeNode(rectOf: rect, cornerRadius: 6)
        outlineNode.strokeColor = defaultColor
        outlineNode.lineWidth = 3
        outlineNode.fillColor = .clear
        outlineNode.glowWidth = 1

        // Label showing what goes here
        labelNode = SKLabelNode(text: slot.label)
        labelNode.fontName = "AvenirNext-Medium"
        labelNode.fontSize = min(14, cellSize * 0.3)
        labelNode.fontColor = SKColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 0.8)
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center

        // Highlight glow for when a compatible piece is selected
        highlightNode = SKShapeNode(rectOf: CGSize(width: rect.width + 8, height: rect.height + 8), cornerRadius: 8)
        highlightNode.strokeColor = .clear
        highlightNode.fillColor = highlightColor.withAlphaComponent(0.15)
        highlightNode.isHidden = true

        super.init()

        self.name = "slot_\(slot.id)"
        self.isUserInteractionEnabled = false

        let pos = slot.scenePosition(cellSize: cellSize, gridOrigin: gridOrigin)
        self.position = pos

        addChild(highlightNode)
        addChild(outlineNode)
        addChild(labelNode)

        // Accessibility
        self.accessibilityLabel = "\(slot.label). Accepts \(slot.acceptsPieceType)."
        self.isAccessibilityElement = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - State Changes

    /// Show that this slot accepts the currently selected piece type
    func showCompatible() {
        guard !isOccupied else { return }
        highlightNode.isHidden = false
        highlightNode.fillColor = compatibleColor.withAlphaComponent(0.2)
        outlineNode.strokeColor = compatibleColor
        outlineNode.glowWidth = 3

        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        ])
        highlightNode.run(SKAction.repeatForever(pulse), withKey: "pulse")
    }

    /// Show that a piece is being dragged over this slot
    func showHover() {
        guard !isOccupied else { return }
        highlightNode.isHidden = false
        highlightNode.fillColor = highlightColor.withAlphaComponent(0.3)
        outlineNode.strokeColor = highlightColor
        outlineNode.lineWidth = 4
        outlineNode.glowWidth = 4
    }

    /// Reset to default appearance
    func resetAppearance() {
        highlightNode.isHidden = true
        highlightNode.removeAction(forKey: "pulse")
        outlineNode.strokeColor = isOccupied ? occupiedColor : defaultColor
        outlineNode.lineWidth = 3
        outlineNode.glowWidth = 1
    }

    /// Mark as occupied with a piece
    func occupy(pieceId: String) {
        isOccupied = true
        placedPieceId = pieceId
        outlineNode.strokeColor = occupiedColor
        labelNode.isHidden = true
        highlightNode.isHidden = true
        highlightNode.removeAction(forKey: "pulse")
    }

    /// Remove the placed piece
    func vacate() {
        isOccupied = false
        placedPieceId = nil
        outlineNode.strokeColor = defaultColor
        labelNode.isHidden = false
    }

    /// Check if a point (in parent coordinates) is within this slot's bounds
    func containsPoint(_ point: CGPoint) -> Bool {
        let halfW = slotSize.width / 2
        let halfH = slotSize.height / 2
        return point.x >= position.x - halfW &&
               point.x <= position.x + halfW &&
               point.y >= position.y - halfH &&
               point.y <= position.y + halfH
    }
}
