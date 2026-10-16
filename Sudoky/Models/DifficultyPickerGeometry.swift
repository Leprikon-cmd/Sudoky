import Foundation

enum DifficultyPickerGeometry {
    static func hasUsableViewport(_ size: CGSize) -> Bool {
        size.width.isFinite && size.height.isFinite && size.width > 0 && size.height > 0
    }

    static func verticalInterval(top: CGFloat, bottom: CGFloat) -> (origin: CGFloat, length: CGFloat) {
        guard top.isFinite, bottom.isFinite else { return (0, 0) }
        let origin = min(1, max(0, top))
        let end = min(1, max(origin, bottom))
        return (origin, end - origin)
    }

    static func miniBoardCellSide(side: CGFloat, lineWidth: CGFloat) -> CGFloat {
        guard side.isFinite, lineWidth.isFinite else { return 0 }
        return max(0, (side - 4 * lineWidth) / 3)
    }
}
