import SwiftUI

enum GameMode: String, Codable {
    case freePlay = "Free Play"
    case challenge = "Challenge"
}

enum AppRoute: Hashable {
    case playerSetup(mode: GameMode)
    case levelSelect
    case game(levelId: Int)
    case settings

    func hash(into hasher: inout Hasher) {
        switch self {
        case .playerSetup(let mode):
            hasher.combine("playerSetup")
            hasher.combine(mode.rawValue)
        case .levelSelect:
            hasher.combine("levelSelect")
        case .game(let levelId):
            hasher.combine("game")
            hasher.combine(levelId)
        case .settings:
            hasher.combine("settings")
        }
    }

    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.playerSetup(let a), .playerSetup(let b)):
            return a == b
        case (.levelSelect, .levelSelect):
            return true
        case (.game(let a), .game(let b)):
            return a == b
        case (.settings, .settings):
            return true
        default:
            return false
        }
    }
}

@MainActor
class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var currentMode: GameMode = .freePlay
    @Published var gameSession: GameSession?

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func startGame(mode: GameMode, players: [Player]) {
        currentMode = mode
        gameSession = GameSession(mode: mode, players: players)
        navigate(to: .levelSelect)
    }

    func startLevel(_ levelId: Int) {
        navigate(to: .game(levelId: levelId))
    }
}
