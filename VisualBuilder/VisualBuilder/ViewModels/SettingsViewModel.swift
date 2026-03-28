import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    // Accessibility
    @AppStorage("highContrastMode") var highContrastMode: Bool = false
    @AppStorage("largePiecesMode") var largePiecesMode: Bool = false
    @AppStorage("hapticFeedback") var hapticFeedback: Bool = true

    // Audio
    @AppStorage("soundEffects") var soundEffects: Bool = true
    @AppStorage("narrationEnabled") var narrationEnabled: Bool = true
    @AppStorage("backgroundMusic") var backgroundMusic: Bool = true
    @AppStorage("masterVolume") var masterVolume: Double = 0.8

    // Game
    @AppStorage("showPieceHints") var showPieceHints: Bool = true
    @AppStorage("autoSnapPieces") var autoSnapPieces: Bool = true

    // Stats (read from PlayerProgress)
    var levelsCompleted: Int {
        UserDefaults.standard.array(forKey: "completedLevels")?.count ?? 0
    }

    var totalEasterEggsFound: Int {
        UserDefaults.standard.stringArray(forKey: "easterEggsFound")?.count ?? 0
    }

    var gamesPlayed: Int {
        UserDefaults.standard.integer(forKey: "totalGamesPlayed")
    }
}
