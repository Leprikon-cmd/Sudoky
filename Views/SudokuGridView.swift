//  SudokuGridView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import SwiftUI

struct SudokuGridView: View {
    let cells: [[Cell]]
    let onCellTap: (Int, Int) -> Void

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<9, id: \.self) { col in
                        let cell = cells[row][col]
                        CellView(cell: cell)
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
