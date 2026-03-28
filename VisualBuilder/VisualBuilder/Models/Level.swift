import Foundation

// MARK: - Level Definition (loaded from JSON)

struct Level: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let challengeTime: TimeInterval
    let gridSize: GridSize
    let backgroundTheme: String

    let narrationScripts: NarrationScripts
    let slotVariants: [SlotVariant]
    let pieces: [PieceDefinition]
    let bonusPieces: [BonusPiece]?
    let easterEggs: [EasterEggDefinition]?

    struct GridSize: Codable {
        let width: Int
        let height: Int
    }
}

// MARK: - Narration

struct NarrationScripts: Codable {
    let intros: [NarrationLine]
    let progress: [String: [String]]  // "25", "50", "75", "100" -> array of variants
    let tension: [String: [String]]   // "50", "25", "10", "expired" -> array of variants
}

struct NarrationLine: Codable {
    let text: String
    let voiceStyle: String
    let rate: Float
    let pitchMultiplier: Float
}

// MARK: - Slots (placement targets)

struct SlotVariant: Codable {
    let variantId: String
    let slots: [SlotDefinition]
}

struct SlotDefinition: Codable, Identifiable {
    let id: String
    let position: Position
    let size: PieceSize
    let acceptsPieceType: String
    let label: String

    struct Position: Codable {
        let x: Int
        let y: Int
    }
}

// MARK: - Pieces

struct PieceDefinition: Codable, Identifiable {
    let id: String
    let type: String
    let label: String
    let size: PieceSize
    let colorVariants: [String]
    let textureVariants: [String]
}

struct PieceSize: Codable {
    let width: Int
    let height: Int
}

// MARK: - Bonus & Easter Eggs

struct BonusPiece: Codable {
    let id: String
    let label: String
    let probability: Double
}

struct EasterEggDefinition: Codable {
    let id: String
    let type: String  // "tap", "sequence", "speed", "exploration"
    let trigger: EasterEggTrigger
    let reward: EasterEggReward
    let hint: String
}

struct EasterEggTrigger: Codable {
    let position: SlotDefinition.Position?
    let tapsRequired: Int?
    let completionTimeUnder: TimeInterval?
    let pieceSequence: [String]?
}

struct EasterEggReward: Codable {
    let type: String  // "visual", "audio", "narrative"
    let content: String
}
