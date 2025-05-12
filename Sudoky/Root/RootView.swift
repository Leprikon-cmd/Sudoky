//
//  RootView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.

import SwiftUI

enum Route: Hashable {
    case difficulty
    case stats
    case settings
    case game(Difficulty)
    case resume
}

struct RootView: View {
    // 🔁 Все StateObject централизованно тут
    @StateObject var statsManager = StatsManager()
    @StateObject var settingsManager = SettingsManager()
    @StateObject var fontManager = FontManager.shared
    @StateObject var playerProgressManager = PlayerProgressManager.shared

    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            StartView(statsManager: statsManager, path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .difficulty:
                        DifficultyPickerView(statsManager: statsManager, path: $path)

                    case .stats:
                        StatsView(statsManager: statsManager, path: $path)

                    case .settings:
                        SettingsView()

                    case .game(let difficulty):
                        GameView(
                            difficulty: difficulty,
                            statsManager: statsManager,
                            playerProgressManager: playerProgressManager,
                            path: $path
                        )

                    case .resume:
                        if let saved = GamePersistenceManager.shared.load() {
                            GameView(
                                savedGame: saved,
                                statsManager: statsManager,
                                playerProgressManager: playerProgressManager,
                                path: $path
                            )
                        } else {
                            StartView(statsManager: statsManager, path: $path)
                        }
                    }
                }
        }
        .tint(Color("NavigationAccent"))
        // 🔗 Передаём зависимости только ОДИН РАЗ
        .environmentObject(settingsManager)
        .environmentObject(fontManager)
        .environmentObject(playerProgressManager)
    }
}

#Preview {
    RootView()
}
