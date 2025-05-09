//  SudokuBoard.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import Foundation

struct SudokuBoard {
    var cells: [[Cell]]

    init(from matrix: [[Int]]) {
        self.cells = []
        for row in 0..<9 {
            var rowCells: [Cell] = []
            for col in 0..<9 {
                let value = matrix[row][col]
                let cell = Cell(
                    row: row,
                    col: col,
                    value: value,
                    isEditable: value == 0,
                    isSelected: false
                )
                rowCells.append(cell)
            }
            self.cells.append(rowCells)
        }
    }

    func cell(atRow row: Int, col: Int) -> Cell {
        return cells[row][col]
    }

    mutating func updateCell(row: Int, col: Int, with value: Int) {
        guard cells[row][col].isEditable else { return }
        cells[row][col].value = value
    }

    mutating func selectCell(row: Int, col: Int) {
        for r in 0..<9 {
            for c in 0..<9 {
                cells[r][c].isSelected = (r == row && c == col)
            }
        }
    }
}
