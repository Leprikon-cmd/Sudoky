import SwiftUI

// MARK: - Уровни сложности
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case новичок, ученик, мастер, сенсей, dokushin
    
    var parchmentImage: String {
            switch self {
            case .новичок: return "parchment_bg2"
            case .ученик:  return "parchment_bg6"
            case .мастер:  return "parchment_bg3"
            case .сенсей:  return "parchment_bg4"
            case .dokushin: return "parchment_bg7"
            }
        }
    
    var id: String { self.rawValue }

    var localizedName: String {
        loc("difficulty.\(self.rawValue)") // ✅ Единый универсальный ключ
    }

    var lives: Int {
        switch self {
        case .новичок: return 10
        case .ученик:  return 6
        case .мастер:  return 4
        case .сенсей:  return 3
        case .dokushin: return 1
        }
    }
}

// MARK: - Экран выбора сложности
struct DifficultyPickerView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var languageManager: LanguageManager // Локализация

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let viewportSize = CGSize(
                width: geometry.size.width + safeArea.leading + safeArea.trailing,
                height: geometry.size.height + safeArea.top + safeArea.bottom
            )
            let scale = viewportSize.height / 1846
            let canvasSize = CGSize(width: 852 * scale, height: 1846 * scale)
            let backOrigin = max(0, safeArea.top + 8 - 0.0363 * canvasSize.height)
            let backRect = expandedBackRect(canvasSize: canvasSize)

            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.86)

                if backOrigin > 0 {
                    Image("difficulty_path_background_tall_v3")
                        .resizable()
                        .frame(width: canvasSize.width, height: canvasSize.height)
                        .frame(width: viewportSize.width, height: backOrigin, alignment: .top)
                        .clipped()
                        .position(x: viewportSize.width / 2, y: backOrigin / 2)
                        .accessibilityHidden(true)
                }

                ZStack(alignment: .topLeading) {
                    Image("difficulty_path_background_tall_v3")
                        .resizable()
                        .frame(width: canvasSize.width, height: canvasSize.height)
                        .accessibilityHidden(true)

                    canvasText(loc("difficulty.title"), in: headerTitleRect, canvasSize: canvasSize, size: 68 * scale, alignment: .center, centered: true, lineLimit: 1, accessibilityHidden: false, isHeader: true)
                    canvasText(loc("difficulty.subtitle"), in: headerSubtitleRect, canvasSize: canvasSize, size: 32 * scale, alignment: .center, centered: true, lineLimit: 1, accessibilityHidden: false)

                    ForEach(Difficulty.allCases) { difficulty in
                        difficultyLabels(difficulty, canvasSize: canvasSize, scale: scale)
                        difficultyButton(difficulty, canvasSize: canvasSize, backRect: backRect, safeBottom: safeArea.bottom, backOrigin: backOrigin)
                    }

                    backButton(frame: backRect)
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .position(x: viewportSize.width / 2, y: backOrigin + canvasSize.height / 2)
            }
            .frame(width: viewportSize.width, height: viewportSize.height)
            .clipped()
            .position(
                x: viewportSize.width / 2 - safeArea.leading,
                y: viewportSize.height / 2 - safeArea.top
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func difficultyLabels(_ difficulty: Difficulty, canvasSize: CGSize, scale: CGFloat) -> some View {
        let rects = difficultyTextRects(for: difficulty)
        return Group {
            canvasText(difficulty.localizedName, in: rects.title, canvasSize: canvasSize, size: 50 * scale, alignment: .leading, lineLimit: 1)
            canvasText(loc("difficulty.description.\(difficulty.rawValue)"), in: rects.description, canvasSize: canvasSize, size: 29 * scale, alignment: .leading, lineLimit: 2)
        }
    }

    private func difficultyTextRects(for difficulty: Difficulty) -> (title: CanvasRect, description: CanvasRect) {
        let board = boardRect(for: difficulty)
        let textBlockHeight: CGFloat = 0.032 + 0.003 + 0.047
        let titleY = board.midY - textBlockHeight / 2
        let x: CGFloat = 0.56
        let width = board.x - x - 0.018
        let title = CanvasRect(x: x, y: titleY, width: width, height: 0.032)
        let description = CanvasRect(x: x, y: titleY + 0.035, width: width, height: 0.047)
        return (title, description)
    }

    private var headerTitleRect: CanvasRect {
        CanvasRect(x: 0.25, y: 0.050, width: 0.70, height: 0.041)
    }

    private var headerSubtitleRect: CanvasRect {
        CanvasRect(x: 0.25, y: 0.094, width: 0.70, height: 0.025)
    }

    private func canvasText(_ value: String, in rect: CanvasRect, canvasSize: CGSize, size: CGFloat, alignment: TextAlignment, centered: Bool = false, lineLimit: Int, accessibilityHidden: Bool = true, isHeader: Bool = false) -> some View {
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

    private func difficultyButton(_ difficulty: Difficulty, canvasSize: CGSize, backRect: CGRect, safeBottom: CGFloat, backOrigin: CGFloat) -> some View {
        let frame = tapRect(for: difficulty, canvasSize: canvasSize, backRect: backRect, safeBottom: safeBottom, backOrigin: backOrigin).scaled(to: canvasSize)
        return Button {
            path.append(Route.game(difficulty))
        } label: {
            Rectangle()
                .fill(Color.clear)
                .frame(width: frame.width, height: frame.height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .position(x: frame.midX, y: frame.midY)
        .accessibilityLabel(Text(difficulty.localizedName))
        .accessibilityHint(Text(loc("difficulty.description.\(difficulty.rawValue)")))
    }

    private func backButton(frame: CGRect) -> some View {
        return Button {
            guard !path.isEmpty else { return }
            path.removeLast()
        } label: {
            Rectangle()
                .fill(Color.clear)
                .frame(width: frame.width, height: frame.height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .position(x: frame.midX, y: frame.midY)
        .accessibilityLabel(Text(loc("common.back")))
    }

    private func expandedBackRect(canvasSize: CGSize) -> CGRect {
        let original = CanvasRect(x: 0.061, y: 0.0363, width: 0.115, height: 0.0542).scaled(to: canvasSize)
        let width = max(original.width, min(44, canvasSize.width))
        let height = max(original.height, min(44, canvasSize.height))
        let center = CGPoint(x: original.midX, y: original.midY)
        return CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
    }

    private func boardRect(for difficulty: Difficulty) -> CanvasRect {
        switch difficulty {
        case .новичок: return CanvasRect(x: 0.818075, y: 0.122427, width: 0.132629, height: 0.061213)
        case .ученик: return CanvasRect(x: 0.818075, y: 0.265980, width: 0.132629, height: 0.061213)
        case .мастер: return CanvasRect(x: 0.818075, y: 0.442578, width: 0.132629, height: 0.061213)
        case .сенсей: return CanvasRect(x: 0.818075, y: 0.623510, width: 0.132629, height: 0.061213)
        case .dokushin: return CanvasRect(x: 0.818075, y: 0.810401, width: 0.132629, height: 0.061213)
        }
    }

    private func tapRect(for difficulty: Difficulty, canvasSize: CGSize, backRect: CGRect, safeBottom: CGFloat, backOrigin: CGFloat) -> CanvasRect {
        let noviceBoard = boardRect(for: .новичок)
        let studentBoard = boardRect(for: .ученик)
        let masterBoard = boardRect(for: .мастер)
        let senseiBoard = boardRect(for: .сенсей)
        let lastBoard = boardRect(for: .dokushin)
        let noviceStudentMidpoint = (noviceBoard.midY + studentBoard.midY) / 2
        let studentMasterMidpoint = (studentBoard.midY + masterBoard.midY) / 2
        let masterSenseiMidpoint = (masterBoard.midY + senseiBoard.midY) / 2
        let senseiDokushinMidpoint = (senseiBoard.midY + lastBoard.midY) / 2
        let noviceTextTop = difficultyTextRects(for: .новичок).title.y
        let lastTextBottom = difficultyTextRects(for: .dokushin).description.maxY
        let safeLastBottom = min(0.94, (canvasSize.height - safeBottom - backOrigin) / canvasSize.height)
        let lastBottom = max(lastBoard.maxY, max(lastTextBottom, safeLastBottom))

        switch difficulty {
        case .новичок:
            let left = max(0.18, backRect.maxX / canvasSize.width + 0.012)
            return CanvasRect(x: left, y: noviceTextTop, width: 0.98 - left, height: noviceStudentMidpoint - noviceTextTop)
        case .ученик:
            return CanvasRect(x: 0.02, y: noviceStudentMidpoint, width: 0.96, height: studentMasterMidpoint - noviceStudentMidpoint)
        case .мастер:
            return CanvasRect(x: 0.02, y: studentMasterMidpoint, width: 0.96, height: masterSenseiMidpoint - studentMasterMidpoint)
        case .сенсей:
            return CanvasRect(x: 0.02, y: masterSenseiMidpoint, width: 0.96, height: senseiDokushinMidpoint - masterSenseiMidpoint)
        case .dokushin:
            return CanvasRect(x: 0.02, y: senseiDokushinMidpoint, width: 0.96, height: lastBottom - senseiDokushinMidpoint)
        }
    }
}

private struct CanvasRect {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    var maxY: CGFloat { y + height }
    var midY: CGFloat { y + height / 2 }

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
