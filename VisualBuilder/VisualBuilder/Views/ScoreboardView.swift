import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let isFinalScoreboard: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Header
                Text(isFinalScoreboard ? "Final Results!" : "Level Results")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vbYellow)
                    .accessibilityAddTraits(.isHeader)

                if let session = coordinator.gameSession {
                    // Player scores
                    VStack(spacing: 16) {
                        ForEach(Array(session.sortedPlayersByScore.enumerated()), id: \.element.id) { index, player in
                            ScoreRow(
                                rank: index + 1,
                                player: player,
                                isWinner: isFinalScoreboard && index == 0
                            )
                        }
                    }
                    .padding(.horizontal, 60)

                    // Winner announcement (final scoreboard)
                    if isFinalScoreboard, let winner = session.winner {
                        VStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.vbYellow)

                            Text("\(winner.name) Wins!")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Color.vbYellow)
                        }
                        .padding(.top, 20)
                        .accessibilityLabel("\(winner.name) wins with \(winner.totalScore) points!")
                    }
                }

                Spacer()

                // Action buttons
                HStack(spacing: 24) {
                    if !isFinalScoreboard {
                        AccessibleButton(
                            title: "Next Level",
                            subtitle: nil,
                            icon: "arrow.right",
                            color: .vbGreen
                        ) {
                            coordinator.gameSession?.advanceToNextLevel()
                            coordinator.pop()
                        }
                    }

                    AccessibleButton(
                        title: isFinalScoreboard ? "Back to Menu" : "End Session",
                        subtitle: nil,
                        icon: isFinalScoreboard ? "house.fill" : "stop.fill",
                        color: isFinalScoreboard ? .vbAccent : .vbRed
                    ) {
                        coordinator.gameSession?.endSession()
                        coordinator.popToRoot()
                    }
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
            }
        }
    }
}

struct ScoreRow: View {
    let rank: Int
    let player: Player
    let isWinner: Bool

    private var rankColor: Color {
        switch rank {
        case 1: return .vbYellow
        case 2: return .vbTextSecondary
        case 3: return .vbOrange
        default: return .vbTextSecondary
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 48, height: 48)

                Text("\(rank)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(rank <= 2 ? Color.black : Color.white)
            }

            // Name
            Text(player.name)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            // Score
            Text("\(player.totalScore) pts")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(rankColor)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isWinner ? Color.vbYellow.opacity(0.15) : Color.vbSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isWinner ? Color.vbYellow.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank): \(player.name), \(player.totalScore) points")
    }
}
