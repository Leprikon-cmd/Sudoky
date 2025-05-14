import SwiftUI

struct GameBoardView: View {
    let cells: [[Cell]]
    let highlightedValue: Int?
    let highlightEnabled: Bool
    let showErrors: Bool
    let onCellTap: (Int, Int) -> Void
    let gridSize: CGFloat
    
    var body: some View {
        // 📐 Вычисляем размеры
        let cellSize = gridSize / 9
        let frameThickness: CGFloat = 18 // Толщина рамки (по каждой стороне)
        let frameSize = gridSize + frameThickness * 2 // Рамка + поле
        
        ZStack {
            // 🎨 Рамка вокруг поля
            Image("Frame3")
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: frameSize, height: frameSize)
                .allowsHitTesting(false)
            
            // 🧩 Поле с ячейками
            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<9, id: \.self) { col in
                                let cell = cells[row][col]
                                CellView(
                                    cell: cell,
                                    row: row,
                                    col: col,
                                    cellSize: cellSize,
                                    highlightedValue: highlightEnabled ? highlightedValue : nil,
                                    showErrors: showErrors
                                )
                                .onTapGesture {
                                    onCellTap(row, col)
                                }
                            }
                        }
                    }
                }
                
                GridLinesOverlay(gridSize: gridSize)
            }
            .frame(width: gridSize, height: gridSize) // 🧩 только поле
            .cornerRadius(16) // или 10 — можешь подбирать по вкусу
            .clipped()       // обязательно, чтобы обрезать содержимое по углам
        }
        .frame(width: frameSize, height: frameSize) // 🎨 вся конструкция
    }
}
private struct GridLinesOverlay: View {
    let gridSize: CGFloat

    var body: some View {
        ZStack {
            // Горизонтальные линии
            ForEach(1..<9, id: \.self) { i in
                Rectangle()
                    .fill(i % 3 == 0 ? (Color ("Line")) : Color.gray)
                    .frame(height: i % 3 == 0 ? 2 : 0.5)
                    .offset(y: CGFloat(i) * gridSize / 9 - gridSize / 2)
            }

            // Вертикальные линии
            ForEach(1..<9, id: \.self) { i in
                Rectangle()
                    .fill(i % 3 == 0 ? (Color ("Line")) : Color.gray)
                    .frame(width: i % 3 == 0 ? 2 : 0.5)
                    .offset(x: CGFloat(i) * gridSize / 9 - gridSize / 2)
            }
        }
        .frame(width: gridSize, height: gridSize)
        .allowsHitTesting(false)
    }
}
