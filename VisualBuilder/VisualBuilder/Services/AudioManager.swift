import AVFoundation
import Combine

/// Manages all game audio: sound effects, background music, and coordinates with NarrationEngine
class AudioManager {
    static let shared = AudioManager()

    private var audioEngine: AVAudioEngine?
    private var playerNodes: [String: AVAudioPlayerNode] = [:]
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private var backgroundPlayer: AVAudioPlayer?

    private(set) var isEnabled: Bool = true
    private(set) var masterVolume: Float = 0.8

    // Sound categories
    enum SoundCategory {
        case placement   // Correct/wrong piece placement
        case ui          // Button taps, navigation
        case celebration // Level complete
        case timer       // Tick, warning
        case easterEgg   // Hidden discoveries
    }

    // Predefined sound identifiers
    enum Sound: String {
        case placeCorrect = "place_correct"
        case placeWrong = "place_wrong"
        case pieceSelect = "piece_select"
        case pieceDeselect = "piece_deselect"
        case levelComplete = "level_complete"
        case timerTick = "timer_tick"
        case timerWarning = "timer_warning"
        case timerExpired = "timer_expired"
        case buttonTap = "button_tap"
        case easterEggFound = "easter_egg_found"
        case playerTurnStart = "player_turn"
        case scoreReveal = "score_reveal"
        case winnerFanfare = "winner_fanfare"
        case heartbeat = "heartbeat"
    }

    init() {
        setupAudioSession()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    /// Pre-load audio buffers for low-latency playback
    func preloadSounds() {
        // In production, these would load actual .wav files from the bundle
        // For now, we use system sounds as placeholders
        let sounds: [Sound] = [
            .placeCorrect, .placeWrong, .pieceSelect, .levelComplete,
            .timerTick, .timerWarning, .buttonTap, .easterEggFound
        ]

        for sound in sounds {
            if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav", subdirectory: "Sounds") {
                loadBuffer(from: url, key: sound.rawValue)
            }
        }
    }

    private func loadBuffer(from url: URL, key: String) {
        do {
            let file = try AVAudioFile(forReading: url)
            guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                             sampleRate: file.fileFormat.sampleRate,
                                             channels: file.fileFormat.channelCount,
                                             interleaved: false) else { return }
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
            try file.read(into: buffer)
            audioBuffers[key] = buffer
        } catch {
            print("Failed to load audio \(key): \(error)")
        }
    }

    // MARK: - Playback

    /// Play a sound effect
    func play(_ sound: Sound) {
        guard isEnabled else { return }

        // Use system sound as fallback when audio files aren't available
        playSystemSound(for: sound)
    }

    /// Play a system sound as placeholder
    private func playSystemSound(for sound: Sound) {
        let soundId: UInt32
        switch sound {
        case .placeCorrect:
            soundId = 1057 // Tink
        case .placeWrong:
            soundId = 1053 // Tock
        case .pieceSelect:
            soundId = 1104 // Click
        case .pieceDeselect:
            soundId = 1105 // Click
        case .levelComplete:
            soundId = 1025 // Fanfare
        case .timerTick:
            soundId = 1103 // Tick
        case .timerWarning:
            soundId = 1005 // Alarm
        case .timerExpired:
            soundId = 1006 // Alert
        case .buttonTap:
            soundId = 1104 // Click
        case .easterEggFound:
            soundId = 1026 // Chime
        case .playerTurnStart:
            soundId = 1025 // Tone
        case .scoreReveal:
            soundId = 1057 // Tink
        case .winnerFanfare:
            soundId = 1025 // Celebrate
        case .heartbeat:
            soundId = 1052 // Low tone
        }
        AudioServicesPlaySystemSound(SystemSoundID(soundId))
    }

    // MARK: - Background Music

    func startBackgroundMusic(theme: String) {
        guard isEnabled else { return }

        // Will load theme-specific music when audio assets are available
        if let url = Bundle.main.url(forResource: "bg_\(theme)", withExtension: "mp3", subdirectory: "Sounds") {
            do {
                backgroundPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundPlayer?.numberOfLoops = -1
                backgroundPlayer?.volume = masterVolume * 0.3
                backgroundPlayer?.play()
            } catch {
                print("Background music failed: \(error)")
            }
        }
    }

    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }

    func setBackgroundMusicTempo(_ multiplier: Float) {
        backgroundPlayer?.rate = multiplier
    }

    // MARK: - Configuration

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stopBackgroundMusic()
        }
    }

    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0, min(1, volume))
        backgroundPlayer?.volume = masterVolume * 0.3
    }

    // MARK: - Challenge Mode Audio Escalation

    func playTensionAudio(at timeRatio: Double) {
        guard isEnabled else { return }

        if timeRatio <= 0.10 {
            // Heartbeat in final 10%
            play(.heartbeat)
            setBackgroundMusicTempo(1.5)
        } else if timeRatio <= 0.25 {
            play(.timerWarning)
            setBackgroundMusicTempo(1.3)
        } else if timeRatio <= 0.50 {
            setBackgroundMusicTempo(1.15)
        }
    }

    func playTimerTick() {
        guard isEnabled else { return }
        play(.timerTick)
    }
}
