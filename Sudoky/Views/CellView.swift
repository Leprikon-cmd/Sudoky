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
    
    func strokeImageName(for value: Int) -> String? {
        guard value >= 1 && value <= 9 else { return nil }
        return "brush_stroke_\(value)"
    }

    var body: some View {
        ZStack {
            
            // Фон ячейки с приоритетом: выбрана → ошибка → совпадение → обычная
            Rectangle()
                .fill(
                    isError ?
                        Color("ErrorCellColor") :                      // Подсветка ошибки
                        Color("CellBackground")                        // Обычный фон
                )
            // Мазок кисти при выделении или подсветке
            if cell.isSelected || isHighlighted {
                if let imageName = strokeImageName(for: cell.value) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.3) // Размер мазка: увеличивает, но не чрезмерно
                        .opacity(0.5)     // Полупрозрачный
                        .frame(width: cellSize, height: cellSize) // Ограничим область
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: cell.isSelected || isHighlighted)
                }
            }
            
            // Если в ячейке есть основное число — отображаем его
            if cell.value != 0 {
                
                fontManager.styledText("\(cell.value)", size: cellSize * 0.8)
                    .foregroundColor(cell.isEditable ? (Color("ButtonPrimary")) : .black)
                    .frame(width: cellSize, height: cellSize)
                    
            }
            // Если число не задано (0), но есть заметки — отрисовываем мини-сетку
            else if !cell.notes.isEmpty {
                VStack(spacing: 1) { // ← вертикальный стек из 3 строк
                    ForEach(0..<3) { row in
                        HStack(spacing: 1) { // ← горизонтальный стек из 3 ячеек
                            ForEach(1..<4) { col in
                                let noteValue = row * 3 + col // ← пересчёт в значение от 1 до 9
                                Text(cell.notes.contains(noteValue) ? "\(noteValue)" : "")
                                    .font(.system(size: cellSize * 0.3)) // ← размер мини-цифр
                                    .frame(width: cellSize / 3, height: cellSize / 3) // ← равномерно распределяем
                                    .foregroundColor(.gray) // ← серый цвет — как будто карандашом
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
