import SwiftUI

struct PlayerTurnView: View {
    let playerName: String
    let playerIndex: Int
    let onReady: () -> Void

    @State private var showContent = false
    @State private var pulseScale: CGFloat = 1.0

    private var playerColor: Color {
        let colors: [Color] = [.vbBlue, .vbOrange, .vbGreen, .vbPurple]
        return colors[playerIndex % colors.count]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                if showContent {
                    // Player icon
                    ZStack {
                        Circle()
                            .fill(playerColor)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseScale)
                            .shadow(color: playerColor.opacity(0.5), radius: 20)

                        Image(systemName: "person.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 16) {
                        Text(playerName)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(playerColor)

                        Text("It's your turn!")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer()

                    // Ready button
                    Button(action: onReady) {
                        HStack(spacing: 12) {
                            Text("I'm Ready!")
                                .font(.system(size: 28, weight: .bold))
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 28))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 20)
                        .background(playerColor, in: Capsule())
                        .shadow(color: playerColor.opacity(0.4), radius: 12)
                    }
                    .accessibilityLabel("\(playerName), tap when you're ready to play")
                }

                Spacer()
                    .frame(height: 80)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(playerName), it's your turn! Tap the ready button when you're ready to play.")
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
    }
}
