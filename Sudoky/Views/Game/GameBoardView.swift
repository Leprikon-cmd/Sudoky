//
//  GameBoardView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.

import SwiftUI

struct GameBoardView: View {
    let cells: [[Cell]]
    let highlightedValue: Int?
    let highlightEnabled: Bool
    let showErrors: Bool
    let onCellTap: (Int, Int) -> Void
    let geo: GeometryProxy  // ← передаём геометрию родительского экрана

    var body: some View {
        let gridSize = min(geo.size.width, geo.size.height * 0.7)
        let cellSize = gridSize / 9

        VStack {
            Spacer()

            ZStack {
                SudokuGridView(
                    cells: cells,
                    onCellTap: onCellTap,
                    highlightedValue: highlightEnabled ? highlightedValue : nil,
                    highlightEnabled: highlightEnabled,
                    showErrors: showErrors,
                    cellSize: cellSize
                )

                GridOverlayView(gridSize: gridSize)
            }
            .frame(width: gridSize, height: gridSize)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
    }
}

