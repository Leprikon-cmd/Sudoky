import Foundation

/// Хранит статистику для конкретного уровня сложности
struct StatsEntry: Codable {
    var played: Int = 0                // Количество сыгранных игр
    var wins: Int = 0                  // Количество побед
    var bestTime: TimeInterval = 0     // Лучшее время прохождения (в секундах)

    var winStreak: Int = 0             // Текущая серия побед подряд
    var maxWinStreak: Int = 0          // Максимальная серия побед

    var flawlessStreak: Int = 0        // Текущая серия flawless-побед (без ошибок)
    var maxFlawlessStreak: Int = 0     // Максимальная flawless-серия
}

class StatsManager: ObservableObject {
    @Published var stats: [Difficulty: StatsEntry] = [:]

    init() {
        if let data = UserDefaults.standard.data(forKey: "difficultyStats"),
           let decoded = try? JSONDecoder().decode([Difficulty: StatsEntry].self, from: data) {
            self.stats = decoded
        } else {
            self.stats = Dictionary(uniqueKeysWithValues: Difficulty.allCases.map { ($0, StatsEntry()) })
        }
    }
    
    /// Сбрасывает статистику по всем уровням сложности
    func resetStats() {
        stats = Dictionary(uniqueKeysWithValues: Difficulty.allCases.map { ($0, StatsEntry()) })
        saveStats()
    }
    
    /// Обновляет статистику по результатам игры
    func recordGame(difficulty: Difficulty, won: Bool, time: TimeInterval?, flawless: Bool) {
        var entry = stats[difficulty] ?? StatsEntry()

        entry.played += 1

        if won {
            entry.wins += 1

            // Обновим лучшее время
            if let t = time, (entry.bestTime == 0 || t < entry.bestTime) {
                entry.bestTime = t
            }

            // Победная серия
            entry.winStreak += 1
            entry.maxWinStreak = max(entry.maxWinStreak, entry.winStreak)

            // Безошибочная серия
            if flawless {
                entry.flawlessStreak += 1
                entry.maxFlawlessStreak = max(entry.maxFlawlessStreak, entry.flawlessStreak)
            } else {
                entry.flawlessStreak = 0
            }

        } else {
            // Если проиграл — сбрасываем серии
            entry.winStreak = 0
            entry.flawlessStreak = 0
        }

        stats[difficulty] = entry
        saveStats()
    }
    /// Сохраняет словарь статистики в UserDefaults
    private func saveStats() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: "difficultyStats")
        }
    }
}
