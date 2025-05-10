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
        // Заглушка, чтобы SwiftUI не выкинул View
        Color.clear
            .alert("Ты проиграл!", isPresented: showLoseAlert) {
                Button("Заново", action: onRestart)
                Button("Новая игра", action: onNewGame)
                Button("Статистика", action: onStats)
                Button("Меню", action: onMenu)
            } message: {
                Text("Все жизни закончились… ты потерял \(abs(gainedXP)) XP")
            }

            .alert("Победа!", isPresented: showWinAlert) {
                Button("Заново", action: onRestart)
                Button("Новая игра", action: onNewGame)
                Button("Статистика", action: onStats)
                Button("Меню", action: onMenu)
            } message: {
                Text("Ты победил за \(formatTime(elapsedTime)) и получил \(gainedXP) XP")
            }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
