import SwiftUI
import SpriteKit
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // Scene
    @Published var scene: SKScene?

    // Level info
    @Published var levelName: String = ""
    @Published var currentNarration: String = ""

    // Game state
    @Published var piecesPlaced: Int = 0
    @Published var totalPieces: Int = 0
    @Published var isLevelComplete: Bool = false
    @Published var elapsedTime: TimeInterval = 0

    // Timer (Challenge Mode)
    @Published var remainingTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0

    // Piece tray
    @Published var availablePieces: [PieceViewModel] = []
    @Published var selectedPieceId: String?

    private var timerCancellable: AnyCancellable?

    func loadLevel(_ levelId: Int) {
        // Placeholder — will load from JSON in Phase 3
        levelName = "Level \(levelId)"
        currentNarration = "Welcome to level \(levelId)! Let's start building!"

        // Create placeholder pieces
        let placeholderPieces: [(String, String, String, String)] = [
            ("wall_1", "Left Wall", "wall", "#FF6B6B"),
            ("wall_2", "Right Wall", "wall", "#FF6B6B"),
            ("roof_1", "Roof", "roof", "#4DABF7"),
            ("door_1", "Front Door", "door", "#69DB7C"),
            ("window_1", "Window", "window", "#FFD43B"),
        ]

        availablePieces = placeholderPieces.map { id, label, type, color in
            PieceViewModel(id: id, label: label, typeName: type, color: color, width: 1, height: 1)
        }
        totalPieces = availablePieces.count

        // Create SpriteKit scene
        let buildScene = BuildScene(size: CGSize(width: 800, height: 600))
        buildScene.scaleMode = .aspectFit
        buildScene.backgroundColor = UIColor(Color.vbBackground)
        scene = buildScene
    }

    func startLevel() {
        // Begin gameplay after narration
        elapsedTime = 0
    }

    func selectPiece(_ pieceId: String) {
        if selectedPieceId == pieceId {
            selectedPieceId = nil
        } else {
            selectedPieceId = pieceId
        }
    }

    func placePiece(_ pieceId: String, at position: CGPoint) {
        availablePieces.removeAll { $0.id == pieceId }
        piecesPlaced += 1
        selectedPieceId = nil

        if piecesPlaced >= totalPieces {
            isLevelComplete = true
            stopTimer()
        }
    }

    // MARK: - Timer

    func startTimer(duration: TimeInterval) {
        totalTime = duration
        remainingTime = duration

        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    if self.remainingTime > 0 {
                        self.remainingTime -= 1
                        self.elapsedTime += 1
                    } else {
                        self.stopTimer()
                    }
                }
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

// MARK: - Placeholder BuildScene

class BuildScene: SKScene {
    override func didMove(to view: SKView) {
        // Grid will be rendered here in Phase 2
        let label = SKLabelNode(text: "Building Area")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 32
        label.fontColor = UIColor(Color.vbTextSecondary)
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
    }
}
