import SwiftUI

struct GardenCircleIcon: View {
    let assetName: String
    let visibleBounds: CGRect?
    let visibleDiameter: CGFloat
    let containerSide: CGFloat

    private let sourceSide: CGFloat = 1254

    var body: some View {
        Group {
            if let visibleBounds {
                let scale = visibleDiameter / max(visibleBounds.width, visibleBounds.height)

                Image(assetName)
                    .resizable()
                    .frame(width: sourceSide * scale, height: sourceSide * scale)
                    .offset(
                        x: (sourceSide / 2 - visibleBounds.midX) * scale,
                        y: (sourceSide / 2 - visibleBounds.midY) * scale
                    )
                    .frame(width: containerSide, height: containerSide)
            } else {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: visibleDiameter, height: visibleDiameter)
                    .frame(width: containerSide, height: containerSide)
            }
        }
        .accessibilityHidden(true)
    }
}
