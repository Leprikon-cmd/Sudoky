
//  SudokuGenerator.swift
//  Sudoky

import Foundation

struct SudokuGenerator {
    static func generate(difficulty: Difficulty) -> [[Int]] {
        var board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        _ = fillBoard(&board)
        removeCells(&board, for: difficulty)
        return board
    }

    private static func fillBoard(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 {
                    let numbers = Array(1...9).shuffled()
                    for num in numbers {
                        if isValid(board, row, col, num) {
                            board[row][col] = num
                            if fillBoard(&board) {
                                return true
                            }
                            board[row][col] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }

    private static func isValid(_ board: [[Int]], _ row: Int, _ col: Int, _ num: Int) -> Bool {
        for i in 0..<9 {
            if board[row][i] == num || board[i][col] == num {
                return false
            }
        }

        let startRow = row / 3 * 3
        let startCol = col / 3 * 3
        for r in 0..<3 {
            for c in 0..<3 {
                if board[startRow + r][startCol + c] == num {
                    return false
                }
            }
        }

        return true
    }

    private static func removeCells(_ board: inout [[Int]], for difficulty: Difficulty) {
        let cellsToRemove: Int
        switch difficulty {
        case .новичок: cellsToRemove = 1 //Для тестов
        case .ученик:  cellsToRemove = 40
        case .мастер:  cellsToRemove = 50
        case .сенсей:  cellsToRemove = 60
        case .dokushin:  cellsToRemove = 60
        }

        var attempts = 0
        while attempts < cellsToRemove {
            let row = Int.random(in: 0..<9)
            let col = Int.random(in: 0..<9)
            if board[row][col] != 0 {
                board[row][col] = 0
                attempts += 1
            }
        }
    }
}
