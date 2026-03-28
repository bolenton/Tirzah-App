import SwiftUI
import SpriteKit

struct GameView: View {
    let levelId: Int
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = GameViewModel()
    @State private var showNarration = true
    @State private var showLevelComplete = false
    @State private var showPlayerTurn = false

    var body: some View {
        ZStack {
            Color.vbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // HUD
                GameHUD(viewModel: viewModel)

                // SpriteKit Game Scene
                if let scene = viewModel.scene {
                    SpriteView(scene: scene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        .accessibilityLabel("Building area")
                        .accessibilityHint("Tap to place selected piece")
                } else {
                    ProgressView("Loading level...")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.vbText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Piece Tray
                PieceTrayView(viewModel: viewModel)
            }

            // Narration Overlay
            if showNarration {
                NarrationView(
                    levelId: levelId,
                    levelName: viewModel.levelName,
                    narrationText: viewModel.currentNarration
                ) {
                    withAnimation {
                        showNarration = false
                    }
                    viewModel.startLevel()
                }
                .transition(.opacity)
            }

            // Player Turn Overlay (multiplayer)
            if showPlayerTurn {
                PlayerTurnView(
                    playerName: coordinator.gameSession?.currentPlayer.name ?? "Builder",
                    playerIndex: coordinator.gameSession?.currentPlayerIndex ?? 0
                ) {
                    withAnimation {
                        showPlayerTurn = false
                        showNarration = true
                    }
                }
                .transition(.opacity)
            }

            // Level Complete Overlay
            if showLevelComplete {
                LevelCompleteView(
                    levelId: levelId,
                    completionTime: viewModel.elapsedTime,
                    isChallenge: coordinator.currentMode == .challenge
                ) {
                    coordinator.pop()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadLevel(levelId)
            if coordinator.gameSession?.isMultiplayer == true &&
               coordinator.gameSession?.currentPlayerIndex ?? 0 > 0 {
                showPlayerTurn = true
                showNarration = false
            }
        }
        .onChange(of: viewModel.isLevelComplete) { _, complete in
            if complete {
                withAnimation(.spring(response: 0.6)) {
                    showLevelComplete = true
                }
            }
        }
    }
}

struct GameHUD: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        HStack(spacing: 20) {
            // Back Button
            Button {
                coordinator.pop()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.vbTextSecondary)
            }
            .accessibilityLabel("Exit level")

            // Level Name
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.levelName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.vbText)

                Text("\(viewModel.piecesPlaced) of \(viewModel.totalPieces) pieces placed")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.vbTextSecondary)
            }

            Spacer()

            // Timer (Challenge Mode)
            if coordinator.currentMode == .challenge {
                TimerView(
                    remainingTime: viewModel.remainingTime,
                    totalTime: viewModel.totalTime
                )
            }

            // Player indicator (multiplayer)
            if let session = coordinator.gameSession, session.isMultiplayer {
                VStack(spacing: 4) {
                    Text(session.currentPlayer.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.vbAccent)
                    Text("Player \(session.currentPlayerIndex + 1) of \(session.playerCount)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.vbTextSecondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.vbSurface)
    }
}
