import Foundation
import AVFoundation

/// Manages cinematic narration using text-to-speech with per-level voice styles
class NarrationEngine: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = NarrationEngine()

    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: (() -> Void)?
    private var isEnabled: Bool = true

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    /// Speak a narration line with the specified voice style
    func speak(_ line: NarrationLine, completion: (() -> Void)? = nil) {
        guard isEnabled else {
            completion?()
            return
        }

        stop()
        completionHandler = completion

        let utterance = AVSpeechUtterance(string: line.text)
        utterance.rate = line.rate
        utterance.pitchMultiplier = line.pitchMultiplier
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.3
        utterance.postUtteranceDelay = 0.2

        // Select voice based on style
        if let voice = voiceForStyle(line.voiceStyle) {
            utterance.voice = voice
        }

        synthesizer.speak(utterance)
    }

    /// Speak a simple text string with default voice
    func speak(_ text: String, rate: Float = 0.5, completion: (() -> Void)? = nil) {
        let line = NarrationLine(text: text, voiceStyle: "default", rate: rate, pitchMultiplier: 1.0)
        speak(line, completion: completion)
    }

    /// Stop any currently playing narration
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        completionHandler = nil
    }

    /// Enable/disable narration
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stop()
        }
    }

    // MARK: - Voice Selection

    private func voiceForStyle(_ style: String) -> AVSpeechSynthesisVoice? {
        // Map voice styles to available system voices
        // Different locales give different "character" feels
        switch style {
        case "friendly_narrator", "excited_mentor", "wise_narrator":
            return AVSpeechSynthesisVoice(language: "en-US")
        case "warm_chef":
            return AVSpeechSynthesisVoice(language: "en-GB")
        case "peaceful_nature", "relaxed_ranger":
            return AVSpeechSynthesisVoice(language: "en-AU")
        case "excited_kid":
            return AVSpeechSynthesisVoice(language: "en-US")
        case "wise_teacher", "whispering_librarian":
            return AVSpeechSynthesisVoice(language: "en-GB")
        case "urgent_dispatcher", "train_conductor", "pilot_captain":
            return AVSpeechSynthesisVoice(language: "en-US")
        case "caring_doctor":
            return AVSpeechSynthesisVoice(language: "en-GB")
        case "country_drawl":
            return AVSpeechSynthesisVoice(language: "en-US")
        case "safari_guide":
            return AVSpeechSynthesisVoice(language: "en-ZA")
        case "surfer_dude":
            return AVSpeechSynthesisVoice(language: "en-AU")
        case "spooky_villain":
            return AVSpeechSynthesisVoice(language: "en-GB")
        case "mission_control", "nasa_countdown":
            return AVSpeechSynthesisVoice(language: "en-US")
        case "deep_sea_diver":
            return AVSpeechSynthesisVoice(language: "en-AU")
        case "mayor_speech", "epic_movie_trailer":
            return AVSpeechSynthesisVoice(language: "en-US")
        default:
            return AVSpeechSynthesisVoice(language: "en-US")
        }
    }

    // MARK: - Progress & Tension Narration

    /// Speak a progress milestone narration
    func speakProgress(from scripts: NarrationScripts, at percent: Int, seed: UInt64) {
        guard isEnabled else { return }
        if let text = NarrationScript.progressNarration(from: scripts, at: percent, seed: seed) {
            speak(text, rate: 0.52)
        }
    }

    /// Speak a tension threshold narration
    func speakTension(from scripts: NarrationScripts, at threshold: String, seed: UInt64) {
        guard isEnabled else { return }
        if let text = NarrationScript.tensionNarration(from: scripts, at: threshold, seed: seed) {
            speak(text, rate: 0.55)
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completionHandler?()
        completionHandler = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completionHandler = nil
    }
}
