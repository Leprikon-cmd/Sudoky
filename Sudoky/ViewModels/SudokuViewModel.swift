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
    let difficulty: Difficulty  // ← сохраняем сложность внутри ViewModel
    private var timerCancellable: AnyCancellable?

    init(loadSaved: Bool = false, difficulty: Difficulty, showErrors: Bool, highlightIdenticals: Bool) {
        self.difficulty = difficulty
        self.showErrors = showErrors
        self.highlightIdenticals = highlightIdenticals
        self.livesRemaining = difficulty.lives
        self.elapsedTime = 0

        if loadSaved, let saved = GamePersistenceManager.shared.load() {
            self.board = SudokuBoard(from: saved.cells)
            self.elapsedTime = saved.elapsedTime
            self.livesRemaining = saved.livesRemaining
            self.highlightedValue = saved.highlightedValue
        } else {
            let matrix = SudokuGenerator.generate(difficulty: difficulty)
            self.board = SudokuBoard(from: matrix)
        }

        startTimer()
    }
    
    /// Сохраняет текущее состояние игры
    func saveGame() {
        let saved = SavedGame(
            cells: board.cells,              // сохраняем ячейки
            difficulty: self.difficulty,     // сохраняем текущую сложность
            elapsedTime: elapsedTime,        // сколько времени прошло
            livesRemaining: livesRemaining,  // сколько жизней осталось
            highlightedValue: highlightedValue  // текущее выделенное значение
        )
        GamePersistenceManager.shared.save(saved)  // сохраняем через менеджер
    }
    
    /// Загружает сохранённую игру (если есть)
    func loadGame() {
        guard let saved = GamePersistenceManager.shared.load() else { return }

        self.board = SudokuBoard(from: saved.cells)
        self.elapsedTime = saved.elapsedTime
        self.livesRemaining = saved.livesRemaining
        self.highlightedValue = saved.highlightedValue
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
        saveGame()

        let isError = board.cells[selected.row][selected.col].hasError

        if isError {
            livesRemaining -= 1
            if livesRemaining <= 0 {
                stopTimer()
                isGameOver = true
                GamePersistenceManager.shared.clear()
            }
        }

        if !isGameOver && board.isSolved() {
            print("🎉 Победа засчитана")
            stopTimer()
            isGameWon = true
            GamePersistenceManager.shared.clear()
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
