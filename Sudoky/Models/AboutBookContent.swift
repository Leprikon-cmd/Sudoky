import Foundation

enum AboutBookChapter: String {
    case manifesto
    case rules
    case sudokuHistory = "sudoku-history"
    case garden
    case bonsaiArt = "bonsai-art"
    case acknowledgements

    var bookletID: BookletChapterID { BookletChapterID(rawValue: rawValue) }
}

enum AboutBookContent {
    static let nikoliHistoryURL = "https://www.nikoli.co.jp/en/puzzles/sudoku/"
    static let bonsaiHistoryURL = "https://www.nationalarboretum.act.gov.au/living-collections/national-bonsai-and-penjing-collection-of-australia"
    static let projectWebsiteURL = "https://leprikon-cmd.github.io/Sudoky/"
    static let communityURL = "https://vk.ru/sudoku.sage"

    static func document() -> BookletDocument {
        BookletDocument(
            id: "about-book",
            titleKey: "about.book.chapter.manifesto",
            chapters: [
                BookletChapter(
                    id: AboutBookChapter.manifesto.bookletID,
                    titleKey: "about.book.chapter.manifesto",
                    titleKind: .aboutTitle,
                    bodyKind: .aboutIntro,
                    titleSpacingAfter: 18,
                    items: [
                    .text("about.book.manifesto.body"),
                    .iconLink("about.book.support.website", projectWebsiteURL, .globe),
                    .iconLink("about.book.support.community", communityURL, .vk)
                    ]
                ),
                BookletChapter(id: AboutBookChapter.rules.bookletID, titleKey: "about.book.chapter.rules", items: [
                    .subheading("about.book.rules.basics"),
                    .text("about.book.rules.basicsBody"),
                    .subheading("about.book.rules.mastery"),
                    .text("about.book.rules.difficulties"),
                    .subheading("about.book.rules.additional"),
                    .text("about.book.rules.additionalBody")
                ]),
                BookletChapter(id: AboutBookChapter.sudokuHistory.bookletID, titleKey: "about.book.chapter.sudokuHistory", items: [
                    .text("about.book.history.body"),
                    .subheading("about.book.history.dokushinTitle"),
                    .text("about.book.history.dokushinBody"),
                    .sourceLink("about.book.history.source", nikoliHistoryURL)
                ]),
                BookletChapter(id: AboutBookChapter.garden.bookletID, titleKey: "about.book.chapter.garden", items: [
                    .text("about.book.garden.body"),
                    .button("about.book.garden.button", .openGardenHelp)
                ]),
                BookletChapter(id: AboutBookChapter.bonsaiArt.bookletID, titleKey: "about.book.chapter.bonsaiArt", items: [
                    .text("about.book.bonsai.body"),
                    .sourceLink("about.book.bonsai.source", bonsaiHistoryURL)
                ]),
                BookletChapter(id: AboutBookChapter.acknowledgements.bookletID, titleKey: "about.book.chapter.acknowledgements", bodyKey: "about.book.acknowledgements.body")
            ],
            hasContents: false,
            showsPageControls: false,
            startsEachChapterOnNewPage: true,
            showsDocumentTitle: false,
            usesCompactSpacing: true,
            firstPageFooterMinimumGap: 16
        )
    }
}
