import SwiftUI

struct PlayerSetupView: View {
    let mode: GameMode
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerCount: Int = 1
    @State private var playerNames: [String] = ["Builder 1", "Builder 2", "Builder 3", "Builder 4"]
    @FocusState private var focusedField: Int?

    private let maxPlayers = 4

    var body: some View {
        ZStack {
            Color.vbBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text(mode == .challenge ? "Challenge Mode" : "Free Play")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(mode == .challenge ? Color.vbOrange : Color.vbGreen)
                        .accessibilityAddTraits(.isHeader)

                    if mode == .challenge {
                        Text("How many players?")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.vbTextSecondary)
                    }
                }
                .padding(.top, 40)

                // Player Count Selector (Challenge Mode only)
                if mode == .challenge {
                    HStack(spacing: 16) {
                        ForEach(1...maxPlayers, id: \.self) { count in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    playerCount = count
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: playerCountIcon(count))
                                        .font(.system(size: 36))
                                    Text("\(count)")
                                        .font(.system(size: 24, weight: .bold))
                                }
                                .frame(width: 100, height: 100)
                                .foregroundStyle(playerCount == count ? Color.white : Color.vbTextSecondary)
                                .background(
                                    playerCount == count ? Color.vbOrange : Color.vbSurface,
                                    in: RoundedRectangle(cornerRadius: 20)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(playerCount == count ? Color.vbOrange : Color.clear, lineWidth: 3)
                                )
                            }
                            .accessibilityLabel("\(count) player\(count > 1 ? "s" : "")")
                            .accessibilityHint(playerCount == count ? "Currently selected" : "Tap to select")
                            .accessibilityAddTraits(playerCount == count ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal, 40)
                }

                // Player Name Fields
                VStack(spacing: 16) {
                    ForEach(0..<playerCount, id: \.self) { index in
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(playerColor(index))
                                .frame(width: 44)

                            TextField("Player \(index + 1) name", text: $playerNames[index])
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(Color.vbText)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.vbSurface, in: RoundedRectangle(cornerRadius: 14))
                                .focused($focusedField, equals: index)
                                .accessibilityLabel("Player \(index + 1) name")
                        }
                    }
                }
                .padding(.horizontal, 80)
                .animation(.spring(response: 0.3), value: playerCount)

                Spacer()

                // Start Button
                AccessibleButton(
                    title: "Start Building!",
                    subtitle: mode == .challenge ? "\(playerCount) player\(playerCount > 1 ? "s" : "") - Challenge Mode" : "Free Play - No time limit",
                    icon: "play.fill",
                    color: mode == .challenge ? .vbOrange : .vbGreen
                ) {
                    startGame()
                }
                .padding(.horizontal, 80)
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

    private func startGame() {
        let activePlayers = (0..<playerCount).map { index in
            Player(name: playerNames[index].isEmpty ? "Builder \(index + 1)" : playerNames[index])
        }
        coordinator.startGame(mode: mode, players: activePlayers)
    }

    private func playerCountIcon(_ count: Int) -> String {
        switch count {
        case 1: return "person.fill"
        case 2: return "person.2.fill"
        case 3: return "person.3.fill"
        case 4: return "person.3.sequence.fill"
        default: return "person.fill"
        }
    }

    private func playerColor(_ index: Int) -> Color {
        let colors: [Color] = [.vbBlue, .vbOrange, .vbGreen, .vbPurple]
        return colors[index % colors.count]
    }
}
