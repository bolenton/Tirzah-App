import Foundation

/// Protocol for easter egg event callbacks
protocol EasterEggDelegate: AnyObject {
    func easterEggDiscovered(_ egg: EasterEggDefinition)
}

/// Detects and manages easter egg discovery across all types:
/// tap, sequence, speed, and exploration
class EasterEggManager {
    static let shared = EasterEggManager()

    weak var delegate: EasterEggDelegate?

    // Level state
    private var currentLevelEggs: [EasterEggDefinition] = []
    private var discoveredInSession: Set<String> = []

    // Tap tracking: position key -> tap count
    private var tapCounts: [String: Int] = [:]

    // Sequence tracking: ordered list of placed piece IDs
    private var placementSequence: [String] = []

    // Timing
    private var levelStartTime: Date?

    // MARK: - Level Setup

    func setupForLevel(eggs: [EasterEggDefinition]) {
        currentLevelEggs = eggs
        tapCounts.removeAll()
        placementSequence.removeAll()
        levelStartTime = Date()
        discoveredInSession.removeAll()
    }

    // MARK: - Event Tracking

    /// Track a tap at a position (for tap-type easter eggs)
    func trackTap(at gridX: Int, gridY: Int) {
        let key = "\(gridX)_\(gridY)"
        tapCounts[key, default: 0] += 1

        // Check tap-type eggs
        for egg in currentLevelEggs where egg.type == "tap" {
            guard !discoveredInSession.contains(egg.id) else { continue }
            guard let triggerPos = egg.trigger.position,
                  let tapsRequired = egg.trigger.tapsRequired else { continue }

            let eggKey = "\(triggerPos.x)_\(triggerPos.y)"
            if key == eggKey, tapCounts[key]! >= tapsRequired {
                discover(egg)
            }
        }
    }

    /// Track a piece placement (for sequence-type easter eggs)
    func trackPiecePlaced(_ pieceId: String) {
        placementSequence.append(pieceId)

        // Check sequence-type eggs
        for egg in currentLevelEggs where egg.type == "sequence" {
            guard !discoveredInSession.contains(egg.id) else { continue }
            guard let requiredSequence = egg.trigger.pieceSequence else { continue }

            if placementSequence == requiredSequence {
                discover(egg)
            }
        }
    }

    /// Check speed-type easter eggs when level completes
    func checkSpeedEggs(completionTime: TimeInterval) {
        for egg in currentLevelEggs where egg.type == "speed" {
            guard !discoveredInSession.contains(egg.id) else { continue }
            guard let timeThreshold = egg.trigger.completionTimeUnder else { continue }

            if completionTime < timeThreshold {
                discover(egg)
            }
        }
    }

    /// Track a piece dragged to unusual location (for exploration-type eggs)
    func trackExploration(pieceId: String, at gridX: Int, gridY: Int) {
        for egg in currentLevelEggs where egg.type == "exploration" {
            guard !discoveredInSession.contains(egg.id) else { continue }
            guard let triggerPos = egg.trigger.position else { continue }

            if gridX == triggerPos.x && gridY == triggerPos.y {
                discover(egg)
            }
        }
    }

    // MARK: - Discovery

    private func discover(_ egg: EasterEggDefinition) {
        guard !discoveredInSession.contains(egg.id) else { return }
        discoveredInSession.insert(egg.id)

        // Notify delegate
        delegate?.easterEggDiscovered(egg)

        // Play feedback
        AudioManager.shared.play(.easterEggFound)
        HapticManager.shared.easterEggFound()
        AccessibilityManager.shared.announceEasterEgg(egg.reward.content)

        // Persist discovery
        ProgressManager.shared.discoverEasterEgg(egg.id)
    }

    // MARK: - Query

    var discoveredCount: Int {
        discoveredInSession.count
    }

    func wasDiscoveredInSession(_ eggId: String) -> Bool {
        discoveredInSession.contains(eggId)
    }

    // MARK: - Catalog

    /// Load the full easter egg catalog for the tracker UI
    static func loadCatalog() -> [EasterEgg] {
        guard let url = Bundle.main.url(forResource: "easter_egg_catalog", withExtension: "json", subdirectory: "EasterEggs") ??
              Bundle.main.url(forResource: "easter_egg_catalog", withExtension: "json") else {
            return []
        }

        struct Catalog: Codable {
            let eggs: [EasterEgg]
        }

        do {
            let data = try Data(contentsOf: url)
            let catalog = try JSONDecoder().decode(Catalog.self, from: data)
            return catalog.eggs
        } catch {
            return []
        }
    }
}
