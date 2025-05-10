//  SudokuViewModel.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import Foundation
import SwiftUI
import Combine

class SudokuViewModel: ObservableObject {
    @Published var board: SudokuBoard
    @Published var elapsedTime: TimeInterval = 0
    @Published var highlightedValue: Int? = nil
    @Published var isGameWon: Bool = false
    @Published var livesRemaining: Int
    @Published var isGameOver: Bool = false
    let showErrors: Bool  // ← переменная становится свойством класса
    let highlightIdenticals: Bool
    private var timerCancellable: AnyCancellable?

    init(difficulty: Difficulty, showErrors: Bool, highlightIdenticals: Bool) {
        self.showErrors = showErrors
        self.highlightIdenticals = highlightIdenticals
        let matrix = SudokuGenerator.generate(difficulty: difficulty)
        self.livesRemaining = difficulty.lives
        self.board = SudokuBoard(from: matrix)
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedTime += 1
            }
    }

    func stopTimer() {
        timerCancellable?.cancel()
    }

    func selectCell(row: Int, col: Int) {
        let selected = board.cell(atRow: row, col: col)
        highlightedValue = selected.value == 0 ? nil : selected.value
        board.selectCell(row: row, col: col)
        objectWillChange.send()
    }
    
    func restartGame(with difficulty: Difficulty) {
        stopTimer()
        let matrix = SudokuGenerator.generate(difficulty: difficulty)
        self.board = SudokuBoard(from: matrix)
        self.elapsedTime = 0
        self.highlightedValue = nil
        self.livesRemaining = difficulty.lives
        self.isGameOver = false
        self.isGameWon = false
        startTimer()
    }

    func enterNumber(_ number: Int) {
        guard let selected = selectedCell else { return }

        board.updateCell(row: selected.row, col: selected.col, with: number)
        board.validateBoard()
        objectWillChange.send()

        let isError = board.cells[selected.row][selected.col].hasError

        if isError {
            livesRemaining -= 1
            if livesRemaining <= 0 {
                stopTimer()
                isGameOver = true
            }
        }

        if !isGameOver && board.isSolved() {
            print("🎉 Победа засчитана")
            stopTimer()
            isGameWon = true
        }
    }

    var selectedCell: Cell? {
        for row in board.cells {
            for cell in row {
                if cell.isSelected { return cell }
            }
        }
        return nil
    }
}
