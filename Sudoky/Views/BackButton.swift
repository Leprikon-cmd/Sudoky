import SwiftUI

struct AppBackButton: View {
    let action: () -> Void

    var body: some View {
        RoundBrushIconButton(
            assetName: "nav_back_brush_transparent_v3",
            accessibilityLabelKey: "common.back",
            action: action
        )
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
