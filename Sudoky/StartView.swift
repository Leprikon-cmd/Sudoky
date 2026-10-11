import SwiftUI
import UIKit

struct StartView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @AppStorage("playerMotto") private var playerMotto: String = ""
    @AppStorage("playerName") private var playerName: String = ""
    @State private var hasSave: Bool = false
    @State private var showAboutSheet = false
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject private var gardenManager: GardenManager
    @ScaledMetric(relativeTo: .body) private var actionFontSize: CGFloat = 20

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            let viewportSize = CGSize(
                width: geometry.size.width + safeArea.leading + safeArea.trailing,
                height: geometry.size.height + safeArea.top + safeArea.bottom
            )
            let actionBlockBottom = viewportSize.height - safeArea.bottom - 10
            let treeContactY = viewportSize.height * 0.59
            let actionRoomBelowTree = max(
                0,
                actionBlockBottom - treeContactY - 6
            )
            let actionButtonHeight = min(
                56,
                max(44, (actionRoomBelowTree - 3 * 7) / 4)
            )
            let actionButtonSpacing = min(
                7,
                max(0, (actionRoomBelowTree - actionButtonHeight * 4) / 3)
            )
            let actionBlockTop = actionBlockBottom
                - actionButtonHeight * 4
                - actionButtonSpacing * 3
            ZStack(alignment: .topLeading) {
                Color(red: 0.92, green: 0.82, blue: 0.66)
                    .frame(width: viewportSize.width, height: viewportSize.height)

                Image("home_background_wood_terrace_v2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: viewportSize.height * 852 / 1847,
                        height: viewportSize.height
                    )
                    .position(x: viewportSize.width / 2, y: viewportSize.height / 2)
                    .accessibilityHidden(true)

                gardenButton(
                    viewportSize: viewportSize,
                    contactY: treeContactY,
                    actionBlockTop: actionBlockTop
                )

                topControls(
                    viewportWidth: viewportSize.width,
                    safeAreaTop: safeArea.top
                )

                homeActionSlots(
                    viewportSize: viewportSize,
                    safeAreaBottom: safeArea.bottom,
                    buttonHeight: actionButtonHeight,
                    buttonSpacing: actionButtonSpacing
                )
            }
            .frame(width: viewportSize.width, height: viewportSize.height)
            .clipped()
            .offset(x: -safeArea.leading, y: -safeArea.top)
        }
        .onAppear {
            if settings.soundEnabled {
                settings.soundEnabled = MusicManager.shared.playBackgroundMusic("Aurnis_Luthael")
            }

            hasSave = hasSavedGame()
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutProjectSheet()
        }
    }

    private func gardenButton(
        viewportSize: CGSize,
        contactY: CGFloat,
        actionBlockTop: CGFloat
    ) -> some View {
        let selectedTree = gardenManager.selectedTree
        let selectedTreeAsset = selectedTree?.imageAssetName
        let frameSide = min(viewportSize.height * 0.46, max(0, viewportSize.width - 16))
        let alphaBottomFraction: CGFloat
        switch selectedTree?.species {
        case .oak: alphaBottomFraction = 967.0 / 1024.0
        case .beech: alphaBottomFraction = 948.0 / 1024.0
        case nil: alphaBottomFraction = 1188.0 / 1254.0
        default: alphaBottomFraction = 967.0 / 1024.0
        }
        let centerY = contactY + (0.5 - alphaBottomFraction) * frameSide
        let potBounds = selectedTree.flatMap { BonsaiPotMetrics.lowerBounds(for: $0) }
        let potWidth = potBounds.map { ($0.maxX - $0.minX) / 1024 * frameSide } ?? 0
        let potCenterX = potBounds.map { ($0.minX + $0.maxX) / (2 * 1024) * frameSide } ?? frameSide / 2
        let shadowVisibleWidth = potWidth * 1.10
        let shadowFrameWidth = shadowVisibleWidth * 2172 / 1785
        let shadowFrameHeight = shadowFrameWidth * 724 / 2172
        let shadowImageCenterX = potCenterX + (0.5 - 1098.5 / 2172) * shadowFrameWidth
        let shadowImageCenterY = frameSide * alphaBottomFraction + 3
            + (0.5 - 460.5 / 724) * shadowFrameHeight
        let contactCoreWidth = potWidth * 0.90
        let treeFrameTop = centerY - frameSide / 2
        let swipeAreaHeight = min(frameSide, max(0, actionBlockTop - treeFrameTop))

        return Button {
            path.append(Route.garden)
        } label: {
            ZStack {
                if let selectedTreeAsset, selectedTree != nil {
                    Image("bonsai_contact_shadow_v2")
                        .resizable()
                        .frame(width: shadowFrameWidth, height: shadowFrameHeight)
                        .opacity(0.90)
                        .position(x: shadowImageCenterX, y: shadowImageCenterY)
                        .animation(.easeInOut(duration: 0.24), value: selectedTreeAsset)
                        .allowsHitTesting(false)

                    Ellipse()
                        .fill(Color(red: 0.24, green: 0.15, blue: 0.10).opacity(0.58))
                        .frame(width: contactCoreWidth, height: 3)
                        .blur(radius: 1.1)
                        .position(x: potCenterX, y: frameSide * alphaBottomFraction + 3)
                        .animation(.easeInOut(duration: 0.24), value: selectedTreeAsset)
                        .allowsHitTesting(false)
                }

                Group {
                    if let assetName = selectedTreeAsset {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .id(assetName)
                            .transition(.opacity)
                    } else {
                        Image("garden_icon_sprout_v2")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .overlay {
                    if gardenManager.hasAvailableDevelopment {
                        GardenAvailabilityGlow()
                            .padding(18)
                            .allowsHitTesting(false)
                    }
                }
                .animation(.easeInOut(duration: 0.24), value: selectedTreeAsset)
            }
            .frame(width: frameSide, height: frameSide)
            .contentShape(Rectangle())
            .overlay(alignment: .top) {
                if selectedTreeAsset != nil, swipeAreaHeight > 0 {
                    Color.clear
                        .frame(width: frameSide, height: swipeAreaHeight)
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 40)
                                .onEnded { value in
                                    let horizontal = value.translation.width
                                    let vertical = value.translation.height
                                    guard abs(horizontal) >= 40, abs(horizontal) > abs(vertical) else { return }
                                    selectAdjacentTree(direction: horizontal < 0 ? 1 : -1)
                                }
                        )
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(loc(selectedTree.map { treeNameKey($0.species) } ?? "garden.empty.title")))
        .accessibilityHint(Text(
            (gardenManager.state?.displayedTreeSpecies.count ?? 0) > 1
                ? loc("garden.tree.switch.accessibilityHint")
                : ""
        ))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selectAdjacentTree(direction: 1)
            case .decrement: selectAdjacentTree(direction: -1)
            @unknown default: break
            }
        }
        .position(x: viewportSize.width / 2, y: centerY)
    }

    private func selectAdjacentTree(direction: Int) {
        guard let currentSpecies = gardenManager.selectedTree?.species,
              let nextSpecies = gardenManager.state?.adjacentDisplayedTreeSpecies(
                from: currentSpecies,
                direction: direction
              ) else { return }
        withAnimation(.easeInOut(duration: 0.24)) {
            _ = gardenManager.selectTree(nextSpecies)
        }
    }

    private func treeNameKey(_ species: GardenSpecies) -> String {
        species == .oak ? "garden.oak.name" : "garden.species.\(species.rawValue)"
    }

    private func topControls(viewportWidth: CGFloat, safeAreaTop: CGFloat) -> some View {
        HStack {
            Button(action: toggleBackgroundSound) {
                topButtonIcon(
                    assetName: settings.soundEnabled ? "home_music_flute_on_v2" : "home_music_flute_off_v2",
                    visibleBounds: CGRect(x: 77, y: 96, width: 1090, height: 1066)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(loc("settings.sound")))
            .accessibilityValue(Text(loc(settings.soundEnabled ? "settings.sound.state.on" : "settings.sound.state.off")))

            Spacer()

            Button {
                path.append(Route.settings)
            } label: {
                topButtonIcon(
                    assetName: "home_settings_scroll_v2",
                    visibleBounds: CGRect(x: 81, y: 101, width: 1097, height: 1039)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(loc("settings.title"))
        }
        .padding(.horizontal, 16)
        .frame(width: viewportWidth, height: 58)
        .position(x: viewportWidth / 2, y: safeAreaTop + 8 + 29)
    }

    private func homeActionSlots(
        viewportSize: CGSize,
        safeAreaBottom: CGFloat,
        buttonHeight: CGFloat,
        buttonSpacing: CGFloat
    ) -> some View {
        let buttonWidth = min(viewportSize.width * 0.90, 460)
        let blockHeight = buttonHeight * 4 + buttonSpacing * 3
        let blockBottom = viewportSize.height - safeAreaBottom - 10
        let largestLeftCapRatio = [
            HomeActionArtwork.continueJourney,
            HomeActionArtwork.newGame,
            HomeActionArtwork.levels,
            HomeActionArtwork.about
        ]
        .map { $0.leftCapPixels / $0.visibleBounds.height }
        .max() ?? 0
        let commonTextLeadingInset = largestLeftCapRatio * buttonHeight + 10

        return VStack(spacing: buttonSpacing) {
            if hasSave {
                homeActionButton(titleKey: "start.resume", artwork: .continueJourney, buttonWidth: buttonWidth, buttonHeight: buttonHeight, textLeadingInset: commonTextLeadingInset) {
                    path.append(Route.resume)
                }
            } else {
                Color.clear
                    .frame(width: buttonWidth, height: buttonHeight)
                    .contentShape(Rectangle())
                    .allowsHitTesting(false)
            }

            homeActionButton(titleKey: "start.newGame", artwork: .newGame, buttonWidth: buttonWidth, buttonHeight: buttonHeight, textLeadingInset: commonTextLeadingInset) {
                path.append(Route.difficulty)
            }

            homeActionButton(titleKey: "start.stats", artwork: .levels, buttonWidth: buttonWidth, buttonHeight: buttonHeight, textLeadingInset: commonTextLeadingInset) {
                path.append(Route.stats)
            }

            homeActionButton(titleKey: "settings.about", artwork: .about, buttonWidth: buttonWidth, buttonHeight: buttonHeight, textLeadingInset: commonTextLeadingInset) {
                showAboutSheet = true
            }
        }
        .frame(width: buttonWidth, height: blockHeight)
        .position(x: viewportSize.width / 2, y: blockBottom - blockHeight / 2)
    }

    private func toggleBackgroundSound() {
        if settings.soundEnabled {
            settings.soundEnabled = false
            MusicManager.shared.stopMusic()
        } else {
            settings.soundEnabled = MusicManager.shared.playBackgroundMusic("Aurnis_Luthael")
        }
    }

    private func topButtonIcon(assetName: String, visibleBounds: CGRect) -> some View {
        let sourceSide: CGFloat = 1254
        let visibleDiameter: CGFloat = 52
        let scale = visibleDiameter / max(visibleBounds.width, visibleBounds.height)
        let imageSide = sourceSide * scale
        let imageOffsetX = (sourceSide / 2 - visibleBounds.midX) * scale
        let imageOffsetY = (sourceSide / 2 - visibleBounds.midY) * scale

        return Image(assetName)
            .resizable()
            .frame(width: imageSide, height: imageSide)
            .offset(x: imageOffsetX, y: imageOffsetY)
            .frame(width: visibleDiameter, height: visibleDiameter)
            .frame(width: 58, height: 58)
            .contentShape(Rectangle())
            .accessibilityHidden(true)
    }

    private func homeActionButton(
        titleKey: String,
        artwork: HomeActionArtwork,
        buttonWidth: CGFloat,
        buttonHeight: CGFloat,
        textLeadingInset: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        let scale = buttonHeight / artwork.visibleBounds.height
        let leftCapWidth = artwork.leftCapPixels * scale
        let rightCapWidth = artwork.rightCapPixels * scale
        let titleFontSize = min(22, max(18, actionFontSize * buttonHeight / 56))
        let slices = buttonArtworkSlices(artwork)

        return Button(action: action) {
            ZStack(alignment: .leading) {
                if let slices {
                    HStack(spacing: 0) {
                        Image(uiImage: slices.left)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: leftCapWidth, height: buttonHeight)

                        Image(uiImage: slices.center)
                            .resizable()
                            .frame(
                                width: max(0, buttonWidth - leftCapWidth - rightCapWidth),
                                height: buttonHeight
                            )

                        Image(uiImage: slices.right)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: rightCapWidth, height: buttonHeight)
                    }
                    .accessibilityHidden(true)
                }

                Text(loc(titleKey))
                    .textStyle(size: titleFontSize)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.leading, textLeadingInset)
                    .padding(.trailing, rightCapWidth + 10)
                    .frame(width: buttonWidth, height: buttonHeight, alignment: .leading)
            }
            .frame(width: buttonWidth, height: buttonHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(loc(titleKey))
    }

    private func buttonArtworkSlices(
        _ artwork: HomeActionArtwork
    ) -> (left: UIImage, center: UIImage, right: UIImage)? {
        guard let sourceImage = UIImage(named: artwork.assetName)?.cgImage,
              sourceImage.width == Int(artwork.pixelSize.width),
              sourceImage.height == Int(artwork.pixelSize.height),
              let visibleArtwork = sourceImage.cropping(to: artwork.visibleBounds) else {
            return nil
        }

        let leftWidth = artwork.leftCapPixels
        let rightWidth = artwork.rightCapPixels
        let centerWidth = CGFloat(visibleArtwork.width) - leftWidth - rightWidth
        guard centerWidth > 0,
              let left = visibleArtwork.cropping(to: CGRect(x: 0, y: 0, width: leftWidth, height: artwork.visibleBounds.height)),
              let center = visibleArtwork.cropping(to: CGRect(x: leftWidth, y: 0, width: centerWidth, height: artwork.visibleBounds.height)),
              let right = visibleArtwork.cropping(to: CGRect(x: leftWidth + centerWidth, y: 0, width: rightWidth, height: artwork.visibleBounds.height)) else {
            return nil
        }

        return (
            UIImage(cgImage: left, scale: 1, orientation: .up),
            UIImage(cgImage: center, scale: 1, orientation: .up),
            UIImage(cgImage: right, scale: 1, orientation: .up)
        )
    }

    func hasSavedGame() -> Bool {
        GamePersistenceManager.shared.load() != nil
    }
}

private struct HomeActionArtwork {
    let assetName: String
    let pixelSize: CGSize
    let visibleBounds: CGRect
    let leftCapPixels: CGFloat
    let rightCapPixels: CGFloat

    static let continueJourney = HomeActionArtwork(
        assetName: "home_button_continue_wood_v2",
        pixelSize: CGSize(width: 2206, height: 713),
        visibleBounds: CGRect(x: 60, y: 148, width: 2087, height: 407),
        leftCapPixels: 450,
        rightCapPixels: 520
    )
    static let newGame = HomeActionArtwork(
        assetName: "home_button_new_game_wood_v2",
        pixelSize: CGSize(width: 2206, height: 713),
        visibleBounds: CGRect(x: 73, y: 165, width: 2063, height: 372),
        leftCapPixels: 450,
        rightCapPixels: 520
    )
    static let levels = HomeActionArtwork(
        assetName: "home_button_mastery_wood_v2",
        pixelSize: CGSize(width: 2206, height: 713),
        visibleBounds: CGRect(x: 84, y: 161, width: 2041, height: 391),
        leftCapPixels: 430,
        rightCapPixels: 520
    )
    static let about = HomeActionArtwork(
        assetName: "home_button_about_wood_v2",
        pixelSize: CGSize(width: 2172, height: 724),
        visibleBounds: CGRect(x: 38, y: 151, width: 2097, height: 422),
        leftCapPixels: 500,
        rightCapPixels: 520
    )
}

private struct BonsaiAlphaBounds {
    let minX: CGFloat
    let maxX: CGFloat
}

private enum BonsaiPotMetrics {
    private static let oak: [(CGFloat, CGFloat)] = [
        (271, 753), (237, 761), (255, 793), (267, 809), (252, 795),
        (214, 756), (235, 784), (249, 794), (244, 793), (243, 809)
    ]
    private static let beech: [(CGFloat, CGFloat)] = [
        (230, 794), (215, 785), (223, 819), (190, 848), (168, 846),
        (208, 841), (241, 812), (232, 812), (212, 811), (175, 824)
    ]

    static func lowerBounds(for tree: GardenTree) -> BonsaiAlphaBounds? {
        guard (1...10).contains(tree.stage) else { return nil }
        let bounds: [(CGFloat, CGFloat)]
        switch tree.species {
        case .oak: bounds = oak
        case .beech: bounds = beech
        case .juniper, .fir, .maple: return nil
        }
        let pair = bounds[tree.stage - 1]
        return BonsaiAlphaBounds(minX: pair.0, maxX: pair.1)
    }
}

#Preview {
    StartView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
    .environmentObject(PlayerProgressManager.shared)
}
