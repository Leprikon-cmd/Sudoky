
//  GameView.swift
//  Sudoky

import SwiftUI

struct GameView: View {
    let difficulty: Difficulty
    @StateObject private var viewModel = SudokuViewModel()

    var body: some View {
        VStack {
            Text("Сложность: \(difficulty.rawValue.capitalized)")
                .font(.headline)

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
        .navigationTitle("Игра")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GameView(difficulty: .новичок)
}
