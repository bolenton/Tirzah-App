import Foundation

/// Selects random variants for a level using a deterministic seed.
/// In multiplayer, all players share the same seed so they get the same layout.
class VariantEngine {

    /// Generate the full runtime configuration for a level
    static func resolve(level: Level, seed: UInt64) -> ResolvedLevel {
        let variant = LevelVariant.generate(from: level, seed: seed)

        // Select slot layout
        let selectedSlots: [SlotDefinition]
        if let slotVariant = level.slotVariants.first(where: { $0.variantId == variant.selectedSlotVariantId }) {
            selectedSlots = slotVariant.slots
        } else {
            selectedSlots = level.slotVariants.first?.slots ?? []
        }

        // Build runtime slots
        let runtimeSlots = selectedSlots.map { def in
            Slot(
                id: def.id,
                gridPosition: CGPoint(x: CGFloat(def.position.x), y: CGFloat(def.position.y)),
                size: def.size,
                acceptsPieceType: def.acceptsPieceType,
                label: def.label
            )
        }

        // Build runtime pieces with selected variants
        var runtimePieces = level.pieces.map { def in
            Piece(
                id: def.id,
                type: def.type,
                label: def.label,
                size: def.size,
                color: variant.pieceColors[def.id] ?? def.colorVariants.first ?? "#CCCCCC",
                texture: variant.pieceTextures[def.id] ?? def.textureVariants.first ?? "default"
            )
        }

        // Shuffle piece order for variety
        var rng = SeededRNG(seed: seed &+ 999)
        runtimePieces.shuffle(using: &rng)

        // Select intro narration
        let introNarration: NarrationLine
        if variant.introNarrationIndex < level.narrationScripts.intros.count {
            introNarration = level.narrationScripts.intros[variant.introNarrationIndex]
        } else {
            introNarration = level.narrationScripts.intros.first ?? NarrationLine(
                text: "Let's build!",
                voiceStyle: "default",
                rate: 0.5,
                pitchMultiplier: 1.0
            )
        }

        return ResolvedLevel(
            level: level,
            variant: variant,
            slots: runtimeSlots,
            pieces: runtimePieces,
            introNarration: introNarration,
            bonusPieceIds: variant.bonusPieceIds
        )
    }
}

/// A level with all variants resolved, ready for gameplay
struct ResolvedLevel {
    let level: Level
    let variant: LevelVariant
    let slots: [Slot]
    let pieces: [Piece]
    let introNarration: NarrationLine
    let bonusPieceIds: Set<String>

    var gridWidth: Int { level.gridSize.width }
    var gridHeight: Int { level.gridSize.height }
    var challengeTime: TimeInterval { level.challengeTime }
    var name: String { level.name }
    var narrationScripts: NarrationScripts { level.narrationScripts }
}

// MARK: - Shuffle with seeded RNG

extension MutableCollection {
    mutating func shuffle(using rng: inout SeededRNG) {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let offset = Int(rng.next() % UInt64(unshuffledCount))
            let i = index(firstUnshuffled, offsetBy: offset)
            swapAt(firstUnshuffled, i)
        }
    }
}
