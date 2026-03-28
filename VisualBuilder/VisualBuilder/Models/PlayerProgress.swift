import Foundation
import SwiftUI

@MainActor
class PlayerProgress: ObservableObject {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let completedLevels = "completedLevels"
        static let bestTimes = "bestTimes"
        static let starsEarned = "starsEarned"
        static let easterEggsFound = "easterEggsFound"
        static let totalGamesPlayed = "totalGamesPlayed"
    }

    @Published var completedLevels: Set<Int> {
        didSet { save() }
    }

    @Published var bestTimes: [Int: TimeInterval] {
        didSet { save() }
    }

    @Published var starsEarned: [Int: Int] {
        didSet { save() }
    }

    @Published var easterEggsFound: Set<String> {
        didSet { save() }
    }

    @Published var totalGamesPlayed: Int {
        didSet { defaults.set(totalGamesPlayed, forKey: Keys.totalGamesPlayed) }
    }

    init() {
        // Load from UserDefaults
        let levelArray = defaults.array(forKey: Keys.completedLevels) as? [Int] ?? []
        self.completedLevels = Set(levelArray)

        if let timeData = defaults.data(forKey: Keys.bestTimes),
           let times = try? JSONDecoder().decode([Int: TimeInterval].self, from: timeData) {
            self.bestTimes = times
        } else {
            self.bestTimes = [:]
        }

        if let starData = defaults.data(forKey: Keys.starsEarned),
           let stars = try? JSONDecoder().decode([Int: Int].self, from: starData) {
            self.starsEarned = stars
        } else {
            self.starsEarned = [:]
        }

        let eggArray = defaults.stringArray(forKey: Keys.easterEggsFound) ?? []
        self.easterEggsFound = Set(eggArray)

        self.totalGamesPlayed = defaults.integer(forKey: Keys.totalGamesPlayed)
    }

    func recordLevelCompletion(levelId: Int, time: TimeInterval, stars: Int) {
        completedLevels.insert(levelId)

        if let existingBest = bestTimes[levelId] {
            if time < existingBest {
                bestTimes[levelId] = time
            }
        } else {
            bestTimes[levelId] = time
        }

        if let existingStars = starsEarned[levelId] {
            if stars > existingStars {
                starsEarned[levelId] = stars
            }
        } else {
            starsEarned[levelId] = stars
        }
    }

    func discoverEasterEgg(_ eggId: String) {
        easterEggsFound.insert(eggId)
    }

    var totalEasterEggsFound: Int {
        easterEggsFound.count
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        if levelId == 1 { return true }
        return completedLevels.contains(levelId - 1)
    }

    private func save() {
        defaults.set(Array(completedLevels), forKey: Keys.completedLevels)
        defaults.set(Array(easterEggsFound), forKey: Keys.easterEggsFound)

        if let timeData = try? JSONEncoder().encode(bestTimes) {
            defaults.set(timeData, forKey: Keys.bestTimes)
        }
        if let starData = try? JSONEncoder().encode(starsEarned) {
            defaults.set(starData, forKey: Keys.starsEarned)
        }
    }
}
