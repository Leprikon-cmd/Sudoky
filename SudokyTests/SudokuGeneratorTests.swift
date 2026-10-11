//
//  SudokuGeneratorTests.swift
//  SudokyTests
//
//  Created by Евгений Зотчик on 20.05.2025.
//

import XCTest
@testable import Sudoky

final class SudokuGeneratorTests: XCTestCase {

    func testGeneratedBoardHasUniqueSolution() {
        for difficulty in Difficulty.allCases {
            let board = SudokuGenerator.generate(difficulty: difficulty)
            var copy = board
            let solutions = SudokuGenerator.countSolutions(&copy)

            XCTAssertEqual(solutions, 1, "❌ Доска для \(difficulty) имеет \(solutions) решений")
        }
    }

    func testEmptyCellsCountByDifficulty() {
        let expectedEmptyCounts: [Difficulty: Int] = [
            .новичок: 28,
            .ученик: 38,
            .мастер: 46,
            .сенсей: 54,
            .dokushin: 54
        ]

        for difficulty in Difficulty.allCases {
            let board = SudokuGenerator.generate(difficulty: difficulty)
            let emptyCells = board.flatMap { $0 }.filter { $0 == 0 }.count
            let expected = expectedEmptyCounts[difficulty] ?? 0

            XCTAssertEqual(emptyCells, expected, accuracy: 2, "❌ Кол-во пустых ячеек для \(difficulty) не совпадает")
        }
    }

#if DEBUG
    func testDebugTestModeNewAndRestartedGamesHaveOneEditableCellInEveryDifficulty() {
        let settings = SettingsManager.shared
        let previousTestMode = settings.testModeEnabled
        let previousSavedData = UserDefaults.standard.data(forKey: "savedGame")
        defer { settings.testModeEnabled = previousTestMode }
        defer {
            if let previousSavedData {
                UserDefaults.standard.set(previousSavedData, forKey: "savedGame")
            } else {
                UserDefaults.standard.removeObject(forKey: "savedGame")
            }
        }

        for difficulty in Difficulty.allCases {
            settings.testModeEnabled = true
            let viewModel = SudokuViewModel(
                difficulty: difficulty,
                showErrors: difficulty != .dokushin,
                highlightIdenticals: difficulty != .dokushin
            )
            if let answer = assertTestModeBoard(viewModel.board, difficulty: difficulty, phase: "new game") {
                viewModel.selectCell(row: answer.row, col: answer.col)
                viewModel.enterNumber(answer.value)
                XCTAssertTrue(viewModel.isGameWon, "Correct single input must win for \(difficulty)")
            }

            viewModel.restartGame(with: difficulty)
            assertTestModeBoard(viewModel.board, difficulty: difficulty, phase: "restart")

            settings.testModeEnabled = false
            viewModel.restartGame(with: difficulty)
            XCTAssertGreaterThan(
                viewModel.board.cells.flatMap { $0 }.filter { $0.value == 0 }.count,
                1,
                "Disabled test mode must use the normal generator for \(difficulty)"
            )
            viewModel.stopTimer()
        }
    }

    func testDebugTestModeDoesNotRewriteSavedGame() {
        let settings = SettingsManager.shared
        let previousTestMode = settings.testModeEnabled
        defer { settings.testModeEnabled = previousTestMode }
        settings.testModeEnabled = true

        let savedCells = SudokuBoard(from: SudokuGenerator.generate(difficulty: .новичок)).cells
        let savedGame = SavedGame(
            cells: savedCells,
            difficulty: .новичок,
            elapsedTime: 17,
            livesRemaining: 8,
            highlightedValue: 4
        )
        let viewModel = SudokuViewModel(savedGame: savedGame)
        defer { viewModel.stopTimer() }

        XCTAssertGreaterThan(savedCells.flatMap { $0 }.filter { $0.value == 0 }.count, 1)
        XCTAssertEqual(viewModel.board.cells, savedCells)
        XCTAssertEqual(viewModel.elapsedTime, savedGame.elapsedTime)
        XCTAssertEqual(viewModel.livesRemaining, savedGame.livesRemaining)
        XCTAssertEqual(viewModel.highlightedValue, savedGame.highlightedValue)
    }

    private func assertTestModeBoard(
        _ board: SudokuBoard,
        difficulty: Difficulty,
        phase: String
    ) -> (row: Int, col: Int, value: Int)? {
        let cells = board.cells.flatMap { $0 }
        let editableCells = cells.filter(\.isEditable)
        let emptyCells = cells.filter { $0.value == 0 }

        XCTAssertEqual(cells.count, 81, "\(phase), \(difficulty)")
        XCTAssertEqual(editableCells.count, 1, "\(phase), \(difficulty)")
        XCTAssertEqual(emptyCells.count, 1, "\(phase), \(difficulty)")
        XCTAssertEqual(editableCells.first?.value, 0, "\(phase), \(difficulty)")
        XCTAssertEqual(cells.filter { !$0.isEditable }.count, 80, "\(phase), \(difficulty)")

        var matrix = board.cells.map { $0.map(\.value) }
        var copy = matrix
        XCTAssertEqual(SudokuGenerator.countSolutions(&copy), 1, "\(phase), \(difficulty)")

        if let emptyCell = editableCells.first {
            let correctValue = Set(1...9).subtracting(Set(matrix[emptyCell.row])).first
            if let correctValue {
                matrix[emptyCell.row][emptyCell.col] = correctValue
                XCTAssertTrue(SudokuBoard(from: matrix).isSolved(), "\(phase), \(difficulty)")
                return (emptyCell.row, emptyCell.col, correctValue)
            } else {
                XCTFail("Could not determine the missing value for \(phase), \(difficulty)")
            }
        }

        return nil
    }
#endif
}
