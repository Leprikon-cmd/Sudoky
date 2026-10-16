import SwiftUI

enum GameBoardPresentation: Equatable {
    case standard
    case fontPreview
}

private enum FontPreviewFrameGeometry {
    // Bounds of the PNG opening measured at alpha >= 128 to ignore faint edge noise.
    static let assetSide: CGFloat = 1224
    static let opening = CGRect(x: 42, y: 12, width: 1171, height: 1171)
}

struct GameBoardView: View {
    @EnvironmentObject private var fontManager: FontManager
    let cells: [[Cell]]
    let highlightedValue: Int?
    let highlightEnabled: Bool
    let showErrors: Bool
    let onCellTap: (Int, Int) -> Void
    var customWidth: CGFloat? = nil // + добавили возможность вручную задать ширину
    var presentation: GameBoardPresentation = .standard

    var body: some View {
        GeometryReader { geo in
            // 📐 Получаем размер рамки (ограничение по ширине/высоте)
            let screenWidth = UIScreen.main.bounds.width
            let isPad = UIDevice.current.userInterfaceIdiom == .pad

            // + уменьшаем ширину на iPad (на 25%)
            let frameSize = customWidth ?? (isPad ? screenWidth * 0.75 : screenWidth - 4)
            let isFontPreview = presentation == .fontPreview
            let frameInset: CGFloat = isFontPreview ? 0 : 5
            let frameCorrection: CGFloat = isFontPreview ? 0 : (isPad ? 12 : 10)
            let gridSize = frameSize - frameInset * 2
            let cellSize = gridSize / 9 // ++ размер одной ячейки
            let previewNoteFontSize = isFontPreview ? fontManager.previewNoteFontSize(cellSize: cellSize) : nil
            let previewFrameScale = gridSize / FontPreviewFrameGeometry.opening.width
            let previewFrameSide = FontPreviewFrameGeometry.assetSide * previewFrameScale
            let previewFrameOffset = CGSize(
                width: (FontPreviewFrameGeometry.assetSide / 2 - FontPreviewFrameGeometry.opening.midX) * previewFrameScale,
                height: (FontPreviewFrameGeometry.assetSide / 2 - FontPreviewFrameGeometry.opening.midY) * previewFrameScale
            )
            let previewContainerSide = previewFrameSide + 2 * max(abs(previewFrameOffset.width), abs(previewFrameOffset.height))
            let containerSide = isFontPreview ? previewContainerSide : frameSize

            ZStack {
                // 🧩 Игровое поле
                ZStack {
                    // Ячейки
                    VStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<9, id: \.self) { col in
                                    let cell = cells[row][col]
                                    CellView(
                                        cell: cell,
                                        row: row,
                                        col: col,
                                        cellSize: cellSize,
                                        highlightedValue: highlightEnabled ? highlightedValue : nil,
                                        showErrors: showErrors,
                                        presentation: presentation,
                                        previewNoteFontSize: previewNoteFontSize
                                    )
                                    .onTapGesture {
                                        onCellTap(row, col)
                                    }
                                }
                            }
                        }
                    }

                    // Линии поверх
                    GridLinesOverlay(gridSize: gridSize, presentation: presentation)
                }
                .frame(width: gridSize, height: gridSize)
                .clipped()

                // В preview внутреннее окно PNG точно совмещено с квадратом сетки.
                if isFontPreview {
                    Image("game_board_frame_thin")
                        .resizable()
                        .frame(width: previewFrameSide, height: previewFrameSide)
                        .offset(x: previewFrameOffset.width, y: previewFrameOffset.height)
                        .allowsHitTesting(false)
                } else {
                    Image("game_board_frame_thin")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: frameSize + frameCorrection,
                            height: frameSize + frameCorrection
                        )
                        .offset(
                            x: -frameCorrection / 2,
                            y: frameCorrection / 2
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(width: containerSide, height: containerSide)
            .position(x: geo.size.width / 2, y: geo.size.height / 2) // центрируем явно
        }
        .aspectRatio(1, contentMode: .fit) // поле и рамка всегда квадратные
    }

    // MARK: - Сетка линий поверх поля
    private struct GridLinesOverlay: View {
        let gridSize: CGFloat
        let presentation: GameBoardPresentation

        private var majorLineWidth: CGFloat { presentation == .fontPreview ? 1 : 1 }

        var body: some View {
            ZStack {
                // Горизонтальные линии
                ForEach(1..<9, id: \.self) { i in
                    Rectangle()
                        .fill(i % 3 == 0 ? Color("Line") : Color.gray)
                        .frame(height: i % 3 == 0 ? majorLineWidth : 0.5)
                        .offset(y: CGFloat(i) * gridSize / 9 - gridSize / 2)
                }

                // Вертикальные линии
                ForEach(1..<9, id: \.self) { i in
                    Rectangle()
                        .fill(i % 3 == 0 ? Color("Line") : Color.gray)
                        .frame(width: i % 3 == 0 ? majorLineWidth : 0.5)
                        .offset(x: CGFloat(i) * gridSize / 9 - gridSize / 2)
                }
            }
            .frame(width: gridSize, height: gridSize)
            .allowsHitTesting(false)
        }
    }
}
