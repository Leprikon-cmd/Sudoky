//  GamePersistenceManager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.
//

import Foundation

/// Менеджер сохранения и восстановления игры
class GamePersistenceManager {
    static let shared = GamePersistenceManager() // Singleton

    private let saveKey = "savedGame"

    /// Сохраняем игру в UserDefaults
    func save(_ game: SavedGame) {
        do {
            let data = try JSONEncoder().encode(game)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Ошибка при сохранении игры: \(error)")
        }
    }

    /// Загружаем игру из UserDefaults
    func load() -> SavedGame? {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return nil }
        do {
            return try JSONDecoder().decode(SavedGame.self, from: data)
        } catch {
            print("Ошибка при загрузке игры: \(error)")
            return nil
        }
    }

    /// Удаляем сохранённую игру
    func clear() {
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    /// Проверяем, есть ли сохранение
    func hasSavedGame() -> Bool {
        return UserDefaults.standard.data(forKey: saveKey) != nil
    }
}
