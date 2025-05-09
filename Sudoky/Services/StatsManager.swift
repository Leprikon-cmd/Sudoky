
//  StatsManager.swift
//  Sudoky

import Foundation

class StatsManager: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var gamesPlayed: Int
    @Published var wins: Int
    @Published var bestTime: TimeInterval

    init() {
        self.gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        self.wins = defaults.integer(forKey: "wins")
        self.bestTime = defaults.double(forKey: "bestTime")
    }

    func recordGame(won: Bool, time: TimeInterval?) {
        gamesPlayed += 1
        if won {
            wins += 1
            if let t = time, (bestTime == 0 || t < bestTime) {
                bestTime = t
            }
        }
        save()
    }

    func resetStats() {
        gamesPlayed = 0
        wins = 0
        bestTime = 0
        save()
    }

    private func save() {
        defaults.set(gamesPlayed, forKey: "gamesPlayed")
        defaults.set(wins, forKey: "wins")
        defaults.set(bestTime, forKey: "bestTime")
    }
}
