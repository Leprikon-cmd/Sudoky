import SwiftUI

// MARK: - Уровни сложности
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case новичок, ученик, мастер, сенсей, dokushin

    var id: String { rawValue }

    var localizedName: String {
        loc("difficulty.\(rawValue)")
    }

    var lives: Int {
        switch self {
        case .новичок: return 10
        case .ученик: return 6
        case .мастер: return 4
        case .сенсей: return 3
        case .dokushin: return 1
        }
    }
}

// MARK: - Экран выбора сложности
struct DifficultyPickerView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let viewportSize = CGSize(
                width: geometry.size.width + safeArea.leading + safeArea.trailing,
                height: geometry.size.height + safeArea.top + safeArea.bottom
            )
            if DifficultyPickerGeometry.hasUsableViewport(viewportSize) {
            let scale = viewportSize.height / 1844
            let canvasSize = CGSize(width: 853 * scale, height: 1844 * scale)
            let titleFrame = headerTitleRect.scaled(to: canvasSize)
            let topUIShift = max(0, safeArea.top + 8 - titleFrame.minY)
            let backRect = expandedBackRect(canvasSize: canvasSize)
            let safeBackRect = backRect.offsetBy(
                dx: 0,
                dy: max(0, safeArea.top + 30 - backRect.midY)
            )

            ZStack {
                Color(red: 0.976, green: 0.82, blue: 0.64)

                Image("difficulty_path_background_tall_v5")
                    .resizable()
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .position(x: viewportSize.width / 2, y: viewportSize.height / 2)
                    .accessibilityHidden(true)

                ZStack(alignment: .topLeading) {
                    canvasText(
                        loc("difficulty.title"),
                        in: headerTitleRect,
                        canvasSize: canvasSize,
                        size: 68 * scale,
                        alignment: .center,
                        centered: true,
                        lineLimit: 1,
                        accessibilityHidden: false,
                        isHeader: true
                    )
                    .offset(y: topUIShift)
                    canvasText(
                        loc("difficulty.subtitle"),
                        in: headerSubtitleRect,
                        canvasSize: canvasSize,
                        size: 32 * scale,
                        alignment: .center,
                        centered: true,
                        lineLimit: 1,
                        accessibilityHidden: false
                    )
                    .offset(y: topUIShift)

                    ForEach(Difficulty.allCases) { difficulty in
                        difficultyRow(difficulty, canvasSize: canvasSize, topUIShift: topUIShift)
                    }

                    backButton(frame: safeBackRect)
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .position(x: viewportSize.width / 2, y: viewportSize.height / 2)
            }
            .frame(width: viewportSize.width, height: viewportSize.height)
            .clipped()
            .position(
                x: viewportSize.width / 2 - safeArea.leading,
                y: viewportSize.height / 2 - safeArea.top
            )
            } else {
                Color.clear
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func difficultyRow(_ difficulty: Difficulty, canvasSize: CGSize, topUIShift: CGFloat) -> some View {
        let normalizedFrame = rowFrame(for: difficulty, canvasSize: canvasSize, topUIShift: topUIShift)
        let frame = normalizedFrame.scaled(to: canvasSize)
        let textWidth = 0.27 * canvasSize.width
        let boardSide = 0.132629 * canvasSize.width
        let leftInset = 0.03 * canvasSize.width
        let boardX = 0.818075 * canvasSize.width
        let gap = max(0, boardX - frame.minX - leftInset - textWidth)
        let scale = canvasSize.height / 1844
        let titleSize = max(20, 46 * scale)
        let descriptionSize = max(14, 29 * scale)

        return Button {
            path.append(Route.game(difficulty))
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2 * scale) {
                    Text(difficulty.localizedName)
                        .textStyle(size: titleSize, color: settingsManager.selectedTextColor)
                        .lineLimit(1)
                        .allowsTightening(true)

                    Text(loc("difficulty.description.\(difficulty.rawValue)"))
                        .textStyle(size: descriptionSize, color: settingsManager.selectedTextColor)
                        .lineLimit(3)
                        .allowsTightening(true)
                }
                .frame(width: textWidth, alignment: .leading)

                Color.clear
                    .frame(width: gap)

                DifficultyMiniBoard(difficulty: difficulty, side: boardSide)
                Spacer(minLength: 0)
            }
            .padding(.leading, leftInset)
            .frame(width: frame.width, height: frame.height, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: frame.width, height: frame.height)
        .position(x: frame.midX, y: frame.midY)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(difficulty.localizedName))
        .accessibilityHint(Text(loc("difficulty.description.\(difficulty.rawValue)")))
    }

    private func backButton(frame: CGRect) -> some View {
        RoundBrushIconButton(
            assetName: "nav_back_brush_transparent_v3",
            accessibilityLabelKey: "common.back"
        ) {
            guard !path.isEmpty else { return }
            path.removeLast()
        }
        .frame(width: frame.width, height: frame.height)
        .position(x: frame.midX, y: frame.midY)
    }

    private func expandedBackRect(canvasSize: CGSize) -> CGRect {
        let original = CanvasRect(x: 0.061, y: 0.0363, width: 0.115, height: 0.0542).scaled(to: canvasSize)
        let width = max(original.width, min(44, canvasSize.width))
        let height = max(original.height, min(44, canvasSize.height))
        let center = CGPoint(x: original.midX, y: original.midY)
        return CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
    }

    private func rowFrame(for difficulty: Difficulty, canvasSize: CGSize, topUIShift: CGFloat) -> CanvasRect {
        let rows = Difficulty.allCases.map(rowAnchor)
        guard let index = Difficulty.allCases.firstIndex(of: difficulty) else {
            return CanvasRect(x: 0.49, y: 0.12, width: 0.48, height: 0.12)
        }
        let firstDivider = (rows[0] + rows[1]) / 2 + 20 / canvasSize.height
        let top = index == 0
            ? headerSubtitleRect.maxY + topUIShift / canvasSize.height + 0.006
            : (index == 1 ? firstDivider : (rows[index - 1] + rows[index]) / 2)
        let bottom = index == rows.count - 1
            ? 0.95
            : (index == 0 ? firstDivider : (rows[index] + rows[index + 1]) / 2)
        let interval = DifficultyPickerGeometry.verticalInterval(top: top, bottom: bottom)
        return CanvasRect(x: 0.49, y: interval.origin, width: 0.48, height: interval.length)
    }

    private func rowAnchor(_ difficulty: Difficulty) -> CGFloat {
        switch difficulty {
        case .новичок: return 0.1530335
        case .ученик: return 0.2965865
        case .мастер: return 0.4731845
        case .сенсей: return 0.6541165
        case .dokushin: return 0.8410075
        }
    }

    private var headerTitleRect: CanvasRect {
        CanvasRect(x: 0.25, y: 0.050, width: 0.70, height: 0.041)
    }

    private var headerSubtitleRect: CanvasRect {
        CanvasRect(x: 0.25, y: 0.094, width: 0.70, height: 0.025)
    }

    private func canvasText(
        _ value: String,
        in rect: CanvasRect,
        canvasSize: CGSize,
        size: CGFloat,
        alignment: TextAlignment,
        centered: Bool = false,
        lineLimit: Int,
        accessibilityHidden: Bool = true,
        isHeader: Bool = false
    ) -> some View {
        let frame = rect.scaled(to: canvasSize)
        return Text(value)
            .textStyle(size: size, color: settingsManager.selectedTextColor)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
            .minimumScaleFactor(0.72)
            .allowsTightening(true)
            .frame(width: frame.width, height: frame.height, alignment: centered ? .center : .topLeading)
            .position(x: frame.midX, y: frame.midY)
            .accessibilityHidden(accessibilityHidden)
            .accessibilityAddTraits(isHeader ? .isHeader : [])
    }
}

