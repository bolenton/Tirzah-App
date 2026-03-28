import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var settings: SettingsViewModel
    @State private var animateTitle = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.vbBackground, Color.vbBackgroundDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 12) {
                    Text("Visual Builder")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vbAccent)
                        .accessibilityAddTraits(.isHeader)
                        .scaleEffect(animateTitle ? 1.0 : 0.8)
                        .opacity(animateTitle ? 1.0 : 0)

                    Text("Building Challenge")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.vbTextSecondary)
                }

                Spacer()

                // Mode Selection
                VStack(spacing: 20) {
                    AccessibleButton(
                        title: "Free Play",
                        subtitle: "Build at your own pace",
                        icon: "hammer.fill",
                        color: .vbGreen
                    ) {
                        coordinator.navigate(to: .playerSetup(mode: .freePlay))
                    }

                    AccessibleButton(
                        title: "Challenge Mode",
                        subtitle: "Beat the clock! 1-4 players",
                        icon: "timer",
                        color: .vbOrange
                    ) {
                        coordinator.navigate(to: .playerSetup(mode: .challenge))
                    }
                }
                .padding(.horizontal, 60)

                Spacer()

                // Bottom buttons
                HStack(spacing: 30) {
                    Button {
                        coordinator.navigate(to: .settings)
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.vbTextSecondary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.vbSurface, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens game settings and accessibility options")

                    if settings.totalEasterEggsFound > 0 {
                        Text("\(settings.totalEasterEggsFound) Easter Eggs Found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.vbPurple)
                            .accessibilityLabel("\(settings.totalEasterEggsFound) Easter eggs discovered")
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateTitle = true
            }
        }
    }
}
