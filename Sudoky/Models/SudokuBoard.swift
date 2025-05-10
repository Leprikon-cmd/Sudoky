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
    
    init(from cells: [[Cell]]) {
        self.cells = cells
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
    mutating func validateBoard() {
        for row in 0..<9 {
            for col in 0..<9 {
                let value = cells[row][col].value

                if value == 0 {
                    cells[row][col].hasError = false // <-- ключевая строка
                } else {
                    cells[row][col].hasError = !isValid(row: row, col: col, value: value)
                }
            }
        }
    }
    func isSolved() -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                let val = cells[row][col].value
                if val == 0 || !isValid(row: row, col: col, value: val) {
                    return false
                }
            }
        }
        return true
    }

    // Валидатор (переиспользуем из генератора)
    private func isValid(row: Int, col: Int, value: Int) -> Bool {
        for i in 0..<9 {
            if i != col && cells[row][i].value == value { return false }
            if i != row && cells[i][col].value == value { return false }
        }

        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in 0..<3 {
            for c in 0..<3 {
                let checkRow = boxRow + r
                let checkCol = boxCol + c
                if (checkRow != row || checkCol != col),
                   cells[checkRow][checkCol].value == value {
                    return false
                }
            }
        }

        return true
    }
}
