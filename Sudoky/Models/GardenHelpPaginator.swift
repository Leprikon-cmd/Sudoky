import Foundation

enum BookletPaginator {
    private static let titleSpacing: CGFloat = 12
    private static let chapterSpacing: CGFloat = 8
    private static let paragraphSpacing: CGFloat = 14
    private static let contentsEntrySpacing: CGFloat = 3

    static func makePages(
        document: BookletDocument,
        localize: (String) -> String,
        contentHeight: CGFloat,
        measure: (String, BookletTextKind) -> CGFloat
    ) -> [BookletPage] {
        let pageHeight = max(0, contentHeight)
        let titleSpacing = document.usesCompactSpacing ? 0 : Self.titleSpacing
        let chapterSpacing = document.usesCompactSpacing ? 0 : Self.chapterSpacing
        let paragraphSpacing = document.usesCompactSpacing ? 0 : Self.paragraphSpacing
        let contentsEntrySpacing = document.usesCompactSpacing ? 0 : Self.contentsEntrySpacing
        let minimumBodyLineHeight = measure("Жg", .body)
        var pages: [BookletPage] = []
        var blocks: [BookletTextBlock] = []
        var usedHeight: CGFloat = 0
        var constrained = false
        var firstPageFooterGapReserved = false

        func finishPage() {
            guard !blocks.isEmpty else { return }
            pages.append(BookletPage(id: "\(document.id)-page-\(pages.count + 1)", blocks: blocks, hasPhysicalConstraint: constrained))
            blocks = []
            usedHeight = 0
            constrained = false
        }

        func append(
            id: String,
            chapterID: BookletChapterID?,
            kind: BookletTextKind,
            text: String,
            label: String?,
            continuation: Bool = false,
            spacing: CGFloat = 0,
            height: CGFloat,
            action: BookletAction? = nil,
            sourceURL: String? = nil,
            linkIcon: BookletLinkIcon? = nil,
            physicalConstraint: Bool = false
        ) {
            blocks.append(BookletTextBlock(
                id: id,
                chapterID: chapterID,
                kind: kind,
                text: text,
                accessibilityLabel: label,
                isContinuation: continuation,
                spacingAfter: spacing,
                action: action,
                sourceURL: sourceURL,
                linkIcon: linkIcon
            ))
            usedHeight += height + spacing
            constrained = constrained || physicalConstraint || usedHeight > pageHeight
        }

        func appendHeading(
            _ text: String,
            id: String,
            chapterID: BookletChapterID?,
            kind: BookletTextKind,
            spacing: CGFloat,
            minimumFollowingLineHeight: CGFloat? = nil
        ) {
            let fullHeight = measure(text, kind)
            let lineHeight = measure("Жg", kind)
            let followingLineHeight = minimumFollowingLineHeight ?? minimumBodyLineHeight
            if !blocks.isEmpty, pageHeight - usedHeight < fullHeight + spacing + followingLineHeight {
                finishPage()
            }

            let available = pageHeight - usedHeight
            if fullHeight + spacing <= available {
                append(
                    id: id, chapterID: chapterID, kind: kind, text: text, label: text,
                    spacing: spacing, height: fullHeight,
                    physicalConstraint: fullHeight + spacing + followingLineHeight > pageHeight
                )
                if fullHeight + spacing + followingLineHeight > pageHeight { finishPage() }
                return
            }

            if !blocks.isEmpty { finishPage() }
            let capacity = max(0, pageHeight - spacing)
            let pieces = BookletTextSplitter.split(text, availableHeight: capacity, minimumLineHeight: lineHeight) {
                measure($0, kind) <= capacity
            }
            for (index, piece) in pieces.enumerated() {
                let isLast = index == pieces.count - 1
                let height = measure(piece, kind)
                append(
                    id: "\(id)-part-\(index + 1)", chapterID: chapterID, kind: kind, text: piece,
                    label: text, continuation: index > 0, spacing: isLast ? spacing : 0,
                    height: height,
                    physicalConstraint: pieces.count > 1 || height + (isLast ? spacing + followingLineHeight : 0) > pageHeight
                )
                if !isLast || height + spacing + followingLineHeight > pageHeight { finishPage() }
            }
        }

        func appendBody(
            _ text: String,
            id: String,
            chapter: BookletChapter,
            kind: BookletTextKind,
            fragmentIndex: inout Int
        ) {
            let minimumLineHeight = measure("Жg", kind)
            var remaining = text
            while !remaining.isEmpty {
                let available = pageHeight - usedHeight
                if available < minimumLineHeight && !blocks.isEmpty {
                    finishPage()
                    continue
                }

                let wholeHeight = measure(remaining, kind)
                if wholeHeight <= available {
                    let spacing = available - wholeHeight >= paragraphSpacing ? paragraphSpacing : 0
                    fragmentIndex += 1
                    append(
                        id: "\(id)-\(fragmentIndex)", chapterID: chapter.id, kind: kind, text: remaining,
                        label: localize(chapter.titleKey), continuation: fragmentIndex > 1,
                        spacing: spacing, height: wholeHeight
                    )
                    remaining = ""
                    continue
                }

                let pieces = BookletTextSplitter.split(remaining, availableHeight: available, minimumLineHeight: minimumLineHeight) {
                    measure($0, kind) <= available
                }
                if pieces.count == 1 && pieces[0] == remaining && !blocks.isEmpty {
                    finishPage()
                    continue
                }

                let first = pieces[0]
                let firstHeight = measure(first, kind)
                fragmentIndex += 1
                append(
                    id: "\(id)-\(fragmentIndex)", chapterID: chapter.id, kind: kind, text: first,
                    label: localize(chapter.titleKey), continuation: fragmentIndex > 1,
                    height: firstHeight, physicalConstraint: firstHeight > available
                )
                if pieces.count == 1 {
                    remaining = ""
                } else {
                    remaining = pieces.dropFirst().joined()
                    finishPage()
                }
            }
        }

        func appendActionBlock(
            id: String,
            chapterID: BookletChapterID,
            kind: BookletTextKind,
            text: String,
            action: BookletAction?,
            sourceURL: String?,
            linkIcon: BookletLinkIcon? = nil
        ) {
            let height = max(44, measure(text, kind))
            if !blocks.isEmpty, height + paragraphSpacing > pageHeight - usedHeight {
                finishPage()
            }
            append(
                id: id, chapterID: chapterID, kind: kind, text: text, label: text,
                spacing: paragraphSpacing, height: height, action: action, sourceURL: sourceURL, linkIcon: linkIcon,
                physicalConstraint: height + paragraphSpacing > pageHeight
            )
        }

        if document.hasContents {
            let title = localize(document.titleKey)
            let fullEntryHeights = document.chapters.map { max(44, measure(localize($0.titleKey), .contentsEntry)) + contentsEntrySpacing }
            let compactEntryHeights = document.chapters.map {
                max(44, measure(localize($0.contentsTitleKey ?? $0.titleKey), .contentsEntry)) + contentsEntrySpacing
            }
            let titleHeight = measure(title, .bookTitle) + titleSpacing
            let fullContentsFit = titleHeight + fullEntryHeights.reduce(0, +) <= pageHeight
            let firstCompactEntryHeight = compactEntryHeights.first ?? 0
            let showBookTitle = fullContentsFit || titleHeight + firstCompactEntryHeight <= pageHeight
            if showBookTitle {
                append(
                    id: "\(document.id)-title", chapterID: nil, kind: .bookTitle,
                    text: title, label: title, spacing: titleSpacing, height: measure(title, .bookTitle),
                    physicalConstraint: titleHeight > pageHeight
                )
            }
            for chapter in document.chapters {
                let entry = localize(fullContentsFit ? chapter.titleKey : (chapter.contentsTitleKey ?? chapter.titleKey))
                let label = localize(chapter.titleKey)
                let height = max(44, measure(entry, .contentsEntry))
                if !blocks.isEmpty, height + contentsEntrySpacing > pageHeight - usedHeight {
                    finishPage()
                }
                append(
                    id: "contents-\(chapter.id)", chapterID: nil, kind: .contentsEntry, text: entry,
                    label: label, spacing: contentsEntrySpacing, height: height,
                    action: .navigateToChapter(chapter.id), physicalConstraint: height > pageHeight
                )
            }
            finishPage()
        } else if document.showsDocumentTitle {
            appendHeading(localize(document.titleKey), id: "\(document.id)-title", chapterID: nil, kind: .bookTitle, spacing: titleSpacing)
        }

        for chapter in document.chapters {
            if document.startsEachChapterOnNewPage,
               chapter.id != document.chapters.first?.id,
               !blocks.isEmpty {
                finishPage()
            }
            appendHeading(
                localize(chapter.titleKey),
                id: "\(chapter.id)-title",
                chapterID: chapter.id,
                kind: chapter.titleKind,
                spacing: chapter.titleSpacingAfter ?? chapterSpacing,
                minimumFollowingLineHeight: measure("Жg", chapter.bodyKind)
            )
            var bodyFragment = 0
            for (itemIndex, item) in chapter.items.enumerated() {
                switch item {
                case .text(let key):
                    appendBody(localize(key), id: "\(chapter.id)-body-\(itemIndex)", chapter: chapter, kind: chapter.bodyKind, fragmentIndex: &bodyFragment)
                case .formatted(let key, let value):
                    appendBody(String(format: localize(key), value), id: "\(chapter.id)-body-\(itemIndex)", chapter: chapter, kind: chapter.bodyKind, fragmentIndex: &bodyFragment)
                case .subheading(let key):
                    appendHeading(localize(key), id: "\(chapter.id)-subheading-\(itemIndex)", chapterID: chapter.id, kind: .subheading, spacing: chapterSpacing)
                case .button(let key, let action):
                    appendActionBlock(
                        id: "\(chapter.id)-action-\(itemIndex)", chapterID: chapter.id,
                        kind: .action, text: localize(key), action: action, sourceURL: nil
                    )
                case .sourceLink(let key, let url):
                    appendActionBlock(
                        id: "\(chapter.id)-source-\(itemIndex)", chapterID: chapter.id,
                        kind: .action, text: localize(key), action: nil, sourceURL: url
                    )
                case .iconLink(let key, let url, let icon):
                    if document.firstPageFooterMinimumGap > 0,
                       !firstPageFooterGapReserved,
                       pages.isEmpty {
                        let remainingFooterHeight = chapter.items[itemIndex...].reduce(CGFloat.zero) { total, footerItem in
                            guard case .iconLink(let footerKey, _, _) = footerItem else { return total }
                            return total + max(44, measure(localize(footerKey), .action)) + paragraphSpacing
                        }
                        let requiredHeight = document.firstPageFooterMinimumGap + remainingFooterHeight
                        if !blocks.isEmpty, requiredHeight > pageHeight - usedHeight {
                            finishPage()
                        }
                        if pages.isEmpty {
                            usedHeight += document.firstPageFooterMinimumGap
                            firstPageFooterGapReserved = true
                        }
                    }
                    appendActionBlock(
                        id: "\(chapter.id)-source-\(itemIndex)", chapterID: chapter.id,
                        kind: .action, text: localize(key), action: nil, sourceURL: url, linkIcon: icon
                    )
                }
            }
        }

        finishPage()
        for chapter in document.chapters {
            for (index, item) in chapter.items.enumerated() {
                let sourceText: String
                switch item {
                case .text(let key): sourceText = localize(key)
                case .formatted(let key, let value): sourceText = String(format: localize(key), value)
                default: continue
                }
                let rendered = pages.flatMap(\.blocks).filter { $0.id.hasPrefix("\(chapter.id)-body-\(index)-") }.map(\.text).joined()
                assert(rendered == sourceText, "Booklet pagination must preserve localized source text")
            }
        }
        assert(pages.allSatisfy { !$0.blocks.isEmpty }, "Booklet pagination must not create empty pages")
        return pages
    }
}
