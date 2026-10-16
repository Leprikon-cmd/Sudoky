import SwiftUI

struct BookletSheet: View {
    let document: BookletDocument
    let closeAccessibilityLabelKey: String
    var initialChapter: BookletChapterID? = nil
    var onAction: (BookletAction) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        let _ = languageManager.language

        NavigationStack {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                BookletPagerView(document: document, initialChapter: initialChapter, onAction: onAction)
            }
            .toolbar {
                RoundBrushIconToolbarItem(
                    assetName: "nav_close_brush_v2",
                    accessibilityLabelKey: closeAccessibilityLabelKey,
                    placement: .navigationBarTrailing
                ) {
                    dismiss()
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

struct GardenHelpSheet: View {
    var body: some View {
        BookletSheet(document: GardenHelpContent.document, closeAccessibilityLabelKey: GardenHelpContent.closeKey)
    }
}
