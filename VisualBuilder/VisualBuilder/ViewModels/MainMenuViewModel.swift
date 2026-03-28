import SwiftUI

@MainActor
class MainMenuViewModel: ObservableObject {
    @Published var selectedMode: GameMode?

    func selectMode(_ mode: GameMode) {
        selectedMode = mode
    }
}
