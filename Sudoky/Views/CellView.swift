//
//  CellView.swift
//  Отвечает за внешний вид ячейки
//  Sudoky
//

import SwiftUI

struct CellView: View {
    @EnvironmentObject var fontManager: FontManager // ++ Менеджер шрифтов — нужен всегда

    let cell: Cell
    let row: Int
    let col: Int
    let cellSize: CGFloat // ++ Используется для всех размеров и расчётов

    let highlightedValue: Int?
    let showErrors: Bool

    @State private var strokeName: String = ""
    @State private var showBrush: Bool = false

    private static var picker = StrokeImagePicker() // ++ Генератор случайных мазков

    var isHighlighted: Bool {
        highlightedValue != nil && highlightedValue == cell.value && cell.value != 0
    }

    var isError: Bool {
        showErrors && cell.hasError
    }

    var body: some View {
        ZStack {
            // 1. 🟫 Фон ячейки
            Rectangle()
                .fill(isError ? Color("ErrorCellColor") : Color("CellBackground")) // 🔧 Цвета из Assets

            // 2. 🧱 Внутренние жирные линии 3×3
            GridLinesOverlay(row: row, col: col, cellSize: cellSize) // ++ Подгрид из линий по краям блока

            // 3. 🔢 Основная цифра
            if cell.value != 0 {
                fontManager.styledText("\(cell.value)", size: cellSize * 0.8) // 🔧 Размер шрифта
                    .foregroundColor(cell.isEditable ? Color("ButtonPrimary") : .black) // 🔧 Цвет
                    .frame(width: cellSize, height: cellSize, alignment: .center)
            }

            // 4. ✏️ Заметки (если нет цифры)
            else if !cell.notes.isEmpty {
                VStack(spacing: 1) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 1) {
                            ForEach(1..<4) { col in
                                let noteValue = row * 3 + col
                                Text(cell.notes.contains(noteValue) ? "\(noteValue)" : "")
                                    .font(.system(size: cellSize * 0.3)) // 🔧 Размер заметок
                                    .frame(width: cellSize / 3, height: cellSize / 3)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }

            // 5. 🖌️ Обводка (мазок) — поверх всего
            if cell.isSelected || isHighlighted {
                Image(strokeName.isEmpty ? Self.picker.nextAndAssign(to: $strokeName) : strokeName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cellSize * 1, height: cellSize * 1) // 🔧 увеличение мазка
                    .opacity(showBrush ? 0.8 : 0) // 🔧 Прозрачность мазка
                    .allowsHitTesting(false)
                    .zIndex(10) // ++ Мазок всегда сверху
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.9)) { // 🔧 Анимация появления
                            showBrush = true
                        }
                    }
            }
        }
        .frame(width: cellSize, height: cellSize) // ++ фиксированный размер ячейки
        .onChange(of: cell.isSelected) { _, _ in handleBrushChange() }
        .onChange(of: isHighlighted) { _, _ in handleBrushChange() }
    }

    // ++ Управление появлением мазка
    private func handleBrushChange() {
        if !(cell.isSelected || isHighlighted) {
            showBrush = false
            strokeName = ""
        }
    }

    // ++ Сетка линий по краям ячейки (внутри блока 3×3)
    private struct GridLinesOverlay: View {
        let row: Int
        let col: Int
        let cellSize: CGFloat

        var body: some View {
            ZStack {
                if row % 3 == 0 {
                    Rectangle()
                        .fill(Color("Line"))
                        .frame(height: 2)
                        .offset(y: -cellSize / 2)
                }
                if col % 3 == 0 {
                    Rectangle()
                        .fill(Color("Line"))
                        .frame(width: 2)
                        .offset(x: -cellSize / 2)
                }
            }
        }
    }

    // ++ Генератор случайных мазков
    class StrokeImagePicker {
        private var available = Array(1...13).shuffled()

        func next() -> String {
            if available.isEmpty {
                available = Array(1...13).shuffled()
            }
            return "brush_stroke_\(available.removeFirst())"
        }

        // ++ Синтаксический сахар для назначения в State
        func nextAndAssign(to binding: Binding<String>) -> String {
            let next = self.next()
            binding.wrappedValue = next
            return next
        }
    }
}
