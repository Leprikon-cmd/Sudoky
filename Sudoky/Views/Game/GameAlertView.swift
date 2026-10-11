//
//  GameAlertView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.

import SwiftUI

struct GameAlertsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let showWinAlert: Binding<Bool>
    let showLoseAlert: Binding<Bool>
    let elapsedTime: TimeInterval
    let flawless: Bool
    let difficulty: Difficulty
    let livesRemaining: Int
    let hasAvailableDevelopment: Bool
    let onRestart: () -> Void
    let onNewGame: () -> Void
    let onGarden: () -> Void
    let onStats: () -> Void
    let onMenu: () -> Void

    var body: some View {
        let _ = languageManager.language
        ZStack {
            if showWinAlert.wrappedValue {
                VictoryView(
                    difficulty: difficulty,
                    elapsedTime: elapsedTime,
                    errorCount: max(0, difficulty.lives - livesRemaining),
                    hasAvailableDevelopment: hasAvailableDevelopment,
                    onNewGame: onNewGame,
                    onGarden: onGarden,
                    onHome: onMenu
                )
            } else if showLoseAlert.wrappedValue {
                DefeatView(
                    difficulty: difficulty,
                    elapsedTime: elapsedTime,
                    errorCount: max(0, difficulty.lives - livesRemaining),
                    onRestart: {
                        showLoseAlert.wrappedValue = false
                        onRestart()
                    },
                    onNewGame: onNewGame,
                    onStats: onStats,
                    onHome: onMenu
                )
            }
        }
    }

}
