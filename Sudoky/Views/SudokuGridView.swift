//SudokuGridView — за сборку всего поля

import SwiftUI

struct SudokuGridView: View {
    let cells: [[Cell]]
    let onCellTap: (Int, Int) -> Void
    let highlightedValue: Int?
    let highlightEnabled: Bool
    let showErrors: Bool
    let cellSize: CGFloat   // Размер каждой ячейки

    var body: some View {
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
        .padding()
    }
}
