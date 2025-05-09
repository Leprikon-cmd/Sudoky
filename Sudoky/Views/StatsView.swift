
//  StatsView.swift
//  Sudoky

import SwiftUI

struct StatsView: View {
    @ObservedObject var stats: StatsManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Статистика")
                .font(.largeTitle)

            HStack {
                Text("Игр сыграно:")
                Spacer()
                Text("\(stats.gamesPlayed)")
            }

            HStack {
                Text("Побед:")
                Spacer()
                Text("\(stats.wins)")
            }

            HStack {
                Text("Лучшее время:")
                Spacer()
                Text(bestTimeFormatted)
            }

            Button("Сбросить статистику") {
                stats.resetStats()
            }
            .foregroundColor(.red)
        }
        .padding()
    }

    var bestTimeFormatted: String {
        if stats.bestTime == 0 {
            return "–"
        } else {
            let minutes = Int(stats.bestTime) / 60
            let seconds = Int(stats.bestTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    StatsView(stats: StatsManager())
}
