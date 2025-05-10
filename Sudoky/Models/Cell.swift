//  Cell.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import Foundation

struct Cell: Identifiable {
    let id = UUID()
    var row: Int
    var col: Int
    var value: Int         // От 1 до 9, 0 если пусто
    var isEditable: Bool   // Можно ли редактировать (false для исходной доски)
    var isSelected: Bool   // Подсвечена ли ячейка
    var hasError: Bool = false
}
