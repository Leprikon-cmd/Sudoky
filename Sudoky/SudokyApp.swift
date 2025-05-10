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
    @StateObject var playerProgressManager = PlayerProgressManager.shared
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                StartView(statsManager: statsManager, path: $path)
                    .environmentObject(playerProgressManager)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .difficulty:
                            DifficultyPickerView(statsManager: statsManager, path: $path)

                        case .stats:
                            StatsView(statsManager: statsManager, path: $path)

                        case .game(let difficulty):
                            GameView(
                                difficulty: difficulty,
                                statsManager: statsManager,
                                playerProgressManager: playerProgressManager,
                                path: $path
                            )

                        case .settings:
                            SettingsView()
                                .environmentObject(settingsManager)

                        case .resume:
                            // Пытаемся загрузить сохранённую игру
                            if let saved = GamePersistenceManager.shared.load() {
                                GameView(savedGame: saved, statsManager: statsManager, playerProgressManager: playerProgressManager, path: $path)
                            } else {
                                // Если вдруг не удалось — возвращаемся на стартовый экран
                                StartView(statsManager: statsManager, path: $path)
                                    .environmentObject(playerProgressManager)
                            }
                        }
                    }
            }
        }
    }
}
