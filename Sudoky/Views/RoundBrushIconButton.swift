import SwiftUI

struct RoundBrushIconButton: View {
    let assetName: String
    let accessibilityLabelKey: String
    var visibleDiameter: CGFloat = 40
    let action: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager

    private var imageSide: CGFloat {
        visibleDiameter * 1254 / 1100
    }

    var body: some View {
        let _ = languageManager.language

        Button(action: action) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSide, height: imageSide)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(loc(accessibilityLabelKey)))
    }
}

struct RoundBrushIconToolbarItem: ToolbarContent {
    let assetName: String
    let accessibilityLabelKey: String
    let placement: ToolbarItemPlacement
    var visibleDiameter: CGFloat = 40
    let action: () -> Void

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: placement) {
                brushButton
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: placement) {
                brushButton
            }
        }
    }

    private var brushButton: some View {
        RoundBrushIconButton(
            assetName: assetName,
            accessibilityLabelKey: accessibilityLabelKey,
            visibleDiameter: visibleDiameter,
            action: action
        )
    }
}
