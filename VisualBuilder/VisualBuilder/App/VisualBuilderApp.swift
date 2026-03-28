import SwiftUI

@main
struct VisualBuilderApp: App {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                MainMenuView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .playerSetup(let mode):
                            PlayerSetupView(mode: mode)
                        case .levelSelect:
                            LevelSelectView()
                        case .game(let levelId):
                            GameView(levelId: levelId)
                        case .settings:
                            SettingsView()
                        }
                    }
            }
            .environmentObject(coordinator)
            .environmentObject(settingsViewModel)
            .preferredColorScheme(.dark)
        }
    }
}
