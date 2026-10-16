import SwiftUI

struct AboutProjectSheet: View {
    var initialChapter: AboutBookChapter? = nil
    @State private var showsGardenHelp = false
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        let _ = languageManager.language

        BookletSheet(
            document: AboutBookContent.document(),
            closeAccessibilityLabelKey: "about.close",
            initialChapter: initialChapter?.bookletID
        ) { action in
            if action == .openGardenHelp {
                showsGardenHelp = true
            }
        }
        .sheet(isPresented: $showsGardenHelp) {
            GardenHelpSheet()
        }
    }
}