private struct DifficultyMiniBoard: View {
    let difficulty: Difficulty
    let side: CGFloat

    private var filledCells: Set<Int> {
        switch difficulty {
        case .новичок: return Set(0...6)
        case .ученик: return Set(0...4)
        case .мастер: return Set([0, 1, 3])
        case .сенсей: return Set([0, 4])
        case .dokushin: return Set([0])
        }
    }

    var body: some View {
        let lineWidth = max(0.8, side * 0.014)
        let cellSide = DifficultyPickerGeometry.miniBoardCellSide(side: side, lineWidth: lineWidth)

        VStack(spacing: lineWidth) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: lineWidth) {
                    ForEach(0..<3, id: \.self) { column in
                        Rectangle()
                            .fill(filledCells.contains(row * 3 + column) ? olive : paper)
                            .frame(width: cellSide, height: cellSide)
                    }
                }
            }
        }
        .padding(lineWidth)
        .background(grid)
        .overlay(Rectangle().strokeBorder(grid, lineWidth: lineWidth))
        .shadow(color: grid.opacity(0.15), radius: 1, y: 0.5)
        .accessibilityHidden(true)
    }

    private var olive: Color {
        Color(red: 115.0 / 255, green: 109.0 / 255, blue: 55.0 / 255)
    }

    private var paper: Color {
        Color(red: 252.0 / 255, green: 229.0 / 255, blue: 193.0 / 255)
    }

    private var grid: Color {
        Color(red: 26.0 / 255, green: 21.0 / 255, blue: 14.0 / 255)
    }
}

private struct CanvasRect {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    var maxY: CGFloat { y + height }

    func scaled(to size: CGSize) -> CGRect {
        CGRect(x: x * size.width, y: y * size.height, width: width * size.width, height: height * size.height)
    }
}

#Preview {
    DifficultyPickerView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
}
