import Foundation

@MainActor
class GameState: ObservableObject {
    @Published var currentLevelId: Int
    @Published var placedPieces: Set<String> = []
    @Published var totalSlots: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isComplete: Bool = false
    @Published var isPaused: Bool = false

    init(levelId: Int) {
        self.currentLevelId = levelId
    }

    var progress: Double {
        guard totalSlots > 0 else { return 0 }
        return Double(placedPieces.count) / Double(totalSlots)
    }

    var progressPercent: Int {
        Int(progress * 100)
    }

    func placePiece(_ pieceId: String) {
        placedPieces.insert(pieceId)
        if placedPieces.count == totalSlots {
            isComplete = true
        }
    }

    func reset() {
        placedPieces = []
        elapsedTime = 0
        isComplete = false
        isPaused = false
    }
}
