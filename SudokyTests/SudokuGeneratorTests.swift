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
            var board = SudokuGenerator.generate(difficulty: difficulty)
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
}
