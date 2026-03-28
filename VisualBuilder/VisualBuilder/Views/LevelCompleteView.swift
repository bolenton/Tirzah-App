import SwiftUI

struct LevelCompleteView: View {
    let levelId: Int
    let completionTime: TimeInterval
    let isChallenge: Bool
    let onContinue: () -> Void

    @State private var showStars = false
    @State private var starScale: [CGFloat] = [0, 0, 0]

    private var stars: Int {
        if !isChallenge { return 3 }
        // Star thresholds based on completion time
        if completionTime < 30 { return 3 }
        if completionTime < 60 { return 2 }
        return 1
    }

    private var timeString: String {
        let minutes = Int(completionTime) / 60
        let seconds = Int(completionTime) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Celebration text
                Text("Level Complete!")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vbYellow)
                    .accessibilityAddTraits(.isHeader)

                Text("Level \(levelId)")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))

                // Stars
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.system(size: 60))
                            .foregroundStyle(index < stars ? Color.vbYellow : Color.white.opacity(0.3))
                            .scaleEffect(starScale[index])
                    }
                }
                .accessibilityLabel("\(stars) out of 3 stars earned")

                // Time
                if isChallenge {
                    VStack(spacing: 8) {
                        Text("Time")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        Text(timeString)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 12) {
                        Text("Continue")
                            .font(.system(size: 26, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 28))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 18)
                    .background(Color.vbGreen, in: Capsule())
                    .shadow(color: Color.vbGreen.opacity(0.4), radius: 12)
                }
                .accessibilityLabel("Continue to next level")

                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            animateStars()
        }
    }

    private func animateStars() {
        for i in 0..<3 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.3 + 0.5)) {
                starScale[i] = 1.0
            }
        }
    }
}
