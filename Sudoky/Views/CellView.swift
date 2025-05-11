//  CellView.swift
//  Отвечает за внешний вид ячейки
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import SwiftUI

struct CellView: View {
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    let cell: Cell
    let row: Int
    let col: Int
    let cellSize: CGFloat
    let highlightedValue: Int?
    let showErrors: Bool

    /// Подсветка ячеек с совпадающим значением (если включена)
    var isHighlighted: Bool {
        highlightedValue != nil && highlightedValue == cell.value && cell.value != 0
    }

    /// Подсветка ошибок (если включена и есть ошибка)
    var isError: Bool {
        showErrors && cell.hasError
    }

    var body: some View {
        ZStack {
            // Фон ячейки с приоритетом: выбрана → ошибка → совпадение → обычная
            Rectangle()
                .fill(
                    cell.isSelected ?
                        Color("SelectedCellColor") :                    // Выделение выбранной ячейки
                    isError ?
                        Color("ErrorCellColor") :                      // Подсветка ошибки
                    isHighlighted ?
                        Color("HighlightedCellColor") :               // Подсветка совпадающих значений
                        Color("CellBackground")                        // Обычный фон
                )

            // Если в ячейке есть основное число — отображаем его
            if cell.value != 0 {
                Text("\(cell.value)")
                    .font(.system(size: cellSize * 0.5))              // ← меняй размер цифры
                    .foregroundColor(cell.isEditable ? .blue : .black)
            }
            // Если число не задано (0), но есть заметки — отрисовываем мини-сетку
            else if !cell.notes.isEmpty {
                VStack(spacing: 1) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 1) {
                            ForEach(1..<4) { col in
                                let noteValue = row * 3 + col
                                Text(cell.notes.contains(noteValue) ? "\(noteValue)" : "")
                                    .font(.system(size: cellSize * 0.3))     // ← меняй размер цифр заметок
                                    .frame(width: cellSize / 3, height: cellSize / 3)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        // Размер всей ячейки
        .frame(width: cellSize, height: cellSize)
    }
}
