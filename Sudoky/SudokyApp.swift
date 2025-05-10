import SwiftUI

enum Route: Hashable {
    case difficulty
    case stats
    case game(Difficulty)
    case settings
    case resume
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

                        case .resume:
                            // Пытаемся загрузить сохранённую игру
                            if let saved = GamePersistenceManager.shared.load() {
                                GameView(savedGame: saved, statsManager: statsManager, path: $path)
                            } else {
                                // Если вдруг не удалось — возвращаемся на стартовый экран
                                StartView(statsManager: statsManager, path: $path)
                            }
                        }
                    }
            }
        }
    }
}
