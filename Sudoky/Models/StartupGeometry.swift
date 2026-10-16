import Foundation

enum StartupGeometry {
    static func hasUsableSize(_ size: CGSize) -> Bool {
        size.width.isFinite && size.height.isFinite && size.width >= 1 && size.height >= 1
    }

    static func hasUsableHomeLayout(
        size: CGSize,
        top: CGFloat,
        leading: CGFloat,
        bottom: CGFloat,
        trailing: CGFloat
    ) -> Bool {
        guard hasUsableSize(size),
              [top, leading, bottom, trailing].allSatisfy({ $0.isFinite && $0 >= 0 }) else {
            return false
        }

        let viewportWidth = size.width + leading + trailing
        let viewportHeight = size.height + top + bottom
        guard viewportWidth.isFinite, viewportHeight.isFinite,
              viewportWidth >= 1, viewportHeight >= 1 else {
            return false
        }

        let actionBlockBottom = viewportHeight - bottom - 10
        let treeContactY = viewportHeight * 0.59
        let actionRoomBelowTree = max(0, actionBlockBottom - treeContactY - 6)
        let buttonHeight = min(56, max(44, (actionRoomBelowTree - 21) / 4))
        let buttonSpacing = min(7, max(0, (actionRoomBelowTree - buttonHeight * 4) / 3))
        let blockHeight = buttonHeight * 4 + buttonSpacing * 3
        let buttonWidth = min(viewportWidth * 0.90, 460)
        let treeFrameSide = min(viewportHeight * 0.46, max(0, viewportWidth - 16))
        let backgroundWidth = viewportHeight * 852 / 1847
        let topControlsY = top + 37
        let actionBlockY = actionBlockBottom - blockHeight / 2

        let frameDimensions = [
            viewportWidth,
            viewportHeight,
            backgroundWidth,
            buttonWidth,
            buttonHeight,
            buttonSpacing,
            blockHeight,
            treeFrameSide
        ]
        let positions = [topControlsY, actionBlockY, treeContactY]
        return frameDimensions.allSatisfy({ $0.isFinite && $0 >= 0 })
            && positions.allSatisfy(\.isFinite)
    }
}
