import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var totalScore: Int
    var levelTimes: [Int: TimeInterval] // levelId -> completion time
    var levelScores: [Int: Int] // levelId -> points earned
    var easterEggsFound: Set<String>

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.totalScore = 0
        self.levelTimes = [:]
        self.levelScores = [:]
        self.easterEggsFound = []
    }

    mutating func recordLevelCompletion(levelId: Int, time: TimeInterval, points: Int) {
        levelTimes[levelId] = time
        levelScores[levelId] = points
        totalScore += points
    }

    mutating func discoverEasterEgg(_ eggId: String) {
        easterEggsFound.insert(eggId)
    }
}
