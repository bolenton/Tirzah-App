import SwiftUI
import SpriteKit
import Combine

@MainActor
class GameViewModel: ObservableObject, BuildSceneDelegate {
    // Scene
    @Published var scene: SKScene?
    private var buildScene: BuildScene?

    // Level info
    @Published var levelName: String = ""
    @Published var currentNarration: String = ""
    @Published var levelId: Int = 0

    // Game state
    @Published var piecesPlaced: Int = 0
    @Published var totalPieces: Int = 0
    @Published var isLevelComplete: Bool = false
    @Published var elapsedTime: TimeInterval = 0

    // Timer (Challenge Mode)
    @Published var remainingTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var tensionLevel: CGFloat = 0 // 0 = calm, 1 = maximum tension

    // Piece tray
    @Published var availablePieces: [PieceViewModel] = []
    @Published var selectedPieceId: String?

    // Progress narration triggers (% milestones already fired)
    private var firedProgressMilestones: Set<Int> = []
    private var firedTensionThresholds: Set<String> = []

    private var timerCancellable: AnyCancellable?
    private var runtimePieces: [Piece] = []
    private var runtimeSlots: [Slot] = []

    // MARK: - Level Loading

    func loadLevel(_ levelId: Int) {
        self.levelId = levelId

        // Placeholder level data — Phase 3 will load from JSON via LevelLoader
        levelName = levelNameForId(levelId)
        currentNarration = narrationForLevel(levelId)

        // Build placeholder slots and pieces for demonstration
        let (slots, pieces) = generatePlaceholderLevel(levelId)
        runtimeSlots = slots
        runtimePieces = pieces

        // Populate tray
        availablePieces = pieces.map { piece in
            PieceViewModel(
                id: piece.id,
                label: piece.label,
                typeName: piece.type,
                color: piece.color,
                width: piece.size.width,
                height: piece.size.height
            )
        }
        totalPieces = slots.count
        piecesPlaced = 0
        isLevelComplete = false
        elapsedTime = 0
        firedProgressMilestones = []
        firedTensionThresholds = []

        // Create SpriteKit scene
        let newScene = BuildScene(size: CGSize(width: 900, height: 650))
        newScene.scaleMode = .aspectFit
        newScene.gameDelegate = self

        let gridWidth: Int
        let gridHeight: Int
        switch levelId {
        case 1...5: gridWidth = 6; gridHeight = 6
        case 6...10: gridWidth = 7; gridHeight = 7
        case 11...15: gridWidth = 8; gridHeight = 7
        default: gridWidth = 8; gridHeight = 8
        }

        newScene.setupLevel(
            slots: slots,
            pieces: pieces,
            gridWidth: gridWidth,
            gridHeight: gridHeight
        )

        buildScene = newScene
        scene = newScene
    }

    func startLevel() {
        elapsedTime = 0
    }

    // MARK: - Piece Interaction

    func selectPiece(_ pieceId: String) {
        if selectedPieceId == pieceId {
            selectedPieceId = nil
            buildScene?.selectPiece(nil)
        } else {
            selectedPieceId = pieceId
            buildScene?.selectPiece(pieceId)

            // Make the piece visible in the scene for dragging
            let spawnPoint = CGPoint(x: 450, y: 100) // Bottom-center of scene
            buildScene?.spawnPiece(id: pieceId, at: spawnPoint)
        }
    }

    // MARK: - Timer

