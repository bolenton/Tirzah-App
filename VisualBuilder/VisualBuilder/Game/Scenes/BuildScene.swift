import SpriteKit

/// Protocol for communicating game events from the SpriteKit scene to the SwiftUI layer
protocol BuildSceneDelegate: AnyObject {
    func buildScene(_ scene: BuildScene, didPlacePiece pieceId: String, inSlot slotId: String)
    func buildScene(_ scene: BuildScene, didRejectPiece pieceId: String)
    func buildScene(_ scene: BuildScene, didSelectPiece pieceId: String)
    func buildScene(_ scene: BuildScene, didTapEmptyAt position: CGPoint)
    func buildSceneDidComplete(_ scene: BuildScene)
    func buildScene(_ scene: BuildScene, didDiscoverEasterEgg eggId: String)
}

/// Main SpriteKit scene for the building gameplay
class BuildScene: SKScene, PieceNodeDelegate {

    weak var gameDelegate: BuildSceneDelegate?

    // Systems
    private let snapSystem = SnapSystem(snapThreshold: 50.0)
    private let collisionSystem = CollisionSystem()

    // Nodes
    private var gridNode: GridNode?
    private var slotNodes: [SlotNode] = []
    private var pieceNodes: [PieceNode] = []

    // State
    private var selectedPieceId: String?
    private var cellSize: CGFloat = 60.0
    private var gridOrigin: CGPoint = .zero
    private var placedCount: Int = 0
    private var totalSlots: Int = 0

    // Easter egg tracking
    private var tapCounts: [String: Int] = [:] // position key -> tap count
    private var placementOrder: [String] = []

