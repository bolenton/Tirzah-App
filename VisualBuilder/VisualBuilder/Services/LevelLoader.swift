import Foundation

/// Loads and parses level JSON files from the app bundle
class LevelLoader {
    static let shared = LevelLoader()

    private var levelCache: [Int: Level] = [:]

    /// Load a specific level by ID
    func loadLevel(_ levelId: Int) -> Level? {
        if let cached = levelCache[levelId] {
            return cached
        }

        let filename = String(format: "level_%02d", levelId)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Levels") ??
              Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Level file not found: \(filename).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let level = try JSONDecoder().decode(Level.self, from: data)
            levelCache[levelId] = level
            return level
        } catch {
            print("Failed to decode level \(levelId): \(error)")
            return nil
        }
    }

    /// Load all level metadata for the level select screen
    func loadAllLevelPreviews() -> [LevelSummary] {
        var summaries: [LevelSummary] = []
        for id in 1...20 {
            if let level = loadLevel(id) {
                summaries.append(LevelSummary(
                    id: level.id,
                    name: level.name,
                    pieceCount: level.pieces.count,
                    challengeTime: level.challengeTime
                ))
            }
        }
        return summaries
    }

    /// Clear the cache (e.g., on memory warning)
    func clearCache() {
        levelCache.removeAll()
    }
}

struct LevelSummary {
    let id: Int
    let name: String
    let pieceCount: Int
    let challengeTime: TimeInterval
}
