
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
    static func countSolutions(_ board: inout [[Int]], limit: Int = 2) -> Int {
        var count = 0
        
        func solve(_ row: Int, _ col: Int) -> Bool {
            var row = row
            var col = col
            
            if col == 9 {
                col = 0
                row += 1
                if row == 9 {
                    count += 1
                    return count >= limit
                }
            }
            
            if board[row][col] != 0 {
                return solve(row, col + 1)
            }
            
            for num in 1...9 {
                if isValid(board, row, col, num) {
                    board[row][col] = num
                    if solve(row, col + 1) {
                        board[row][col] = 0
                        return true
                    }
                    board[row][col] = 0
                }
            }
            
            return false
        }
        
        _ = solve(0, 0)
        return count
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
        let targetEmptyCount: Int
        switch difficulty {
        case .новичок: targetEmptyCount = 28
        case .ученик:  targetEmptyCount = 38
        case .мастер:  targetEmptyCount = 46
        case .сенсей, .dokushin: targetEmptyCount = 54
        }
        
        var attempts = 0
        var removed = 0
        
        while removed < targetEmptyCount && attempts < 500 {
            let row = Int.random(in: 0..<9)
            let col = Int.random(in: 0..<9)
            
            if board[row][col] == 0 { continue }
            
            let backup = board[row][col]
            board[row][col] = 0
            
            var copy = board
            let solutions = countSolutions(&copy)
            
            if solutions != 1 {
                board[row][col] = backup // откат
            } else {
                removed += 1
            }
            
            attempts += 1
        }
    }
}
