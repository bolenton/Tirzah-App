import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var settings: SettingsViewModel

    var body: some View {
        ZStack {
            Color.vbBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vbAccent)
                        .accessibilityAddTraits(.isHeader)
                        .padding(.top, 20)

                    // Accessibility Section
                    SettingsSection(title: "Accessibility", icon: "accessibility") {
                        SettingsToggle(
                            title: "High Contrast Mode",
                            description: "Bold outlines and simplified colors for better visibility",
                            isOn: $settings.highContrastMode
                        )

                        SettingsToggle(
                            title: "Large Pieces",
                            description: "Makes building pieces even larger for easier targeting",
                            isOn: $settings.largePiecesMode
                        )

                        SettingsToggle(
                            title: "Haptic Feedback",
                            description: "Vibration feedback when placing pieces",
                            isOn: $settings.hapticFeedback
                        )
                    }

                    // Audio Section
                    SettingsSection(title: "Audio", icon: "speaker.wave.3.fill") {
                        SettingsToggle(
                            title: "Sound Effects",
                            description: "Placement sounds and UI feedback",
                            isOn: $settings.soundEffects
                        )

                        SettingsToggle(
                            title: "Level Narration",
                            description: "Cinematic voice narration at the start of each level",
                            isOn: $settings.narrationEnabled
                        )

                        SettingsToggle(
                            title: "Background Music",
                            description: "Ambient music during gameplay",
                            isOn: $settings.backgroundMusic
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Master Volume")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.vbText)

                            Slider(value: $settings.masterVolume, in: 0...1)
                                .tint(Color.vbAccent)
                                .accessibilityLabel("Master volume")
                                .accessibilityValue("\(Int(settings.masterVolume * 100)) percent")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }

                    // Game Section
                    SettingsSection(title: "Game", icon: "gamecontroller.fill") {
                        SettingsToggle(
                            title: "Show Piece Hints",
                            description: "Highlight compatible slots when a piece is selected",
                            isOn: $settings.showPieceHints
                        )

                        SettingsToggle(
                            title: "Auto-Snap Pieces",
                            description: "Pieces snap to nearest valid slot automatically",
                            isOn: $settings.autoSnapPieces
                        )
                    }

                    // Stats
                    SettingsSection(title: "Progress", icon: "chart.bar.fill") {
                        StatRow(label: "Levels Completed", value: "\(settings.levelsCompleted)")
                        StatRow(label: "Easter Eggs Found", value: "\(settings.totalEasterEggsFound) / 60")
                        StatRow(label: "Games Played", value: "\(settings.gamesPlayed)")
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 20, weight: .medium))
                    }
                    .foregroundStyle(Color.vbAccent)
                }
                .accessibilityLabel("Go back to main menu")
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(Color.vbAccent)
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.vbText)
            }
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                content
            }
            .background(Color.vbSurface, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.vbText)
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.vbTextSecondary)
            }
        }
        .tint(Color.vbAccent)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .accessibilityLabel("\(title). \(description)")
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.vbText)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.vbAccent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
}
