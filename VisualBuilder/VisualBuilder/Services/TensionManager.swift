import Foundation
import Combine

/// Coordinates all tension escalation effects for Challenge Mode:
/// visual pulse, audio tempo, haptic heartbeat, narration
class TensionManager {
    static let shared = TensionManager()

    private let audio = AudioManager.shared
    private let haptic = HapticManager.shared
    private let narration = NarrationEngine.shared

    private var lastTickSecond: Int = -1
    private var firedThresholds: Set<String> = []

    struct TensionState {
        let timeRatio: Double       // 0.0 = expired, 1.0 = full time
        let remainingSeconds: Int
        let totalSeconds: Int
    }

    // MARK: - Reset

    func reset() {
        lastTickSecond = -1
        firedThresholds.removeAll()
        audio.setBackgroundMusicTempo(1.0)
    }

    // MARK: - Update (called every second from timer)

    /// Process tension effects based on current time state.
    /// Returns the tension intensity (0-1) for visual effects.
    func update(state: TensionState, narrationScripts: NarrationScripts?, seed: UInt64) -> CGFloat {
        let ratio = state.timeRatio
        let seconds = state.remainingSeconds

        // Tick sound in last 10 seconds
        if seconds <= 10 && seconds > 0 && seconds != lastTickSecond {
            lastTickSecond = seconds
            audio.playTimerTick()

            // Haptic in last 5 seconds
            if seconds <= 5 {
                haptic.timerWarningPulse()
            } else {
                haptic.timerTick(intensity: CGFloat(11 - seconds) / 10.0)
            }
        }

        // Heartbeat in last 3 seconds
        if seconds <= 3 && seconds > 0 {
            haptic.playHeartbeat(intensity: Float(4 - seconds) / 3.0)
            audio.play(.heartbeat)
        }

        // Tension thresholds
        if ratio <= 0.10 && !firedThresholds.contains("10") {
            firedThresholds.insert("10")
            audio.setBackgroundMusicTempo(1.5)
            if let scripts = narrationScripts {
                narration.speakTension(from: scripts, at: "10", seed: seed)
            }
            return 1.0
        }

        if ratio <= 0.25 && !firedThresholds.contains("25") {
            firedThresholds.insert("25")
            audio.play(.timerWarning)
            audio.setBackgroundMusicTempo(1.3)
            if let scripts = narrationScripts {
                narration.speakTension(from: scripts, at: "25", seed: seed)
            }
            return 0.7
        }

        if ratio <= 0.50 && !firedThresholds.contains("50") {
            firedThresholds.insert("50")
            audio.setBackgroundMusicTempo(1.15)
            if let scripts = narrationScripts {
                narration.speakTension(from: scripts, at: "50", seed: seed)
            }
            return 0.3
        }

        // Timer expired
        if seconds <= 0 && !firedThresholds.contains("expired") {
            firedThresholds.insert("expired")
            audio.play(.timerExpired)
            haptic.timerExpired()
            if let scripts = narrationScripts {
                narration.speakTension(from: scripts, at: "expired", seed: seed)
            }
            return 0
        }

        // Return current tension intensity
        if ratio <= 0.10 { return 1.0 }
        if ratio <= 0.25 { return 0.7 }
        if ratio <= 0.50 { return 0.3 }
        return 0
    }
}
