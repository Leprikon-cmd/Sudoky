//
//  CellView.swift
//  Отвечает за внешний вид ячейки
//  Sudoky
//

import SwiftUI

struct CellView: View {
    @EnvironmentObject var fontManager: FontManager // ++ Менеджер шрифтов
    let cell: Cell
    let row: Int
    let col: Int
    let cellSize: CGFloat // ++ Используется для всех размеров и расчётов
    
    let highlightedValue: Int?
    let showErrors: Bool
    
    @State private var strokeName: String = ""
    @State private var showBrush: Bool = false
    
    private static var picker = StrokeImagePicker() // ++ Генератор случайных мазков
    
    private func textColor() -> Color {
        if isError {
            return .red // ++ если ошибка — красный
        } else if cell.isEditable {
            return Color("ButtonPrimary") // + пользовательский ввод
        } else {
            return Color("ColorPrimary")    // ++ изначальные цифры
        }
    }
    
    var isHighlighted: Bool {
        highlightedValue != nil && highlightedValue == cell.value && cell.value != 0
    }
    
    var isError: Bool {
        showErrors && cell.hasError
    }
    
    var body: some View {
        ZStack {
            // 🟫 Фон ячейки
            Rectangle()
                .fill(Color("CellBackground")) // ++ Фон, цвет из Assets
            
            // 🔢 Основная цифра или заметки
            if cell.value != 0 {
                Text("\(cell.value)")
                    .textStyle(size: cellSize * 0.8, customColor: textColor()) // ✅ Централизованно
                    .frame(width: cellSize, height: cellSize)
            } else if !cell.notes.isEmpty {
                VStack(spacing: 1) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 1) {
                            ForEach(1..<4) { col in
                                let noteValue = row * 3 + col
                                Text(cell.notes.contains(noteValue) ? "\(noteValue)" : "")
                                    .textStyle(size: cellSize * 0.3)
                                    .frame(width: cellSize / 3, height: cellSize / 3)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        
            
            // 🖌️ Обводка (мазок) — поверх всего
            if (cell.isSelected || isHighlighted), !strokeName.isEmpty {
                Image(strokeName) // ++ Просто используем текущее имя, НИЧЕГО НЕ МЕНЯЕМ
                    .resizable()
                    .scaledToFit()
                    .frame(width: cellSize * 1, height: cellSize * 1) // 🔧 увеличение мазка
                    .opacity(showBrush ? 0.8 : 0) // 🔧 Прозрачность мазка
                    .allowsHitTesting(false)
                    .zIndex(10) // ++ Мазок всегда сверху
                    .animation(.easeOut(duration: 0.4), value: showBrush) // ++ Стабильная анимация
            }
        }
        .frame(width: cellSize, height: cellSize) // ++ фиксированный размер ячейки
        .onChange(of: cell.isSelected) { _, _ in handleBrushChange() }
        .onChange(of: isHighlighted) { _, _ in handleBrushChange() }
    }

    // ++ Управление появлением и исчезновением мазка
    private func handleBrushChange() {
        if cell.isSelected || isHighlighted {
            if strokeName.isEmpty {
                strokeName = Self.picker.next() // ++ Генерируем ОДИН РАЗ
                }
            showBrush = true
        } else {
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
        private var available = Array(1...9).shuffled()

        func next() -> String {
            if available.isEmpty {
                available = Array(1...9).shuffled()
            }
            return "stroke_brush_\(available.removeFirst())"
        }

        // ++ Синтаксический сахар для назначения в State
        func nextAndAssign(to binding: Binding<String>) -> String {
            let next = self.next()
            binding.wrappedValue = next
            return next
        }
    }
}
