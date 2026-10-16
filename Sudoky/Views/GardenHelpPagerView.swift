import SwiftUI
import UIKit

struct BookletPagerView: View {
    let document: BookletDocument
    let initialChapter: BookletChapterID?
    let onAction: (BookletAction) -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var fontManager: FontManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentPageIndex = 0

    @ScaledMetric(relativeTo: .title2) private var bookTitleFontSize: CGFloat = 22
    @ScaledMetric(relativeTo: .title2) private var aboutBookCompactTitleFontSize: CGFloat = 28
    @ScaledMetric(relativeTo: .title2) private var aboutBookWideTitleFontSize: CGFloat = 30
    @ScaledMetric(relativeTo: .title3) private var chapterTitleFontSize: CGFloat = 20
    @ScaledMetric(relativeTo: .headline) private var subheadingFontSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var bodyFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .body) private var aboutBookCompactIntroFontSize: CGFloat = 19
    @ScaledMetric(relativeTo: .body) private var aboutBookWideIntroFontSize: CGFloat = 20
    @ScaledMetric(relativeTo: .caption) private var pageNumberFontSize: CGFloat = 13
    @ScaledMetric(relativeTo: .body) private var headingLineSpacing: CGFloat = 2
    @ScaledMetric(relativeTo: .body) private var bodyLineSpacing: CGFloat = 5

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let layout = bookLayout(in: geometry.size, showsPageControls: document.showsPageControls)
            let compactAboutTitle = layout.textRect.width < 270
            let aboutTitleFontSize = compactAboutTitle ? aboutBookCompactTitleFontSize : aboutBookWideTitleFontSize
            let aboutIntroFontSize = compactAboutTitle ? aboutBookCompactIntroFontSize : aboutBookWideIntroFontSize
            let pages = makePages(
                layout: layout,
                aboutTitleFontSize: aboutTitleFontSize,
                aboutIntroFontSize: aboutIntroFontSize
            )
            let chapterStartPages = startPages(for: pages)

            Group {
                if !pages.isEmpty {
                    BookletPageCurlView(
                        pages: pages,
                        layout: layout,
                        currentPageIndex: $currentPageIndex,
                        reduceMotion: reduceMotion
                    ) { index in
                        AnyView(
                            BookletPageContentView(
                                page: pages[index],
                                pageNumber: index + 1,
                                pageCount: pages.count,
                                pageAccessibilityValue: String(
                                    format: loc(GardenHelpContent.pageIndicatorKey),
                                    index + 1,
                                    pages.count
                                ),
                                pageTitleKey: document.titleKey,
                                layout: layout,
                                bookTitleFontSize: bookTitleFontSize,
                                aboutBookTitleFontSize: aboutTitleFontSize,
                                chapterTitleFontSize: chapterTitleFontSize,
                                subheadingFontSize: subheadingFontSize,
                                bodyFontSize: bodyFontSize,
                                aboutBookIntroFontSize: aboutIntroFontSize,
                                pageNumberFontSize: pageNumberFontSize,
                                headingLineSpacing: document.usesCompactSpacing ? 0 : headingLineSpacing,
                                bodyLineSpacing: document.usesCompactSpacing ? 0 : bodyLineSpacing,
                                firstPageFooterMinimumGap: document.firstPageFooterMinimumGap,
                                pinsFirstPageFooter: document.id == "about-book" && index == 0,
                                onNavigateToChapter: { chapterID in
                                    if let target = chapterStartPages[chapterID] {
                                        currentPageIndex = target
                                    }
                                },
                                onAction: onAction
                            ) { direction in
                                movePage(direction, pageCount: pages.count)
                            }
                            .environmentObject(languageManager)
                            .environmentObject(fontManager)
                            .environmentObject(settingsManager)
                            .environment(\.dynamicTypeSize, dynamicTypeSize)
                        )
                    }
                    .id(reduceMotion)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear { currentPageIndex = initialPageIndex(in: chapterStartPages) }
            .onChange(of: languageManager.language) { currentPageIndex = initialPageIndex(in: chapterStartPages) }
            .onChange(of: dynamicTypeSize) { currentPageIndex = initialPageIndex(in: chapterStartPages) }
            .onChange(of: geometry.size) { currentPageIndex = initialPageIndex(in: chapterStartPages) }
            .onChange(of: pages.count) {
                currentPageIndex = initialPageIndex(in: chapterStartPages)
            }
        }
    }

    private func bookLayout(in size: CGSize, showsPageControls: Bool) -> BookletLayout {
        // GeometryReader is already below the navigation bar; don't subtract safe areas twice.
        let maximumWidth = min(600, max(0, size.width - 16))
        let maximumHeight = max(0, size.height - 16)
        let scale = min(maximumWidth / 987, maximumHeight / 1593)
        let imageSize = CGSize(width: 987 * scale, height: 1593 * scale)
        let imageRect = CGRect(
            x: (size.width - imageSize.width) / 2,
            y: 8,
            width: imageSize.width,
            height: imageSize.height
        )

        let inkSafety: CGFloat = 3
        let safeLeft = imageRect.minX + imageRect.width * 0.16 + 2
        let safeRight = imageRect.minX + imageRect.width * 0.90 - 2
        let safeTop = imageRect.minY + imageRect.height * 0.075 + inkSafety
        let safeBottom = imageRect.minY + imageRect.height * 0.92 - inkSafety
        let safeWidth = max(0, safeRight - safeLeft)
        let numberHeight = safeWidth > 0
            ? measuredHeight(
                "888",
                width: safeWidth,
                font: fontManager.bookMeasurementFont(size: pageNumberFontSize),
                lineSpacing: 0
            )
            : 0
        let numberRect = CGRect(x: safeLeft, y: safeTop, width: safeWidth, height: numberHeight)
        let textTop = safeTop + numberHeight + 7
        let controlsHeight: CGFloat = showsPageControls ? 44 : 0
        let controlsGap: CGFloat = showsPageControls ? 8 : 0
        let textBottom = safeBottom - controlsHeight - controlsGap
        let textRect = CGRect(x: safeLeft, y: textTop, width: safeWidth, height: max(0, textBottom - textTop))
        let pageControlsRect = showsPageControls
            ? CGRect(x: safeLeft, y: safeBottom - controlsHeight, width: safeWidth, height: controlsHeight)
            : nil
        return BookletLayout(
            containerSize: size,
            imageRect: imageRect,
            numberRect: numberRect,
            textRect: textRect,
            pageControlsRect: pageControlsRect
        )
    }

    private func makePages(
        layout: BookletLayout,
        aboutTitleFontSize: CGFloat,
        aboutIntroFontSize: CGFloat
    ) -> [BookletPage] {
        BookletPaginator.makePages(
            document: document,
            localize: loc,
            contentHeight: layout.textRect.height,
            measure: { text, kind in
                let size: CGFloat
                let spacing: CGFloat
                var weight: UIFont.Weight = .regular
                switch kind {
                case .bookTitle:
                    size = bookTitleFontSize
                    spacing = headingLineSpacing
                case .aboutTitle:
                    size = aboutTitleFontSize
                    spacing = headingLineSpacing
                    weight = .semibold
                case .chapterTitle:
                    size = chapterTitleFontSize
                    spacing = headingLineSpacing
                case .subheading:
                    size = subheadingFontSize
                    spacing = headingLineSpacing
                case .body:
                    size = bodyFontSize
                    spacing = bodyLineSpacing
                case .aboutIntro:
                    size = aboutIntroFontSize
                    spacing = bodyLineSpacing
                case .contentsEntry, .action:
                    size = bodyFontSize
                    spacing = bodyLineSpacing
                }
                let effectiveSpacing = document.usesCompactSpacing ? 0 : spacing
                let font: UIFont
                font = fontManager.bookMeasurementFont(size: size, weight: weight)
                return measuredHeight(
                    text,
                    width: layout.textRect.width,
                    font: font,
                    lineSpacing: effectiveSpacing
                )
            }
        )
    }

    private func measuredHeight(_ text: String, width: CGFloat, font: UIFont, lineSpacing: CGFloat) -> CGFloat {
        guard !text.isEmpty else { return 0 }
        guard width > 0 else { return .greatestFiniteMagnitude }
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.lineSpacing = lineSpacing
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font, .paragraphStyle: paragraph],
            context: nil
        )
        return ceil(bounds.height + 1)
    }

    private func startPages(for pages: [BookletPage]) -> [BookletChapterID: Int] {
        var result: [BookletChapterID: Int] = [:]
        for (index, page) in pages.enumerated() {
            for block in page.blocks where block.kind == .chapterTitle {
                if let chapterID = block.chapterID, result[chapterID] == nil {
                    result[chapterID] = index
                }
            }
        }
        return result
    }

    private func initialPageIndex(in starts: [BookletChapterID: Int]) -> Int {
        guard let initialChapter else { return 0 }
        return starts[initialChapter] ?? 0
    }

    private func movePage(_ direction: AccessibilityAdjustmentDirection, pageCount: Int) {
        switch direction {
        case .increment:
            currentPageIndex = min(currentPageIndex + 1, max(0, pageCount - 1))
        case .decrement:
            currentPageIndex = max(currentPageIndex - 1, 0)
        @unknown default:
            break
        }
    }
}