    // Configuration
    var highContrastEnabled: Bool = false {
        didSet {
            pieceNodes.forEach { $0.highContrastEnabled = highContrastEnabled }
        }
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1.0)
        anchorPoint = CGPoint(x: 0, y: 0)
    }

    // MARK: - Level Setup

    func setupLevel(slots: [Slot], pieces: [Piece], gridWidth: Int, gridHeight: Int) {
        // Clear existing
        removeAllChildren()
        slotNodes.removeAll()
        pieceNodes.removeAll()
        placedCount = 0
        placementOrder.removeAll()
        tapCounts.removeAll()

        totalSlots = slots.count

        // Calculate cell size to fit the grid in the scene
        let padding: CGFloat = 40
        let availableWidth = size.width - padding * 2
        let availableHeight = size.height - padding * 2

        let cellW = availableWidth / CGFloat(gridWidth)
        let cellH = availableHeight / CGFloat(gridHeight)
        cellSize = min(cellW, cellH, 80) // Cap at 80pt per cell

        // Center the grid
        let gridTotalWidth = CGFloat(gridWidth) * cellSize
        let gridTotalHeight = CGFloat(gridHeight) * cellSize
        gridOrigin = CGPoint(
            x: (size.width - gridTotalWidth) / 2,
            y: (size.height - gridTotalHeight) / 2
        )

        // Draw grid
        let grid = GridNode(gridWidth: gridWidth, gridHeight: gridHeight, cellSize: cellSize, origin: gridOrigin)
        addChild(grid)
        gridNode = grid

        // Create slot nodes
        for slot in slots {
            let slotNode = SlotNode(slot: slot, cellSize: cellSize, gridOrigin: gridOrigin)
            addChild(slotNode)
            slotNodes.append(slotNode)
        }

        // Create piece nodes (positioned off-screen initially — placed by the tray or drag)
        for piece in pieces {
            let pieceSize = CGSize(
                width: CGFloat(piece.size.width) * cellSize,
                height: CGFloat(piece.size.height) * cellSize
            )
            let node = PieceNode(piece: piece, size: pieceSize)
            node.delegate = self
            node.highContrastEnabled = highContrastEnabled
            node.position = CGPoint(x: -200, y: -200) // Off-screen until spawned
            node.isHidden = true
            addChild(node)
            pieceNodes.append(node)
        }
    }

    // MARK: - Piece Management

    /// Spawn a piece into the scene from the tray (called when user selects from SwiftUI tray)
    func spawnPiece(id: String, at position: CGPoint) {
        guard let node = pieceNodes.first(where: { $0.pieceId == id && !$0.isPlaced }) else { return }
        node.position = position
        node.isHidden = false
        node.setScale(0.1)
        node.run(SKAction.scale(to: 1.0, duration: 0.2))
    }

    /// Select a piece (from tap-to-place flow)
    func selectPiece(_ pieceId: String?) {
        // Deselect previous
        if let prevId = selectedPieceId,
           let prevNode = pieceNodes.first(where: { $0.pieceId == prevId }) {
            prevNode.setSelected(false)
        }

        selectedPieceId = pieceId

        // Select new
        if let pieceId = pieceId,
           let node = pieceNodes.first(where: { $0.pieceId == pieceId && !$0.isPlaced }) {
            node.setSelected(true)

            // Highlight compatible slots
            let compatibleType = node.pieceType
            for slot in slotNodes {
                if slot.acceptsPieceType == compatibleType && !slot.isOccupied {
                    slot.showCompatible()
                } else {
                    slot.resetAppearance()
                }
            }
        } else {
            // Reset all slot highlights
            slotNodes.forEach { $0.resetAppearance() }
        }
    }

    // MARK: - Placement Logic

    private func attemptPlacement(piece: PieceNode, at position: CGPoint) -> Bool {
        // Find nearest compatible slot
        guard let result = snapSystem.findNearestSlot(
            for: piece.pieceType,
            at: position,
            in: slotNodes
        ) else {
            return false
        }

        if result.isCompatible {
            placePiece(piece, in: result.slot)
            return true
        } else {
            piece.animateReject()
            gameDelegate?.buildScene(self, didRejectPiece: piece.pieceId)
            return false
        }
    }

    private func placePiece(_ piece: PieceNode, in slot: SlotNode) {
        slot.occupy(pieceId: piece.pieceId)
        placementOrder.append(piece.pieceId)

        piece.animateSnap(to: slot.position) { [weak self] in
            guard let self else { return }
            self.placedCount += 1
            self.gameDelegate?.buildScene(self, didPlacePiece: piece.pieceId, inSlot: slot.slotId)

            // Check completion
            if self.placedCount >= self.totalSlots {
                self.gameDelegate?.buildSceneDidComplete(self)
            }
        }

        // Deselect after placement
        if selectedPieceId == piece.pieceId {
            selectedPieceId = nil
            slotNodes.forEach { $0.resetAppearance() }
        }
    }

    // MARK: - Tap-to-Place (tap on grid when piece is selected)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if tapping a slot when a piece is selected
        if let selectedId = selectedPieceId,
           let piece = pieceNodes.first(where: { $0.pieceId == selectedId && !$0.isPlaced }) {

            // Find the slot at tap location
            if let targetSlot = snapSystem.findSlotForTap(
                pieceType: piece.pieceType,
                tapPosition: location,
                slots: slotNodes
            ) {
                // Make piece visible at tap location then snap to slot
                piece.isHidden = false
                piece.position = location
                placePiece(piece, in: targetSlot)
                return
            }
        }

        // Track taps for easter eggs
        let key = "\(Int(location.x / 20))_\(Int(location.y / 20))"
        tapCounts[key, default: 0] += 1

        gameDelegate?.buildScene(self, didTapEmptyAt: location)
    }

    // MARK: - PieceNodeDelegate (Drag & Drop)

    func pieceDidStartDrag(_ piece: PieceNode) {
        // Highlight compatible slots while dragging
        for slot in slotNodes {
            if slot.acceptsPieceType == piece.pieceType && !slot.isOccupied {
                slot.showCompatible()
            }
        }
    }

    func pieceDidMove(_ piece: PieceNode, to position: CGPoint) {
        // Show hover effect on nearest compatible slot
        for slot in slotNodes {
            if slot.containsPoint(position) && slot.acceptsPieceType == piece.pieceType && !slot.isOccupied {
                slot.showHover()
            } else if slot.acceptsPieceType == piece.pieceType && !slot.isOccupied {
                slot.showCompatible()
            } else {
                slot.resetAppearance()
            }
        }
    }

    func pieceDidEndDrag(_ piece: PieceNode, at position: CGPoint) {
        if !attemptPlacement(piece: piece, at: position) {
            piece.animateReturnToOrigin()
        }
        // Reset slot highlights
        for slot in slotNodes {
            if !slot.isOccupied {
                if let selId = selectedPieceId,
                   let selPiece = pieceNodes.first(where: { $0.pieceId == selId }),
                   slot.acceptsPieceType == selPiece.pieceType {
                    slot.showCompatible()
                } else {
                    slot.resetAppearance()
                }
            }
        }
    }

    func pieceWasTapped(_ piece: PieceNode) {
        // Toggle selection
        if selectedPieceId == piece.pieceId {
            selectPiece(nil)
        } else {
            selectPiece(piece.pieceId)
        }
        gameDelegate?.buildScene(self, didSelectPiece: piece.pieceId)
    }

    // MARK: - Tension Visual Effects

    func showTensionPulse(intensity: CGFloat) {
        // Red edge glow that intensifies as time runs out
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = SKColor.red.withAlphaComponent(0.05 * intensity)
        overlay.strokeColor = SKColor.red.withAlphaComponent(0.2 * intensity)
        overlay.lineWidth = 8
        overlay.zPosition = 100
        overlay.name = "tensionOverlay"

        // Remove existing
        childNode(withName: "tensionOverlay")?.removeFromParent()
        addChild(overlay)

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3 * intensity, duration: 0.5),
            SKAction.fadeAlpha(to: 0.1 * intensity, duration: 0.5)
        ])
        overlay.run(SKAction.repeatForever(pulse))
    }

    func removeTensionEffects() {
        childNode(withName: "tensionOverlay")?.removeFromParent()
    }

    // MARK: - Completion Celebration

    func playCelebration() {
        // Particle burst from center
        let emitter = SKEmitterNode()
        emitter.particleTexture = nil
        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter.zPosition = 200
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 200
        emitter.particleLifetime = 2.0
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        emitter.emissionAngleRange = .pi * 2
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.2
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.4
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = SKColor(red: 0.95, green: 0.8, blue: 0.2, alpha: 1.0)
        emitter.particleColorRedRange = 0.3
        emitter.particleColorGreenRange = 0.3

        addChild(emitter)

        // Auto-remove after particles finish
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.removeFromParent()
        ]))

        // Flash all placed pieces
        for piece in pieceNodes where piece.isPlaced {
            let flash = SKAction.sequence([
                SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.2),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
            ])
            piece.run(SKAction.repeat(flash, count: 3))
        }
    }
}
