import SpriteKit

/// Detects piece overlap and validates placement constraints
class CollisionSystem {

    /// Check if two rectangular areas overlap
    func overlaps(
        positionA: CGPoint, sizeA: CGSize,
        positionB: CGPoint, sizeB: CGSize
    ) -> Bool {
        let halfWidthA = sizeA.width / 2
        let halfHeightA = sizeA.height / 2
        let halfWidthB = sizeB.width / 2
        let halfHeightB = sizeB.height / 2

        let leftA = positionA.x - halfWidthA
        let rightA = positionA.x + halfWidthA
        let bottomA = positionA.y - halfHeightA
        let topA = positionA.y + halfHeightA

        let leftB = positionB.x - halfWidthB
        let rightB = positionB.x + halfWidthB
        let bottomB = positionB.y - halfHeightB
        let topB = positionB.y + halfHeightB

        return leftA < rightB && rightA > leftB && bottomA < topB && topA > bottomB
    }

    /// Check if placing a piece at a position would overlap with any existing placed pieces
    func wouldOverlap(
        position: CGPoint,
        size: CGSize,
        existingPieces: [PieceNode]
    ) -> Bool {
        for existing in existingPieces {
            guard existing.isPlaced else { continue }
            if overlaps(
                positionA: position, sizeA: size,
                positionB: existing.position, sizeB: existing.pieceSize
            ) {
                return true
            }
        }
        return false
    }

    /// Check if a position is within the grid bounds
    func isWithinGrid(
        position: CGPoint,
        pieceSize: CGSize,
        gridOrigin: CGPoint,
        gridSize: CGSize
    ) -> Bool {
        let halfW = pieceSize.width / 2
        let halfH = pieceSize.height / 2

        return position.x - halfW >= gridOrigin.x &&
               position.x + halfW <= gridOrigin.x + gridSize.width &&
               position.y - halfH >= gridOrigin.y &&
               position.y + halfH <= gridOrigin.y + gridSize.height
    }
}
