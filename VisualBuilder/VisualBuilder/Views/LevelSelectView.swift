import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = LevelSelectViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        ZStack {
            Color.vbBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose a Level")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vbAccent)
                        .accessibilityAddTraits(.isHeader)

                    if let session = coordinator.gameSession, session.isMultiplayer {
                        Text("\(session.playerCount) players - \(coordinator.currentMode.rawValue)")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.vbTextSecondary)
                    }
                }
                .padding(.top, 20)

                // Level Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.levels) { level in
                            LevelCard(level: level) {
                                coordinator.startLevel(level.id)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
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
                .accessibilityLabel("Go back")
            }
        }
    }
}

struct LevelCard: View {
    let level: LevelPreview
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Level number
                ZStack {
                    Circle()
                        .fill(level.isUnlocked ? Color.vbAccent : Color.vbSurface)
                        .frame(width: 60, height: 60)

                    if level.isUnlocked {
                        Text("\(level.id)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.vbTextSecondary)
                    }
                }

                // Level name
                Text(level.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(level.isUnlocked ? Color.vbText : Color.vbTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Piece count
                Text("\(level.pieceCount) pieces")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.vbTextSecondary)

                // Stars
                if level.starsEarned > 0 {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { star in
                            Image(systemName: star < level.starsEarned ? "star.fill" : "star")
                                .font(.system(size: 16))
                                .foregroundStyle(star < level.starsEarned ? Color.vbYellow : Color.vbTextSecondary)
                        }
                    }
                }
            }
            .frame(width: 160, height: 180)
            .background(Color.vbSurface, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(level.isUnlocked ? Color.vbAccent.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .opacity(level.isUnlocked ? 1.0 : 0.5)
        }
        .disabled(!level.isUnlocked)
        .accessibilityLabel("Level \(level.id): \(level.name)")
        .accessibilityHint(level.isUnlocked ? "\(level.pieceCount) pieces. Tap to play." : "Locked. Complete previous level to unlock.")
        .accessibilityValue(level.starsEarned > 0 ? "\(level.starsEarned) of 3 stars earned" : "Not completed")
    }
}

struct LevelPreview: Identifiable {
    let id: Int
    let name: String
    let pieceCount: Int
    let isUnlocked: Bool
    let starsEarned: Int
}
