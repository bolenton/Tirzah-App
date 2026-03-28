import Foundation

struct LevelVariant {
    let seed: UInt64
    let selectedSlotVariantId: String
    let pieceColors: [String: String]     // pieceId -> selected color hex
    let pieceTextures: [String: String]   // pieceId -> selected texture name
    let bonusPieceIds: Set<String>        // which bonus pieces appear
    let introNarrationIndex: Int          // which intro narration to use

    /// Deterministically generate a variant from a seed and level definition
    static func generate(from level: Level, seed: UInt64) -> LevelVariant {
        var rng = SeededRNG(seed: seed &+ UInt64(level.id))

        // Pick a slot layout variant
        let slotVariantIndex = Int(rng.next() % UInt64(level.slotVariants.count))
        let selectedVariant = level.slotVariants[slotVariantIndex]

        // Pick colors for each piece
        var pieceColors: [String: String] = [:]
        var pieceTextures: [String: String] = [:]
        for piece in level.pieces {
            let colorIndex = Int(rng.next() % UInt64(piece.colorVariants.count))
            pieceColors[piece.id] = piece.colorVariants[colorIndex]

            let textureIndex = Int(rng.next() % UInt64(piece.textureVariants.count))
            pieceTextures[piece.id] = piece.textureVariants[textureIndex]
        }

        // Determine which bonus pieces appear
        var bonusPieceIds: Set<String> = []
        if let bonusPieces = level.bonusPieces {
            for bonus in bonusPieces {
                let roll = Double(rng.next() % 1000) / 1000.0
                if roll < bonus.probability {
                    bonusPieceIds.insert(bonus.id)
                }
            }
        }

        // Pick narration intro
        let narrationIndex = Int(rng.next() % UInt64(level.narrationScripts.intros.count))

        return LevelVariant(
            seed: seed,
            selectedSlotVariantId: selectedVariant.variantId,
            pieceColors: pieceColors,
            pieceTextures: pieceTextures,
            bonusPieceIds: bonusPieceIds,
            introNarrationIndex: narrationIndex
        )
    }
}

// MARK: - Seeded Random Number Generator

struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 1 : seed
    }

    /// xorshift64 — simple, fast, deterministic
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
