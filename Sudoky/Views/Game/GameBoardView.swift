import SwiftUI

struct GameBoardView: View {
    let cells: [[Cell]]
    let highlightedValue: Int?
    let highlightEnabled: Bool
    let showErrors: Bool
    let onCellTap: (Int, Int) -> Void
    var customWidth: CGFloat? = nil // + добавили возможность вручную задать ширину

    var body: some View {
        GeometryReader { geo in
            // 📐 Получаем размер рамки (ограничение по ширине/высоте)
            let screenWidth = UIScreen.main.bounds.width
            let isPad = UIDevice.current.userInterfaceIdiom == .pad

            // + уменьшаем ширину на iPad (на 25%)
            let frameSize = isPad ? screenWidth * 0.75 : screenWidth - 4 // Уменьшаем поле на 4 pt.
            let frameInset: CGFloat = 5
            let frameCorrection: CGFloat = isPad ? 12 : 10
            let gridSize = frameSize - frameInset * 2
            let cellSize = gridSize / 9 // ++ размер одной ячейки

            ZStack {
                // 🧩 Игровое поле
                ZStack {
                    // Ячейки
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

                    // Линии поверх
                    GridLinesOverlay(gridSize: gridSize)
                }
                .frame(width: gridSize, height: gridSize)
                .clipped()

                // Тонкая деревянная рамка оставляет сетку главным элементом экрана.
                Image("game_board_frame_thin")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: frameSize + frameCorrection,
                        height: frameSize + frameCorrection
                    )
                    .offset(
                        x: -frameCorrection / 2,
                        y: frameCorrection / 2
                    )
                    .allowsHitTesting(false)
            }
            .frame(width: frameSize, height: frameSize)
            .position(x: geo.size.width / 2, y: geo.size.height / 2) // центрируем явно
        }
        .aspectRatio(1, contentMode: .fit) // поле и рамка всегда квадратные
    }

    // MARK: - Сетка линий поверх поля
    private struct GridLinesOverlay: View {
        let gridSize: CGFloat

        var body: some View {
            ZStack {
                // Горизонтальные линии
                ForEach(1..<9, id: \.self) { i in
                    Rectangle()
                        .fill(i % 3 == 0 ? Color("Line") : Color.gray)
                        .frame(height: i % 3 == 0 ? 2 : 0.5)
                        .offset(y: CGFloat(i) * gridSize / 9 - gridSize / 2)
                }

                // Вертикальные линии
                ForEach(1..<9, id: \.self) { i in
                    Rectangle()
                        .fill(i % 3 == 0 ? Color("Line") : Color.gray)
                        .frame(width: i % 3 == 0 ? 2 : 0.5)
                        .offset(x: CGFloat(i) * gridSize / 9 - gridSize / 2)
                }
            }
            .frame(width: gridSize, height: gridSize)
            .allowsHitTesting(false)
        }
    }
}
