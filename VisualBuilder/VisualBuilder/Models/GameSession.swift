import Foundation

@MainActor
class GameSession: ObservableObject {
    let mode: GameMode
    @Published var players: [Player]
    @Published var currentPlayerIndex: Int = 0
    @Published var currentLevelId: Int = 1
    @Published var levelResults: [Int: [LevelResult]] = [:] // levelId -> results per player
    @Published var isSessionActive: Bool = true
    @Published var variantSeed: UInt64

    struct LevelResult: Identifiable {
        let id = UUID()
        let playerId: UUID
        let playerName: String
        let completionTime: TimeInterval?
        let didComplete: Bool
        var pointsAwarded: Int = 0
    }

    init(mode: GameMode, players: [Player]) {
        self.mode = mode
        self.players = players
        self.variantSeed = UInt64.random(in: 0...UInt64.max)
    }

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }

    var playerCount: Int {
        players.count
    }

    var isMultiplayer: Bool {
        players.count > 1
    }

    func recordResult(playerId: UUID, time: TimeInterval?, didComplete: Bool) {
        let playerName = players.first { $0.id == playerId }?.name ?? "Unknown"
        let result = LevelResult(
            playerId: playerId,
            playerName: playerName,
            completionTime: time,
            didComplete: didComplete
        )

        if levelResults[currentLevelId] == nil {
            levelResults[currentLevelId] = []
        }
        levelResults[currentLevelId]?.append(result)
    }

    func advanceToNextPlayer() -> Bool {
        if currentPlayerIndex + 1 < players.count {
            currentPlayerIndex += 1
            return true
        }
        return false
    }

    func awardPointsForCurrentLevel() {
        guard var results = levelResults[currentLevelId] else { return }

        // Sort by completion time (completed players first, then by time)
        let sorted = results.enumerated().sorted { a, b in
            if a.element.didComplete && !b.element.didComplete { return true }
            if !a.element.didComplete && b.element.didComplete { return false }
            let timeA = a.element.completionTime ?? .infinity
            let timeB = b.element.completionTime ?? .infinity
            return timeA < timeB
        }

        let pointTable = [3, 2, 1, 0]
        for (rank, item) in sorted.enumerated() {
            let points = rank < pointTable.count ? pointTable[rank] : 0
            results[item.offset].pointsAwarded = points

            if let playerIdx = players.firstIndex(where: { $0.id == item.element.playerId }) {
                players[playerIdx].recordLevelCompletion(
                    levelId: currentLevelId,
                    time: item.element.completionTime ?? 0,
                    points: points
                )
            }
        }
        levelResults[currentLevelId] = results
    }

    func advanceToNextLevel() {
        awardPointsForCurrentLevel()
        currentPlayerIndex = 0
        currentLevelId += 1
    }

    func endSession() {
        if levelResults[currentLevelId] != nil {
            awardPointsForCurrentLevel()
        }
        isSessionActive = false
    }

    var winner: Player? {
        players.max(by: { $0.totalScore < $1.totalScore })
    }

    var sortedPlayersByScore: [Player] {
        players.sorted { $0.totalScore > $1.totalScore }
    }
}
