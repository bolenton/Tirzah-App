import SpriteKit

/// Protocol to communicate piece events back to the scene
protocol PieceNodeDelegate: AnyObject {
    func pieceDidStartDrag(_ piece: PieceNode)
    func pieceDidMove(_ piece: PieceNode, to position: CGPoint)
    func pieceDidEndDrag(_ piece: PieceNode, at position: CGPoint)
    func pieceWasTapped(_ piece: PieceNode)
}

/// A draggable building piece in the SpriteKit scene
class PieceNode: SKNode {
    let pieceId: String
    let pieceType: String
    let pieceLabel: String
    let pieceColor: SKColor
    let pieceSize: CGSize

    private(set) var isPlaced: Bool = false
    private(set) var isDragging: Bool = false

    private let bodyNode: SKShapeNode
    private let shadowNode: SKShapeNode
    private let labelNode: SKLabelNode
    private var originalPosition: CGPoint = .zero
    private var touchOffset: CGPoint = .zero

    weak var delegate: PieceNodeDelegate?

    // High contrast border
    var highContrastEnabled: Bool = false {
        didSet {
            bodyNode.lineWidth = highContrastEnabled ? 4 : 2
        }
    }

    init(piece: Piece, size: CGSize) {
        self.pieceId = piece.id
        self.pieceType = piece.type
        self.pieceLabel = piece.label
        self.pieceSize = size

        // Parse hex color
        let hex = piece.color.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        self.pieceColor = SKColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )

        // Shadow (beneath the piece for depth)
        shadowNode = SKShapeNode(rectOf: CGSize(width: size.width - 2, height: size.height - 2), cornerRadius: 8)
        shadowNode.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 3, y: -3)
        shadowNode.zPosition = -1

        // Main body
        bodyNode = SKShapeNode(rectOf: CGSize(width: size.width - 4, height: size.height - 4), cornerRadius: 8)
        bodyNode.fillColor = pieceColor
        bodyNode.strokeColor = SKColor.white.withAlphaComponent(0.6)
        bodyNode.lineWidth = 2

        // Texture pattern overlay (subtle)
        // Future: use piece.texture to select different patterns

        // Label
        labelNode = SKLabelNode(text: piece.label)
        labelNode.fontName = "AvenirNext-Bold"
        labelNode.fontSize = min(14, size.width * 0.2)
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center

        super.init()

        self.name = "piece_\(piece.id)"
        self.zPosition = 10
        self.isUserInteractionEnabled = true

        addChild(shadowNode)
        addChild(bodyNode)
        addChild(labelNode)

        // Accessibility
        self.accessibilityLabel = "\(piece.label), \(piece.type) piece"
        self.isAccessibilityElement = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Visual State

    func setSelected(_ selected: Bool) {
        if selected {
            bodyNode.strokeColor = SKColor(red: 0.31, green: 0.76, blue: 0.97, alpha: 1.0)
            bodyNode.lineWidth = 4
            bodyNode.glowWidth = 3

            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
            run(SKAction.repeatForever(pulse), withKey: "selectedPulse")
        } else {
            bodyNode.strokeColor = SKColor.white.withAlphaComponent(0.6)
            bodyNode.lineWidth = highContrastEnabled ? 4 : 2
            bodyNode.glowWidth = 0
            removeAction(forKey: "selectedPulse")
            setScale(1.0)
        }
    }

    func animateSnap(to targetPosition: CGPoint, completion: @escaping () -> Void) {
        isPlaced = true
        isUserInteractionEnabled = false
        zPosition = 5

        let move = SKAction.move(to: targetPosition, duration: 0.2)
        move.timingMode = .easeOut

        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let bounce = SKAction.sequence([scaleDown, scaleUp])

        // Flash green border
        let flashGreen = SKAction.run { [weak self] in
            self?.bodyNode.strokeColor = SKColor(red: 0.25, green: 0.72, blue: 0.31, alpha: 1.0)
            self?.bodyNode.lineWidth = 4
        }
        let resetBorder = SKAction.run { [weak self] in
            self?.bodyNode.strokeColor = SKColor.white.withAlphaComponent(0.4)
            self?.bodyNode.lineWidth = 2
        }

        run(SKAction.sequence([
            SKAction.group([move, flashGreen]),
            bounce,
            SKAction.wait(forDuration: 0.3),
            resetBorder,
            SKAction.run(completion)
        ]))

        // Remove shadow when placed
        shadowNode.run(SKAction.fadeOut(withDuration: 0.2))
    }

    func animateReject() {
        // Shake animation for wrong placement
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -8, y: 0, duration: 0.05),
            SKAction.moveBy(x: 16, y: 0, duration: 0.05),
            SKAction.moveBy(x: -16, y: 0, duration: 0.05),
            SKAction.moveBy(x: 16, y: 0, duration: 0.05),
            SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        ])

        // Flash red border
        let flashRed = SKAction.run { [weak self] in
            self?.bodyNode.strokeColor = SKColor(red: 0.97, green: 0.32, blue: 0.29, alpha: 1.0)
        }
        let resetBorder = SKAction.run { [weak self] in
            self?.bodyNode.strokeColor = SKColor.white.withAlphaComponent(0.6)
        }

        run(SKAction.sequence([flashRed, shake, resetBorder]))
    }

    func animateReturnToOrigin() {
        let move = SKAction.move(to: originalPosition, duration: 0.3)
        move.timingMode = .easeOut
        run(move)
        zPosition = 10
    }

    // MARK: - Touch Handling (Drag & Tap)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isPlaced else { return }
        let location = touch.location(in: parent!)
        originalPosition = position
        touchOffset = CGPoint(x: position.x - location.x, y: position.y - location.y)
        isDragging = false

        // Lift effect
        zPosition = 50
        run(SKAction.scale(to: 1.1, duration: 0.15))
        shadowNode.run(SKAction.group([
            SKAction.moveBy(x: 2, y: -2, duration: 0.15),
            SKAction.fadeAlpha(to: 0.5, duration: 0.15)
        ]))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isPlaced else { return }
        let location = touch.location(in: parent!)
        let newPosition = CGPoint(x: location.x + touchOffset.x, y: location.y + touchOffset.y)

        // Detect drag threshold
        if !isDragging {
            let dx = abs(newPosition.x - originalPosition.x)
            let dy = abs(newPosition.y - originalPosition.y)
            if dx > 8 || dy > 8 {
                isDragging = true
                delegate?.pieceDidStartDrag(self)
            }
        }

        if isDragging {
            position = newPosition
            delegate?.pieceDidMove(self, to: newPosition)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isPlaced else { return }

        run(SKAction.scale(to: 1.0, duration: 0.1))
        shadowNode.run(SKAction.group([
            SKAction.move(to: CGPoint(x: 3, y: -3), duration: 0.1),
            SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        ]))

        if isDragging {
            let location = touch.location(in: parent!)
            delegate?.pieceDidEndDrag(self, at: location)
        } else {
            delegate?.pieceWasTapped(self)
        }

        isDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        run(SKAction.scale(to: 1.0, duration: 0.1))
        animateReturnToOrigin()
    }
}
