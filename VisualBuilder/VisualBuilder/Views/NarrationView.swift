import SwiftUI

struct NarrationView: View {
    let levelId: Int
    let levelName: String
    let narrationText: String
    let onDismiss: () -> Void

    @State private var textOpacity: Double = 0
    @State private var showSkipButton = false

    var body: some View {
        ZStack {
            // Cinematic dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Level number badge
                ZStack {
                    Circle()
                        .fill(Color.vbAccent)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.vbAccent.opacity(0.5), radius: 20)

                    Text("\(levelId)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                }

                // Level name
                Text(levelName)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                // Narration text
                Text(narrationText)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 80)
                    .opacity(textOpacity)

                Spacer()

                // Skip / Continue button
                if showSkipButton {
                    Button(action: onDismiss) {
                        HStack(spacing: 12) {
                            Text("Start Building")
                                .font(.system(size: 24, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 28))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 18)
                        .background(Color.vbAccent, in: Capsule())
                        .shadow(color: Color.vbAccent.opacity(0.4), radius: 10)
                    }
                    .accessibilityLabel("Start building")
                    .accessibilityHint("Tap to skip narration and begin the level")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                    .frame(height: 60)
            }
        }
        .onTapGesture {
            onDismiss()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Level \(levelId): \(levelName). \(narrationText)")
        .accessibilityHint("Tap anywhere to skip and start building")
        .onAppear {
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                textOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(2.0)) {
                showSkipButton = true
            }
        }
    }
}
