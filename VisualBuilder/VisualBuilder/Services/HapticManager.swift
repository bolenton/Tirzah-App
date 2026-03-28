import UIKit
import CoreHaptics

/// Manages all haptic feedback patterns for the game
class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?
    private(set) var isEnabled: Bool = true

    // UIKit feedback generators (simple haptics)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    init() {
        prepareGenerators()
        setupCoreHaptics()
    }

    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    private func setupCoreHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()

            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("CoreHaptics engine failed: \(error)")
        }
    }

    // MARK: - Configuration

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    // MARK: - Game Haptics

    /// Piece picked up from tray
    func piecePickup() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }

    /// Piece selected in tray (tap)
    func pieceSelect() {
        guard isEnabled else { return }
        selection.selectionChanged()
    }

    /// Piece deselected
    func pieceDeselect() {
        guard isEnabled else { return }
        selection.selectionChanged()
    }

    /// Piece correctly placed in a slot
    func placeCorrect() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }

    /// Piece rejected (wrong slot)
    func placeWrong() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }

    /// Piece hovering over a valid slot
    func hoverOverSlot() {
        guard isEnabled else { return }
        impactLight.impactOccurred(intensity: 0.5)
    }

    /// Level complete celebration
    func levelComplete() {
        guard isEnabled else { return }
        playPattern([
            (.heavy, 0.0),
            (.medium, 0.15),
            (.light, 0.3),
            (.medium, 0.45),
            (.heavy, 0.6)
        ])
    }

    /// Timer tick in last 10 seconds
    func timerTick(intensity: CGFloat) {
        guard isEnabled else { return }
        impactLight.impactOccurred(intensity: intensity)
    }

    /// Timer warning pulse (last 5 seconds)
    func timerWarningPulse() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }

    /// Timer expired
    func timerExpired() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    /// Easter egg discovered
    func easterEggFound() {
        guard isEnabled else { return }
        playPattern([
            (.light, 0.0),
            (.light, 0.1),
            (.medium, 0.2),
            (.heavy, 0.35),
            (.light, 0.5),
            (.light, 0.6)
        ])
    }

    /// Button tap
    func buttonTap() {
        guard isEnabled else { return }
        impactLight.impactOccurred(intensity: 0.6)
    }

    /// Player turn notification
    func playerTurn() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }

    /// Winner announcement
    func winnerCelebration() {
        guard isEnabled else { return }
        playPattern([
            (.heavy, 0.0),
            (.heavy, 0.2),
            (.heavy, 0.4),
            (.medium, 0.6),
            (.light, 0.7),
            (.light, 0.8),
            (.heavy, 1.0)
        ])
    }

    // MARK: - Pattern Player

    private func playPattern(_ events: [(UIImpactFeedbackGenerator.FeedbackStyle, TimeInterval)]) {
        for (style, delay) in events {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self, self.isEnabled else { return }
                switch style {
                case .light:
                    self.impactLight.impactOccurred()
                case .medium:
                    self.impactMedium.impactOccurred()
                case .heavy:
                    self.impactHeavy.impactOccurred()
                default:
                    self.impactMedium.impactOccurred()
                }
            }
        }
    }

    // MARK: - CoreHaptics Custom Pattern (Heartbeat for tension)

    func playHeartbeat(intensity: Float) {
        guard isEnabled, let engine else { return }

        do {
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)

            let beat1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpness], relativeTime: 0)
            let beat2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpness], relativeTime: 0.15)

            let pattern = try CHHapticPattern(events: [beat1, beat2], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Fallback to UIKit haptics
            impactHeavy.impactOccurred()
        }
    }
}
