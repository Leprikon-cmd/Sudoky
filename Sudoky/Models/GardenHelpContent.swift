import Foundation
import CoreGraphics

struct BookletChapterID: RawRepresentable, Hashable, Identifiable, ExpressibleByStringLiteral, CustomStringConvertible {
    let rawValue: String

    init(rawValue: String) { self.rawValue = rawValue }
    init(stringLiteral value: String) { rawValue = value }
    var id: String { rawValue }
    var description: String { rawValue }
}

struct BookletChapter: Identifiable, Equatable {
    let id: BookletChapterID
    let titleKey: String
    let contentsTitleKey: String?
    let items: [BookletItem]
    let titleKind: BookletTextKind
    let bodyKind: BookletTextKind
    let titleSpacingAfter: CGFloat?

    init(
        id: BookletChapterID,
        titleKey: String,
        contentsTitleKey: String? = nil,
        titleKind: BookletTextKind = .chapterTitle,
        bodyKind: BookletTextKind = .body,
        titleSpacingAfter: CGFloat? = nil,
        bodyKey: String
    ) {
        self.id = id
        self.titleKey = titleKey
        self.contentsTitleKey = contentsTitleKey
        self.titleKind = titleKind
        self.bodyKind = bodyKind
        self.titleSpacingAfter = titleSpacingAfter
        self.items = [.text(bodyKey)]
    }

    init(
        id: BookletChapterID,
        titleKey: String,
        contentsTitleKey: String? = nil,
        titleKind: BookletTextKind = .chapterTitle,
        bodyKind: BookletTextKind = .body,
        titleSpacingAfter: CGFloat? = nil,
        items: [BookletItem]
    ) {
        self.id = id
        self.titleKey = titleKey
        self.contentsTitleKey = contentsTitleKey
        self.titleKind = titleKind
        self.bodyKind = bodyKind
        self.titleSpacingAfter = titleSpacingAfter
        self.items = items
    }
}

enum BookletItem: Equatable {
    case text(String)
    case formatted(String, String)
    case subheading(String)
    case button(String, BookletAction)
    case sourceLink(String, String)
    case iconLink(String, String, BookletLinkIcon)
}

enum BookletLinkIcon: Equatable { case globe, vk }

enum BookletAction: Equatable {
    case navigateToChapter(BookletChapterID)
    case openGardenHelp
}

struct BookletDocument: Equatable {
    let id: String
    let titleKey: String
    let chapters: [BookletChapter]
    let hasContents: Bool
    let showsPageControls: Bool
    var startsEachChapterOnNewPage: Bool = false
    var showsDocumentTitle: Bool = true
    var usesCompactSpacing: Bool = false
    var firstPageFooterMinimumGap: CGFloat = 0
}

enum BookletTextKind: Equatable {
    case bookTitle
    case aboutTitle
    case chapterTitle
    case subheading
    case body
    case aboutIntro
    case contentsEntry
    case action
}

struct BookletTextBlock: Identifiable, Equatable {
    let id: String
    let chapterID: BookletChapterID?
    let kind: BookletTextKind
    let text: String
    let accessibilityLabel: String?
    let isContinuation: Bool
    let spacingAfter: CGFloat
    let action: BookletAction?
    let sourceURL: String?
    let linkIcon: BookletLinkIcon?
}

struct BookletPage: Identifiable, Equatable {
    let id: String
    let blocks: [BookletTextBlock]
    let hasPhysicalConstraint: Bool
}

struct BookletLayout: Equatable {
    let containerSize: CGSize
    let imageRect: CGRect
    let numberRect: CGRect
    let textRect: CGRect
    let pageControlsRect: CGRect?
}

enum GardenHelpContent {
    static let titleKey = "garden.help.title"
    static let accessibilityLabelKey = "garden.help.accessibilityLabel"
    static let closeKey = "garden.help.close"
    static let continuationKey = "garden.help.continuation"
    static let pageIndicatorKey = "garden.help.pageIndicator"
    static let swipeHintKey = "garden.help.swipeHint"
    static let previousPageKey = "booklet.previousPage"
    static let nextPageKey = "booklet.nextPage"

    static let sections = [
        BookletChapter(id: "planting", titleKey: "garden.help.planting.title", bodyKey: "garden.help.planting.body"),
        BookletChapter(id: "developmentSteps", titleKey: "garden.help.developmentSteps.title", bodyKey: "garden.help.developmentSteps.body"),
        BookletChapter(id: "savingSteps", titleKey: "garden.help.savingSteps.title", bodyKey: "garden.help.savingSteps.body"),
        BookletChapter(id: "growingByHand", titleKey: "garden.help.growingByHand.title", bodyKey: "garden.help.growingByHand.body"),
        BookletChapter(id: "switchingTrees", titleKey: "garden.help.switchingTrees.title", bodyKey: "garden.help.switchingTrees.body"),
        BookletChapter(id: "oneTreePerSpecies", titleKey: "garden.help.oneTreePerSpecies.title", bodyKey: "garden.help.oneTreePerSpecies.body")
    ]

    static let document = BookletDocument(
        id: "garden-help",
        titleKey: titleKey,
        chapters: sections,
        hasContents: false,
        showsPageControls: false
    )
}
