//
//  PlayerProgressManager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.
//



import Foundation

/// Менеджер прогресса игрока: уровень, опыт, и логика прокачки
class PlayerProgressManager: ObservableObject {
    static let shared = PlayerProgressManager()

    @Published private(set) var currentXP: Double = 0
    @Published private(set) var currentLevel: Int = 1

    private let defaults = UserDefaults.standard

    private init() {
        load()
    }

    /// Добавляет опыт на основе параметров игры
    func addXP(difficulty: Difficulty, livesRemaining: Int, elapsedTime: TimeInterval) {
        let baseXP = 1.0
        let difficultyMultiplier: Double = {
            switch difficulty {
            case .новичок: return 1
            case .ученик: return 5
            case .мастер: return 10
            case .сенсей: return 25
            case .dokushin: return 50
            }
        }()

        let lostLives = Double(difficulty.lives - livesRemaining)
        let livesPenalty = lostLives * 1.0 // -1 XP за каждую потерю

        let timeBonus: Double = {
            let seconds = elapsedTime
            let bonusFactor = max(0.0, (600.0 - seconds) / 600.0) // до +1.0
            return bonusFactor * baseXP
        }()

        var gainedXP = baseXP * difficultyMultiplier + timeBonus - livesPenalty
        gainedXP = max(0, gainedXP)

        currentXP += gainedXP
        updateLevel()
        save()
    }
    
    /// Применяет штраф за поражение — вычитает 1% от текущего уровня XP
    func applyLossPenalty() {
        let penalty = max(1.0, Double(currentLevel)) * 0.01
        currentXP = max(0, currentXP - penalty)
        updateLevel()
        save()
    }

    /// Обновляет текущий уровень, если достаточно XP
    private func updateLevel() {
        var level = 1
        var requiredXP = xpForLevel(level + 1)

        while currentXP >= requiredXP {
            level += 1
            requiredXP = xpForLevel(level + 1)
        }

        currentLevel = level
    }

    /// Возвращает необходимый XP для следующего уровня
    private func xpForLevel(_ level: Int) -> Double {
        return Double(level * level * 10)
    }

    /// Сохраняет текущий прогресс
    private func save() {
        defaults.set(currentXP, forKey: "playerXP")
        defaults.set(currentLevel, forKey: "playerLevel")
    }

    /// Загружает сохранённый прогресс
    private func load() {
        currentXP = defaults.double(forKey: "playerXP")
        currentLevel = defaults.integer(forKey: "playerLevel")
        if currentLevel == 0 { currentLevel = 1 }
    }

    /// Сброс прогресса
    func reset() {
        currentXP = 0
        currentLevel = 1
        save()
    }
}
