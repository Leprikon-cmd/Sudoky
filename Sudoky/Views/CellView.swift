//  CellView.swift
//  Отвечает за внешний вид ячейки
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import SwiftUI

struct CellView: View {
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
                    isError ? Color("ErrorCellColor") :             // Подсветка ошибки
                    isHighlighted ? Color("HighlightedCellColor") : // Подсветка совпадающих значений
                    Color("CellBackground")                         // Обычный фон
                )

            // Отображение значения, если не 0
            Text(cell.value == 0 ? "" : "\(cell.value)")
                .font(.system(size: cellSize * 0.5))
                .foregroundColor(cell.isEditable ? .blue : .black) // Цвет для редактируемых/нередактируемых
        }
        // Размер ячейки
        .frame(width: cellSize, height: cellSize)
    }
}
