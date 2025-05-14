//
//  CellView.swift
//  Отвечает за внешний вид ячейки
//  Sudoky
//

import SwiftUI

struct CellView: View {
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    let cell: Cell
    let row: Int
    let col: Int
    let cellSize: CGFloat
    let highlightedValue: Int?
    let showErrors: Bool

    @State private var strokeName: String = ""    // Имя текущего мазка
    @State private var showBrush: Bool = false    // Показывать мазок или нет

    private static var picker = StrokeImagePicker() // Общий выбор обводок

    // MARK: - Вычисления

    /// Подсветка ячеек с совпадающим значением (если включена)
    var isHighlighted: Bool {
        highlightedValue != nil && highlightedValue == cell.value && cell.value != 0
    }

    /// Подсветка ошибок (если включена и есть ошибка)
    var isError: Bool {
        showErrors && cell.hasError
    }

    // MARK: - Основное тело ячейки

    var body: some View {
        ZStack {
            // 🟫 Фон ячейки (настраивается в Assets)
            Rectangle()
                .fill(isError ? Color("ErrorCellColor") : Color("CellBackground"))

            // 🎨 Мазок кисти при выделении
            if cell.isSelected || isHighlighted {
                if !strokeName.isEmpty {
                    Image(strokeName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: cellSize, height: cellSize)
                        .opacity(showBrush ? 0.8 : 0) // 🔧 Прозрачность мазка при появлении
                        .onAppear {
                            // Генерация мазка и анимация
                            if strokeName.isEmpty {
                                strokeName = Self.picker.next()
                            }
                            withAnimation(.easeOut(duration: 0.9)) {
                                showBrush = true
                            }
                        }
                } else {
                    // Случай, когда мазок ещё не назначен
                    Color.clear
                        .frame(width: cellSize, height: cellSize)
                        .onAppear {
                            strokeName = Self.picker.next()
                            withAnimation(.easeOut(duration: 0.9)) { // 🔧 Длительность и стиль анимации
                                showBrush = true
                            }
                        }
                }
            }

            // 🔢 Основное число
            if cell.value != 0 {
                fontManager.styledText("\(cell.value)", size: cellSize * 0.8) // 🔧 Размер шрифта
                    .foregroundColor(cell.isEditable ? Color("ButtonPrimary") : .black) // 🔧 Цвет числа
                    .frame(width: cellSize, height: cellSize, alignment: .center)
            }

            // ✏️ Заметки в пустой ячейке
            else if !cell.notes.isEmpty {
                VStack(spacing: 1) { // 🔧 Межстрочный отступ мини-сетки
                    ForEach(0..<3) { row in
                        HStack(spacing: 1) {
                            ForEach(1..<4) { col in
                                let noteValue = row * 3 + col
                                Text(cell.notes.contains(noteValue) ? "\(noteValue)" : "")
                                    .font(.system(size: cellSize * 0.3)) // 🔧 Размер шрифта заметок
                                    .frame(width: cellSize / 3, height: cellSize / 3)
                                    .foregroundColor(.gray) // 🔧 Цвет заметок
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: cell.isSelected) { _, _ in
            handleBrushChange()
        }
        .onChange(of: isHighlighted) { _, _ in
            handleBrushChange()
        }
        .frame(width: cellSize, height: cellSize)
    }

    // MARK: - Управление мазком
    private func handleBrushChange() {
        if !(cell.isSelected || isHighlighted) {
            showBrush = false
            strokeName = ""
        }
    }

    // MARK: - Генератор случайных мазков
    class StrokeImagePicker {
        private var available = Array(1...13).shuffled()

        func next() -> String {
            if available.isEmpty {
                available = Array(1...13).shuffled()
            }
            return "brush_stroke_\(available.removeFirst())"
        }
    }
}
