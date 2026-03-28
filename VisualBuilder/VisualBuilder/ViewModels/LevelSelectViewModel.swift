import SwiftUI

@MainActor
class LevelSelectViewModel: ObservableObject {
    @Published var levels: [LevelPreview] = []

    init() {
        loadLevels()
    }

    private func loadLevels() {
        // Level metadata — will be loaded from JSON in Phase 3
        let levelData: [(Int, String, Int)] = [
            (1, "Build a House", 5),
            (2, "Build a Kitchen", 7),
            (3, "Build a Garden", 8),
            (4, "Build a Playground", 6),
            (5, "Build a School", 8),
            (6, "Build a Fire Station", 7),
            (7, "Build a Hospital", 8),
            (8, "Build a Farm", 10),
            (9, "Build a Park", 9),
            (10, "Build a Zoo", 10),
            (11, "Build a Library", 8),
            (12, "Build a Beach", 9),
            (13, "Build a Castle", 10),
            (14, "Build a Train Station", 9),
            (15, "Build a Space Station", 10),
            (16, "Build an Airport", 11),
            (17, "Build an Aquarium", 10),
            (18, "Build a Spaceship", 10),
            (19, "Build a Town", 12),
            (20, "Build a City", 14),
        ]

        levels = levelData.map { id, name, pieces in
            LevelPreview(
                id: id,
                name: name,
                pieceCount: pieces,
                isUnlocked: id <= 1, // Only level 1 unlocked initially
                starsEarned: 0
            )
        }
    }
}
