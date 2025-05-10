import SwiftUI

enum Route: Hashable {
    case difficulty
    case stats
    case game(Difficulty)
    case settings
}

@main
struct SudokyApp: App {
    @StateObject var statsManager = StatsManager()
    @StateObject var settingsManager = SettingsManager()
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                StartView(statsManager: statsManager, path: $path)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .difficulty:
                            DifficultyPickerView(statsManager: statsManager, path: $path)
                        case .stats:
                            StatsView(statsManager: statsManager, path: $path)
                        case .game(let difficulty):
                            GameView(difficulty: difficulty, statsManager: statsManager, path: $path)
                        case .settings:
                            SettingsView()
                                .environmentObject(settingsManager)
                        }
                    }
            }
        }
    }
}
