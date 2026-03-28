import UIKit

/// Manages VoiceOver announcements and accessibility state for the game
class AccessibilityManager {
    static let shared = AccessibilityManager()

    // MARK: - VoiceOver Announcements

    /// Announce a message via VoiceOver
    func announce(_ message: String, afterDelay: TimeInterval = 0) {
        if afterDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + afterDelay) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        } else {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    /// Announce screen change (new screen appeared)
    func announceScreenChange(_ screenName: String) {
        UIAccessibility.post(notification: .screenChanged, argument: screenName)
    }

    /// Announce layout change (elements changed on current screen)
    func announceLayoutChange(_ message: String? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: message)
    }

    // MARK: - Game Event Announcements

    func announcePieceSelected(_ pieceName: String, pieceType: String) {
        announce("\(pieceName) selected. Tap a \(pieceType) slot to place it, or drag it onto the grid.")
    }

    func announcePieceDeselected() {
        announce("Piece deselected.")
    }

    func announcePiecePlaced(_ pieceName: String, slotName: String, remaining: Int) {
        if remaining > 0 {
            announce("\(pieceName) placed in \(slotName). \(remaining) piece\(remaining == 1 ? "" : "s") remaining.")
        } else {
            announce("\(pieceName) placed in \(slotName). All pieces placed! Level complete!")
        }
    }

    func announcePieceRejected(_ pieceName: String) {
        announce("Cannot place \(pieceName) here. Try a different slot.")
    }

    func announceLevelStart(_ levelName: String) {
        announceScreenChange("Now playing: \(levelName)")
    }

    func announceLevelComplete(levelId: Int, time: TimeInterval?) {
        if let time {
            let seconds = Int(time)
            announce("Level \(levelId) complete! Finished in \(seconds) seconds.")
        } else {
            announce("Level \(levelId) complete! Great job!")
        }
    }

    func announceTimerUpdate(remaining: Int) {
        // Only announce at key moments to avoid spam
        switch remaining {
        case 60:
            announce("One minute remaining.")
        case 30:
            announce("Thirty seconds remaining.")
        case 10:
            announce("Ten seconds remaining!")
        case 5:
            announce("Five seconds!")
        case 0:
            announce("Time's up!")
        default:
            break
        }
    }

    func announcePlayerTurn(_ playerName: String, playerNumber: Int) {
        announceScreenChange("\(playerName), it's your turn! Player \(playerNumber).")
    }

    func announceScoreboard(winner: String, score: Int) {
        announce("\(winner) wins with \(score) points!")
    }

    func announceEasterEgg(_ description: String) {
        announce("Easter egg found! \(description)", afterDelay: 0.5)
    }

    func announceProgress(percent: Int) {
        announce("\(percent) percent complete.")
    }

    // MARK: - State Queries

    var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }

    var isBoldTextEnabled: Bool {
        UIAccessibility.isBoldTextEnabled
    }

    var prefersCrossFadeTransitions: Bool {
        UIAccessibility.prefersCrossFadeTransitions
    }
}
