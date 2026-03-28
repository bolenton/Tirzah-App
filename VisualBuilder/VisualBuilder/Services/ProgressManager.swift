import Foundation
import SwiftUI

/// Central manager for persisting player progress, settings, and easter egg discoveries
class ProgressManager {
    static let shared = ProgressManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let completedLevels = "completedLevels"
        static let bestTimes = "bestTimes"
        static let starsEarned = "starsEarned"
        static let easterEggsFound = "easterEggsFound"
        static let totalGamesPlayed = "totalGamesPlayed"
        static let masterBuilderLevels = "masterBuilderLevels"
    }

    // MARK: - Level Progress

    func markLevelCompleted(_ levelId: Int) {
        var levels = completedLevels
        levels.insert(levelId)
        defaults.set(Array(levels), forKey: Keys.completedLevels)
    }

    func recordBestTime(levelId: Int, time: TimeInterval) {
        var times = bestTimes
        if let existing = times[levelId], time >= existing {
            return // Only save if it's a new best
        }
        times[levelId] = time
        if let data = try? JSONEncoder().encode(times) {
            defaults.set(data, forKey: Keys.bestTimes)
        }
    }

    func recordStars(levelId: Int, stars: Int) {
        var allStars = starsEarned
        if let existing = allStars[levelId], stars <= existing {
            return // Only save if more stars
        }
        allStars[levelId] = stars
        if let data = try? JSONEncoder().encode(allStars) {
            defaults.set(data, forKey: Keys.starsEarned)
        }
    }

    func incrementGamesPlayed() {
        defaults.set(totalGamesPlayed + 1, forKey: Keys.totalGamesPlayed)
    }

    // MARK: - Easter Eggs

    func discoverEasterEgg(_ eggId: String) {
        var eggs = easterEggsFound
        eggs.insert(eggId)
        defaults.set(Array(eggs), forKey: Keys.easterEggsFound)
    }

    func markMasterBuilder(levelId: Int) {
        var levels = masterBuilderLevels
        levels.insert(levelId)
        defaults.set(Array(levels), forKey: Keys.masterBuilderLevels)
    }

    // MARK: - Queries

    var completedLevels: Set<Int> {
        Set(defaults.array(forKey: Keys.completedLevels) as? [Int] ?? [])
    }

    var bestTimes: [Int: TimeInterval] {
        guard let data = defaults.data(forKey: Keys.bestTimes),
              let times = try? JSONDecoder().decode([Int: TimeInterval].self, from: data) else {
            return [:]
        }
        return times
    }

    var starsEarned: [Int: Int] {
        guard let data = defaults.data(forKey: Keys.starsEarned),
              let stars = try? JSONDecoder().decode([Int: Int].self, from: data) else {
            return [:]
        }
        return stars
    }

    var easterEggsFound: Set<String> {
        Set(defaults.stringArray(forKey: Keys.easterEggsFound) ?? [])
    }

    var totalGamesPlayed: Int {
        defaults.integer(forKey: Keys.totalGamesPlayed)
    }

    var masterBuilderLevels: Set<Int> {
        Set(defaults.array(forKey: Keys.masterBuilderLevels) as? [Int] ?? [])
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        if levelId <= 1 { return true }
        return completedLevels.contains(levelId - 1)
    }

    func starsForLevel(_ levelId: Int) -> Int {
        starsEarned[levelId] ?? 0
    }

    func bestTimeForLevel(_ levelId: Int) -> TimeInterval? {
        bestTimes[levelId]
    }

    /// Calculate stars based on completion time vs challenge time
    static func calculateStars(completionTime: TimeInterval, challengeTime: TimeInterval) -> Int {
        let ratio = completionTime / challengeTime
        if ratio <= 0.33 { return 3 }
        if ratio <= 0.66 { return 2 }
        return 1
    }
}
