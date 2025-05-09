//  ContentView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()

    var body: some View {
        VStack {
            SudokuGridView(
                cells: viewModel.board.cells,
                onCellTap: { row, col in
                    viewModel.selectCell(row: row, col: col)
                }
            )

            KeypadView { number in
                viewModel.enterNumber(number)
            }
        }
        .padding()
    }
}
