import SwiftUI

struct AppBackButton: View {
    let action: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        let _ = languageManager.language

        Button(action: action) {
            Image("back_paper_brush")
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 41)
                .frame(width: 56, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(loc("common.back")))
    }
}

struct AppBackToolbarItem: ToolbarContent {
    let action: () -> Void

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .navigationBarLeading) {
                AppBackButton(action: action)
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .navigationBarLeading) {
                AppBackButton(action: action)
            }
        }
    }
}
