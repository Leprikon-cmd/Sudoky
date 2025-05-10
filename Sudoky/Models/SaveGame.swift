//  SaveGame.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.
//

import Foundation

/// Структура для сохранения состояния игры
struct SavedGame: Codable, Hashable {
    let cells: [[Cell]]                // Текущее состояние всех ячеек
    let difficulty: Difficulty         // Выбранная сложность
    let elapsedTime: TimeInterval      // Прошедшее время
    let livesRemaining: Int            // Осталось жизней
    let highlightedValue: Int?         // Подсвеченное число (если есть)
}
