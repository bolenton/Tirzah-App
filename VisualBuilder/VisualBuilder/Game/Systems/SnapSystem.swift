import SpriteKit

/// Handles piece-to-slot matching and snap-to-grid logic
class SnapSystem {
    /// Maximum distance (in points) for a piece to snap into a slot
    let snapThreshold: CGFloat

    init(snapThreshold: CGFloat = 50.0) {
        self.snapThreshold = snapThreshold
    }

    /// Result of evaluating a potential placement
    struct SnapResult {
        let slot: SlotNode
        let distance: CGFloat
        let isCompatible: Bool
    }

    /// Find the nearest compatible slot for a piece at a given position
    func findNearestSlot(
        for pieceType: String,
        at position: CGPoint,
        in slots: [SlotNode]
    ) -> SnapResult? {
        var bestResult: SnapResult?
        var bestDistance: CGFloat = .infinity

        for slot in slots {
            guard !slot.isOccupied else { continue }

            let distance = hypot(position.x - slot.position.x, position.y - slot.position.y)
            let isCompatible = slot.acceptsPieceType == pieceType

            if distance < bestDistance && distance <= snapThreshold {
                bestDistance = distance
                bestResult = SnapResult(slot: slot, distance: distance, isCompatible: isCompatible)
            }
        }

        return bestResult
    }

    /// Find all compatible (unoccupied) slots for a piece type
    func compatibleSlots(for pieceType: String, in slots: [SlotNode]) -> [SlotNode] {
        slots.filter { !$0.isOccupied && $0.acceptsPieceType == pieceType }
    }

    /// Check if a piece can be placed in a specific slot
    func canPlace(pieceType: String, in slot: SlotNode) -> Bool {
        !slot.isOccupied && slot.acceptsPieceType == pieceType
    }

    /// For tap-to-place: find the best slot for the selected piece type
    /// When user taps the grid area, find the nearest compatible empty slot to the tap point
    func findSlotForTap(
        pieceType: String,
        tapPosition: CGPoint,
        slots: [SlotNode]
    ) -> SlotNode? {
        let compatible = compatibleSlots(for: pieceType, in: slots)
        guard !compatible.isEmpty else { return nil }

        // If only one compatible slot, use it regardless of distance
        if compatible.count == 1 {
            return compatible.first
        }

        // Find the one closest to where the user tapped
        return compatible.min(by: { slotA, slotB in
            let distA = hypot(tapPosition.x - slotA.position.x, tapPosition.y - slotA.position.y)
            let distB = hypot(tapPosition.x - slotB.position.x, tapPosition.y - slotB.position.y)
            return distA < distB
        })
    }
}