    func startTimer(duration: TimeInterval) {
        totalTime = duration
        remainingTime = duration
        tensionLevel = 0

        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    if self.remainingTime > 0 {
                        self.remainingTime -= 1
                        self.elapsedTime += 1
                        self.updateTension()
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

    private func updateTension() {
        guard totalTime > 0 else { return }
        let timeRatio = remainingTime / totalTime

        // Tension escalation thresholds
        if timeRatio <= 0.10 {
            tensionLevel = 1.0
            fireTensionNarration("10")
            buildScene?.showTensionPulse(intensity: 1.0)
        } else if timeRatio <= 0.25 {
            tensionLevel = 0.7
            fireTensionNarration("25")
            buildScene?.showTensionPulse(intensity: 0.7)
        } else if timeRatio <= 0.50 {
            tensionLevel = 0.3
            fireTensionNarration("50")
            buildScene?.showTensionPulse(intensity: 0.3)
        } else {
            tensionLevel = 0
            buildScene?.removeTensionEffects()
        }
    }

    private func fireTensionNarration(_ threshold: String) {
        guard !firedTensionThresholds.contains(threshold) else { return }
        firedTensionThresholds.insert(threshold)
        // Audio/narration will be wired in Phase 4
    }

    private func checkProgressMilestones() {
        guard totalPieces > 0 else { return }
        let percent = (piecesPlaced * 100) / totalPieces

        let milestones = [25, 50, 75, 100]
        for milestone in milestones {
            if percent >= milestone && !firedProgressMilestones.contains(milestone) {
                firedProgressMilestones.insert(milestone)
                // Progress narration will be wired in Phase 4
            }
        }
    }

    // MARK: - BuildSceneDelegate

    nonisolated func buildScene(_ scene: BuildScene, didPlacePiece pieceId: String, inSlot slotId: String) {
        Task { @MainActor in
            availablePieces.removeAll { $0.id == pieceId }
            piecesPlaced += 1
            selectedPieceId = nil
            checkProgressMilestones()
        }
    }

    nonisolated func buildScene(_ scene: BuildScene, didRejectPiece pieceId: String) {
        // Audio feedback will be added in Phase 4
    }

    nonisolated func buildScene(_ scene: BuildScene, didSelectPiece pieceId: String) {
        Task { @MainActor in
            if selectedPieceId == pieceId {
                selectedPieceId = nil
            } else {
                selectedPieceId = pieceId
            }
        }
    }

    nonisolated func buildScene(_ scene: BuildScene, didTapEmptyAt position: CGPoint) {
        // Easter egg detection will be added in Phase 5
    }

    nonisolated func buildSceneDidComplete(_ scene: BuildScene) {
        Task { @MainActor in
            isLevelComplete = true
            stopTimer()
            buildScene?.playCelebration()
        }
    }

    nonisolated func buildScene(_ scene: BuildScene, didDiscoverEasterEgg eggId: String) {
        // Easter egg handling will be added in Phase 5
    }

    // MARK: - Placeholder Level Generation

    private func generatePlaceholderLevel(_ levelId: Int) -> ([Slot], [Piece]) {
        // Generates a simple level with walls, roof, door for demonstration
        // Phase 3 will replace this with JSON-loaded levels
        let pieceConfigs: [(String, String, String, Int, Int, Int, Int)] = {
            switch levelId {
            case 1: // House
                return [
                    ("wall_left", "wall", "Left Wall", 1, 3, 1, 1),
                    ("wall_right", "wall", "Right Wall", 4, 3, 1, 1),
                    ("roof", "roof", "Roof", 1, 4, 4, 1),
                    ("door", "door", "Front Door", 2, 1, 1, 2),
                    ("window", "window", "Window", 3, 2, 1, 1),
                ]
            default:
                // Generic level with scaling pieces
                let count = min(5 + levelId, 14)
                return (0..<count).map { i in
                    let types = ["wall", "roof", "door", "window", "floor"]
                    let type = types[i % types.count]
                    return ("\(type)_\(i)", type, "\(type.capitalized) \(i + 1)", i % 6, (i / 6) + 1, 1, 1)
                }
            }
        }()

        let colors: [String: [String]] = [
            "wall": ["#FF6B6B", "#8B4513", "#A0522D", "#CD853F"],
            "roof": ["#D32F2F", "#1565C0", "#2E7D32", "#6A1B9A"],
            "door": ["#69DB7C", "#8B4513", "#FFD43B"],
            "window": ["#4DABF7", "#FFD43B", "#38D9A9"],
            "floor": ["#CD853F", "#8B8B8B", "#DEB887"],
        ]

        var slots: [Slot] = []
        var pieces: [Piece] = []

        for (id, type, label, x, y, w, h) in pieceConfigs {
            let slot = Slot(
                id: "slot_\(id)",
                gridPosition: CGPoint(x: CGFloat(x), y: CGFloat(y)),
                size: PieceSize(width: w, height: h),
                acceptsPieceType: type,
                label: label
            )
            slots.append(slot)

            let colorOptions = colors[type] ?? ["#CCCCCC"]
            let selectedColor = colorOptions.randomElement() ?? "#CCCCCC"

            let piece = Piece(
                id: id,
                type: type,
                label: label,
                size: PieceSize(width: w, height: h),
                color: selectedColor,
                texture: "default"
            )
            pieces.append(piece)
        }

        return (slots, pieces)
    }

    private func levelNameForId(_ id: Int) -> String {
        let names = [
            1: "Build a House", 2: "Build a Kitchen", 3: "Build a Garden",
            4: "Build a Playground", 5: "Build a School", 6: "Build a Fire Station",
            7: "Build a Hospital", 8: "Build a Farm", 9: "Build a Park",
            10: "Build a Zoo", 11: "Build a Library", 12: "Build a Beach",
            13: "Build a Castle", 14: "Build a Train Station", 15: "Build a Space Station",
            16: "Build an Airport", 17: "Build an Aquarium", 18: "Build a Spaceship",
            19: "Build a Town", 20: "Build a City"
        ]
        return names[id] ?? "Level \(id)"
    }

    private func narrationForLevel(_ id: Int) -> String {
        let narrations = [
            1: "Welcome, builder! Your first challenge awaits. Can you build the perfect house?",
            2: "Time to cook up something special! Build a kitchen from scratch!",
            3: "Nature calls! Create a beautiful garden with flowers and trees.",
            4: "Let's have some fun! Build a playground where kids will love to play.",
            5: "School's in session! Construct the perfect place to learn.",
            6: "Emergency! We need a fire station, stat! Can you build it?",
            7: "Healing begins here. Build a hospital to help those in need.",
            8: "Yeehaw! Time to build a farm with a big red barn!",
            9: "Fresh air and open spaces await. Build a beautiful park!",
            10: "Roar! The animals need a home. Build an amazing zoo!",
            11: "Shhhh! It's library time. Build a quiet place for books.",
            12: "Surf's up, builder! Create a perfect day at the beach!",
            13: "You dare enter the castle? Let's see if you can piece it together... mwahahaha!",
            14: "All aboard! Build a train station before the next train arrives!",
            15: "Houston, we have a builder! Assemble the space station!",
            16: "Flight departing soon! Build the airport before takeoff!",
            17: "Dive deep, builder! Create an underwater world of wonder!",
            18: "3... 2... 1... Build a spaceship before liftoff!",
            19: "It takes a village! Build an entire town from the ground up!",
            20: "The ultimate challenge! Build a whole city, master builder!"
        ]
        return narrations[id] ?? "Let's build something amazing!"
    }
}
