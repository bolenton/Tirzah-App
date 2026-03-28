import Foundation
import SpriteKit

// MARK: - Runtime Piece (instantiated from PieceDefinition with variant applied)

struct Piece: Identifiable {
    let id: String
    let type: String
    let label: String
    let size: PieceSize
    let color: String        // Selected color variant
    let texture: String      // Selected texture variant
    var isPlaced: Bool = false
    var targetSlotId: String? = nil
}

// MARK: - Runtime Slot (instantiated from SlotDefinition)

struct Slot: Identifiable {
    let id: String
    let gridPosition: CGPoint   // Grid coordinates
    let size: PieceSize
    let acceptsPieceType: String
    let label: String
    var isOccupied: Bool = false
    var placedPieceId: String? = nil

    /// Scene position calculated from grid coordinates and cell size
    func scenePosition(cellSize: CGFloat, gridOrigin: CGPoint) -> CGPoint {
        CGPoint(
            x: gridOrigin.x + CGFloat(gridPosition.x) * cellSize + CGFloat(size.width) * cellSize / 2,
            y: gridOrigin.y + CGFloat(gridPosition.y) * cellSize + CGFloat(size.height) * cellSize / 2
        )
    }

    func sceneSize(cellSize: CGFloat) -> CGSize {
        CGSize(
            width: CGFloat(size.width) * cellSize,
            height: CGFloat(size.height) * cellSize
        )
    }
}
