import SwiftUI

struct BookletPageContentView: View {
    let page: BookletPage
    let pageNumber: Int
    let pageCount: Int
    let pageAccessibilityValue: String
    let pageTitleKey: String
    let layout: BookletLayout
    let bookTitleFontSize: CGFloat
    let aboutBookTitleFontSize: CGFloat
    let chapterTitleFontSize: CGFloat
    let subheadingFontSize: CGFloat
    let bodyFontSize: CGFloat
    let aboutBookIntroFontSize: CGFloat
    let pageNumberFontSize: CGFloat
    let headingLineSpacing: CGFloat
    let bodyLineSpacing: CGFloat
    let firstPageFooterMinimumGap: CGFloat
    let pinsFirstPageFooter: Bool
    let onNavigateToChapter: (BookletChapterID) -> Void
    let onAction: (BookletAction) -> Void
    let onAdjustPage: (AccessibilityAdjustmentDirection) -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var settingsManager: SettingsManager

    var body: some View {
        let _ = languageManager.language

        ZStack(alignment: .topLeading) {
            Image("garden_help_book_right_v1")
                .resizable()
                .scaledToFit()
                .frame(width: layout.imageRect.width, height: layout.imageRect.height)
                .offset(x: layout.imageRect.minX, y: layout.imageRect.minY)
                .accessibilityHidden(true)

            Text(verbatim: String(pageNumber))
                .bookTextStyle(size: pageNumberFontSize)
                .multilineTextAlignment(.trailing)
                .lineSpacing(0)
                .frame(width: layout.numberRect.width, height: layout.numberRect.height, alignment: .topTrailing)
                .fixedSize(horizontal: false, vertical: true)
                .offset(x: layout.numberRect.minX, y: layout.numberRect.minY)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(page.blocks) { block in
                    if block.id == firstPageFooterBlockID {
                        Spacer(minLength: firstPageFooterMinimumGap)
                    }
                    content(for: block)
                }
            }
            .frame(width: layout.textRect.width, height: layout.textRect.height, alignment: .topLeading)
            .offset(x: layout.textRect.minX, y: layout.textRect.minY)

            if let controlsRect = layout.pageControlsRect {
                HStack {
                    if pageNumber > 1 {
                        pageControl(symbol: "chevron.left", direction: .decrement, isPrevious: true)
                    }
                    Spacer(minLength: 0)
                    if pageNumber < pageCount {
                        pageControl(symbol: "chevron.right", direction: .increment, isPrevious: false)
                    }
                }
                .frame(width: controlsRect.width, height: controlsRect.height)
                .offset(x: controlsRect.minX, y: controlsRect.minY)
            }
        }
        .frame(width: layout.containerSize.width, height: layout.containerSize.height, alignment: .topLeading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(loc(pageTitleKey)))
        .accessibilityValue(Text(pageAccessibilityValue))
        .accessibilityHint(Text(loc(GardenHelpContent.swipeHintKey)))
        .accessibilityAction(named: Text(loc(GardenHelpContent.previousPageKey))) {
            onAdjustPage(.decrement)
        }
        .accessibilityAction(named: Text(loc(GardenHelpContent.nextPageKey))) {
            onAdjustPage(.increment)
        }
        .accessibilityAdjustableAction(onAdjustPage)
        // Pager dimensions already use the externally scaled values.
        .environment(\.dynamicTypeSize, .large)
    }

    @ViewBuilder
    private func content(for block: BookletTextBlock) -> some View {
        let label = accessibleText(for: block)
        switch block.kind {
        case .contentsEntry:
            Button {
                if case .navigateToChapter(let chapterID) = block.action {
                    onNavigateToChapter(chapterID)
                }
            } label: {
                Text(block.text)
                    .bookTextStyle(size: bodyFontSize)
                    .foregroundStyle(settingsManager.selectedTextColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(bodyLineSpacing)
                    .frame(width: layout.textRect.width, alignment: .leading)
                    .frame(minHeight: 44, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: label))
            .accessibilityHint(Text(loc("about.contents.openChapter")))
            .padding(.bottom, block.spacingAfter)
        case .action:
            if let sourceURL = block.sourceURL, let url = URL(string: sourceURL) {
                Link(destination: url) {
                    HStack(alignment: .center, spacing: 8) {
                        if let icon = block.linkIcon {
                            BookletLinkMark(icon: icon, color: settingsManager.selectedTextColor)
                                .frame(width: 24, height: 24)
                                .accessibilityHidden(true)
                        }
                        Text(block.text)
                            .bookTextStyle(size: bodyFontSize)
                            .lineSpacing(bodyLineSpacing)
                    }
                    .foregroundStyle(settingsManager.selectedTextColor)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .frame(width: layout.textRect.width, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel(Text(verbatim: label))
                .padding(.bottom, block.spacingAfter)
            } else {
                Button {
                    if let action = block.action { onAction(action) }
                } label: {
                    Text(block.text)
                    .bookTextStyle(size: bodyFontSize)
                        .foregroundStyle(settingsManager.selectedTextColor)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(bodyLineSpacing)
                        .frame(width: layout.textRect.width, alignment: .leading)
                        .frame(minHeight: 44, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(verbatim: label))
                .padding(.bottom, block.spacingAfter)
            }
        default:
            let isHeading = block.kind == .bookTitle || block.kind == .aboutTitle
                || block.kind == .chapterTitle || block.kind == .subheading
            let weight: Font.Weight = block.kind == .aboutTitle ? .semibold : .regular
            let text = Text(block.text)
            text
                .modifier(BookletTextStyle(
                    fontSize: fontSize(for: block.kind),
                    weight: weight,
                    settingsManager: settingsManager
                ))
                .multilineTextAlignment(isHeading ? .center : .leading)
                .lineSpacing(lineSpacing(for: block.kind))
                .frame(width: layout.textRect.width, alignment: isHeading ? .center : .leading)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(Text(verbatim: label))
                .accessibilityAddTraits(isHeading ? .isHeader : [])
                .padding(.bottom, block.spacingAfter)
        }
    }

    private func accessibleText(for block: BookletTextBlock) -> String {
        guard let heading = block.accessibilityLabel else { return block.text }
        if block.kind == .contentsEntry { return heading }
        if block.kind == .bookTitle || block.kind == .aboutTitle
            || block.kind == .chapterTitle || block.kind == .subheading {
            return block.isContinuation ? "\(heading). \(loc(GardenHelpContent.continuationKey))" : heading
        }
        let hasChapterTitle = page.blocks.contains { $0.kind == .chapterTitle && $0.chapterID == block.chapterID }
        if (block.kind == .body || block.kind == .aboutIntro) && (!hasChapterTitle || block.isContinuation) {
            let continuation = block.isContinuation ? " \(loc(GardenHelpContent.continuationKey))." : ""
            return "\(heading).\(continuation) \(block.text)"
        }
        return block.text
    }

    private func pageControl(
        symbol: String,
        direction: AccessibilityAdjustmentDirection,
        isPrevious: Bool
    ) -> some View {
        Button {
            onAdjustPage(direction)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .accessibilityHidden(true)
                .foregroundStyle(settingsManager.selectedTextColor)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.30), in: Capsule())
                .overlay(Capsule().stroke(settingsManager.selectedTextColor.opacity(0.25), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(loc(isPrevious ? GardenHelpContent.previousPageKey : GardenHelpContent.nextPageKey)))
    }

    private func fontSize(for kind: BookletTextKind) -> CGFloat {
        switch kind {
        case .bookTitle: return bookTitleFontSize
        case .aboutTitle: return aboutBookTitleFontSize
        case .chapterTitle: return chapterTitleFontSize
        case .subheading: return subheadingFontSize
        case .body, .contentsEntry, .action: return bodyFontSize
        case .aboutIntro: return aboutBookIntroFontSize
        }
    }

    private func lineSpacing(for kind: BookletTextKind) -> CGFloat {
        kind == .body || kind == .aboutIntro ? bodyLineSpacing : headingLineSpacing
    }

    private var firstPageFooterBlockID: String? {
        guard pinsFirstPageFooter else { return nil }
        return page.blocks.first(where: { $0.linkIcon != nil })?.id
    }
}

private struct BookletTextStyle: ViewModifier {
    let fontSize: CGFloat
    let weight: Font.Weight
    let settingsManager: SettingsManager

    func body(content: Content) -> some View {
        content.bookTextStyle(size: fontSize, weight: weight)
            .foregroundStyle(settingsManager.selectedTextColor)
    }
}

private struct BookletLinkMark: View {
    let icon: BookletLinkIcon
    let color: Color

    var body: some View {
        Group {
            switch icon {
            case .globe:
                ZStack {
                    ProjectBookPagesShape()
                        .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    ProjectRoadShape()
                        .stroke(color, style: StrokeStyle(lineWidth: 1.15, lineCap: .round, lineJoin: .round))
                }
            case .vk:
                VKMonogramShape()
                    .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
        .accessibilityHidden(true)
    }
}

private struct ProjectBookPagesShape: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        path.move(to: point(0.08, 0.19))
        path.addCurve(to: point(0.47, 0.29), control1: point(0.20, 0.14), control2: point(0.37, 0.18))
        path.addLine(to: point(0.47, 0.88))
        path.addCurve(to: point(0.08, 0.77), control1: point(0.34, 0.76), control2: point(0.18, 0.74))
        path.closeSubpath()

        path.move(to: point(0.53, 0.29))
        path.addCurve(to: point(0.92, 0.19), control1: point(0.63, 0.18), control2: point(0.80, 0.14))
        path.addLine(to: point(0.92, 0.77))
        path.addCurve(to: point(0.53, 0.88), control1: point(0.82, 0.74), control2: point(0.66, 0.76))
        path.closeSubpath()

        path.move(to: point(0.50, 0.28))
        path.addLine(to: point(0.50, 0.89))
        return path
    }
}

private struct ProjectRoadShape: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        path.move(to: point(0.43, 0.79))
        path.addCurve(to: point(0.49, 0.37), control1: point(0.39, 0.62), control2: point(0.50, 0.52))
        path.move(to: point(0.57, 0.79))
        path.addCurve(to: point(0.51, 0.37), control1: point(0.61, 0.62), control2: point(0.50, 0.52))
        path.move(to: point(0.50, 0.72))
        path.addLine(to: point(0.50, 0.64))
        path.move(to: point(0.50, 0.55))
        path.addLine(to: point(0.50, 0.49))
        return path
    }
}

private struct VKMonogramShape: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
        }

        var path = Path()
        path.move(to: point(0.10, 0.22))
        path.addLine(to: point(0.31, 0.78))
        path.addLine(to: point(0.51, 0.22))
        path.move(to: point(0.62, 0.20))
        path.addLine(to: point(0.62, 0.80))
        path.move(to: point(0.62, 0.51))
        path.addLine(to: point(0.91, 0.22))
        path.move(to: point(0.65, 0.49))
        path.addLine(to: point(0.92, 0.80))
        return path
    }
}
