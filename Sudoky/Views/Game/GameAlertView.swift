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

    var body: some View {
        ZStack {
            if showWinAlert.wrappedValue {
                GameCustomAlert(
                    title: loc("alert.win.title"),
                    message: String(format: loc("alert.win.message"), formatTime(elapsedTime), gainedXP),
                    actions: [
                        AlertAction(title: loc("alert.restart"), handler: onRestart),
                        AlertAction(title: loc("alert.newGame"), handler: onNewGame),
                        AlertAction(title: loc("alert.stats"), handler: onStats),
                        AlertAction(title: loc("alert.menu"), handler: onMenu)
                    ],
                    isPresented: showWinAlert
                )
            }

            if showLoseAlert.wrappedValue {
                GameCustomAlert(
                    title: loc("alert.lose.title"),
                    message: String(format: loc("alert.lose.message"), abs(gainedXP)),
                    actions: [
                        AlertAction(title: loc("alert.restart"), handler: onRestart),
                        AlertAction(title: loc("alert.newGame"), handler: onNewGame),
                        AlertAction(title: loc("alert.stats"), handler: onStats),
                        AlertAction(title: loc("alert.menu"), handler: onMenu)
                    ],
                    isPresented: showLoseAlert
                )
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
