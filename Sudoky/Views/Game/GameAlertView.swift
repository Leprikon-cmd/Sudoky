//
//  GameAlertView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.

import SwiftUI

struct GameAlertsView: View {
    let showWinAlert: Binding<Bool>
    let showLoseAlert: Binding<Bool>
    let gainedXP: Int
    let elapsedTime: TimeInterval
    let flawless: Bool
    let onRestart: () -> Void
    let onNewGame: () -> Void
    let onStats: () -> Void
    let onMenu: () -> Void
    @EnvironmentObject var languageManager: LanguageManager // Локализация

    var body: some View {
        // Заглушка, чтобы SwiftUI не выкинул View
        Color.clear
            .alert(loc("alert.lose.title"), isPresented: showLoseAlert) {
                Button(loc("alert.restart"), action: onRestart)
                Button(loc("alert.newGame"), action: onNewGame)
                Button(loc("alert.stats"), action: onStats)
                Button(loc("alert.menu"), action: onMenu)
            } message: {
                Text(String(format: loc("alert.lose.message"), abs(gainedXP)))
            }

            .alert(loc("alert.win.title"), isPresented: showWinAlert) {
                Button(loc("alert.restart"), action: onRestart)
                Button(loc("alert.newGame"), action: onNewGame)
                Button(loc("alert.stats"), action: onStats)
                Button(loc("alert.menu"), action: onMenu)
            } message: {
                Text(String(format: loc("alert.win.message"), formatTime(elapsedTime), gainedXP))
            }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
