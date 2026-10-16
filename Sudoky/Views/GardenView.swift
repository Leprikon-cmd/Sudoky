import SwiftUI

struct GardenView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var gardenManager: GardenManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var fontManager: FontManager

    @State private var showingGardenHelp = false
    @ScaledMetric(relativeTo: .title2) private var titleFontSize: CGFloat = 30
    @ScaledMetric(relativeTo: .body) private var subtitleFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .body) private var actionFontSize: CGFloat = 14
    @ScaledMetric(relativeTo: .headline) private var navigationTitleFontSize: CGFloat = 18

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let compact = geometry.size.height < 650
            let viewedSpecies = gardenManager.lastViewedSpecies
            let tree = gardenManager.state?.trees.first(where: { $0.species == viewedSpecies })
            let treeImageSide = min(
                min(340, max(0, geometry.size.width - 48)),
                geometry.size.height * (compact ? 0.42 : 0.50)
            )
            let treeImageOffsetY = tree.map {
                BonsaiPotMetrics.gardenOffsetY(for: $0, frameSide: treeImageSide)
            } ?? 0
            let canGrowViewedTree = gardenManager.state?.selectedSpecies == viewedSpecies
                && gardenManager.canGrowSelectedTree

            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: compact ? 6 : 10) {
                    Spacer(minLength: 0)

                    Group {
                        if let assetName = tree?.imageAssetName {
                            Image(assetName)
                                .resizable()
                                .scaledToFit()
                                .id(assetName)
                                .transition(.opacity)
                        } else {
                            Image("garden_icon_sprout_v2")
                                .resizable()
                                .scaledToFit()
                                .padding(56)
                                .id("garden-empty")
                                .transition(.opacity)
                        }
                    }
                    .frame(
                        maxWidth: min(340, geometry.size.width - 48),
                        maxHeight: geometry.size.height * (compact ? 0.42 : 0.50)
                    )
                    .offset(y: treeImageOffsetY)
                    .overlay {
                        if gardenManager.canPlant(viewedSpecies) || canGrowViewedTree {
                            GardenAvailabilityGlow()
                                .padding(30)
                                .allowsHitTesting(false)
                        }
                    }
                    .accessibilityLabel(Text(loc(speciesNameKey(viewedSpecies))))
                    .animation(.easeInOut(duration: 0.25), value: tree?.imageAssetName)
                    .gesture(
                        DragGesture(minimumDistance: 24)
                            .onEnded { value in selectAdjacentSlot(for: value.translation) }
                    )

                    Text(loc(speciesNameKey(viewedSpecies)))
                        .textStyle(size: titleFontSize)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(loc(gardenManager.issue != nil
                             ? "garden.storage.error"
                             : tree.map { speciesSubtitleKey($0.species) }
                                ?? emptySlotSubtitleKey(for: viewedSpecies)))
                        .textStyle(size: subtitleFontSize)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 4) {
                        ForEach(GardenSpecies.orderedGardenSpecies, id: \.self) { species in
                            speciesSlotButton(species)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.22), value: gardenManager.lastViewedSpecies)

                    if gardenManager.hasAvailableDevelopment {
                        GardenStatusLabel(key: "garden.availability", symbol: "sparkle")
                    }

                    if tree?.stage == 10 {
                        GardenStatusLabel(key: "garden.fullyGrown", symbol: "leaf.fill")
                    }

                    Spacer(minLength: 0)

                    HStack(spacing: 8) {
                        GardenActionButton(
                            title: loc("garden.action.plant"),
                            iconName: "garden_icon_sprout_v2",
                            visibleBounds: CGRect(x: 129, y: 151, width: 998, height: 984),
                            fontSize: actionFontSize,
                            enabled: gardenManager.canPlant(viewedSpecies)
                        ) {
                            gardenManager.plant(viewedSpecies)
                        }

                        GardenActionButton(
                            title: loc("garden.action.grow"),
                            iconName: "garden_icon_branch_v1",
                            visibleBounds: CGRect(x: 126, y: 151, width: 1002, height: 975),
                            fontSize: actionFontSize,
                            enabled: gardenManager.issue == nil && canGrowViewedTree
                        ) {
                            gardenManager.growSelectedTree()
                        }

                    }
                    .padding(.bottom, 12)

                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 560, maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            AppBackToolbarItem {
                path.removeLast()
            }
#if DEBUG
            if settingsManager.testModeEnabled {
                GardenDebugToolbarItem {
                    guard settingsManager.testModeEnabled else { return }
                    _ = gardenManager.resetDebugTestGarden(testModeEnabled: settingsManager.testModeEnabled)
                }
            }
#endif
            ToolbarItem(placement: .principal) {
                Text(loc("garden.title"))
                    .textStyle(size: navigationTitleFontSize)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .accessibilityAddTraits(.isHeader)
            }
            RoundBrushIconToolbarItem(
                assetName: "nav_help_brush_v2",
                accessibilityLabelKey: GardenHelpContent.accessibilityLabelKey,
                placement: .navigationBarTrailing
            ) {
                showingGardenHelp = true
            }
        }
        .sheet(isPresented: $showingGardenHelp) {
            GardenHelpSheet()
                .environmentObject(languageManager)
                .environmentObject(fontManager)
                .environmentObject(settingsManager)
        }
    }

    private func speciesSlotButton(_ species: GardenSpecies) -> some View {
        let tree = gardenManager.state?.trees.first(where: { $0.species == species })
        let thumbnail = tree?.imageAssetName ?? GardenTree(species: species, stage: 1).imageAssetName ?? "garden_icon_sprout_v2"
        let isSelected = gardenManager.lastViewedSpecies == species
        let isPlanted = tree != nil
        let canPlant = gardenManager.canPlant(species)
        let statusKey = speciesStatusKey(species)
        let statusSymbol = gardenManager.issue != nil
            ? "exclamationmark.circle.fill"
            : (isPlanted ? "checkmark.circle.fill" : (canPlant ? "leaf.fill" : "lock.fill"))

        return Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                _ = gardenManager.selectSlot(species)
            }
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 34)

                    Image(systemName: statusSymbol)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color("ButtonPrimary"))
                        .background(Circle().fill(Color.white.opacity(0.88)).frame(width: 13, height: 13))
                        .offset(x: 3, y: -2)
                        .accessibilityHidden(true)
                }
                Text(loc(shortSpeciesNameKey(species)))
                    .textStyle(size: 11)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
            .background {
                RoundedRectangle(cornerRadius: 11)
                    .fill(Color("ButtonPrimary").opacity(isSelected ? 0.15 : 0.035))
                    .overlay {
                        RoundedRectangle(cornerRadius: 11)
                            .stroke(Color("Line").opacity(isSelected ? 1 : 0.55), lineWidth: 1)
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("\(loc(speciesNameKey(species))) — \(loc(statusKey))"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func speciesNameKey(_ species: GardenSpecies) -> String {
        species == .oak ? "garden.oak.name" : "garden.species.\(species.rawValue)"
    }

    private func shortSpeciesNameKey(_ species: GardenSpecies) -> String {
        "garden.species.short.\(species.rawValue)"
    }

    private func speciesStatusKey(_ species: GardenSpecies) -> String {
        if gardenManager.issue != nil { return "garden.storage.error" }
        if gardenManager.state?.trees.contains(where: { $0.species == species }) == true {
            return "garden.species.planted"
        }
        if gardenManager.canPlant(species) {
            return gardenManager.state?.hasUsedFirstFreePlanting == true
                ? "garden.costsAction"
                : "garden.readyToPlant"
        }
        return "garden.needsAction"
    }

    private func emptySlotSubtitleKey(for species: GardenSpecies) -> String {
        guard gardenManager.canPlant(species) else { return "garden.needsAction" }
        return gardenManager.state?.hasUsedFirstFreePlanting == true
            ? "garden.costsAction"
            : "garden.readyToPlant"
    }

    private func selectAdjacentSlot(for translation: CGSize) {
        guard abs(translation.width) >= 36,
              abs(translation.width) > abs(translation.height) * 1.15,
              let state = gardenManager.state,
              let next = state.adjacentGardenSlot(
                from: gardenManager.lastViewedSpecies,
                direction: translation.width < 0 ? 1 : -1
              ) else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            _ = gardenManager.selectSlot(next)
        }
    }

    private func speciesSubtitleKey(_ species: GardenSpecies) -> String {
        switch species {
        case .oak: return "garden.oak.subtitle"
        case .beech: return "garden.beech.subtitle"
        case .maple, .juniper, .apple: return "garden.species.subtitle.\(species.rawValue)"
        case .fir: return "garden.species.unavailable"
        }
    }
}

private struct GardenStatusLabel: View {
    let key: String
    let symbol: String

    @ScaledMetric(relativeTo: .caption) private var fontSize: CGFloat = 13

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .medium))
                .accessibilityHidden(true)
            Text(loc(key))
                .textStyle(size: fontSize)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(Color("ButtonPrimary"))
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

private struct GardenActionButton: View {
    let title: String
    let iconName: String
    let visibleBounds: CGRect?
    let fontSize: CGFloat
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                GardenCircleIcon(
                    assetName: iconName,
                    visibleBounds: visibleBounds,
                    visibleDiameter: 52,
                    containerSide: 60
                )

                Text(title)
                    .textStyle(size: fontSize)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, minHeight: 82)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("ButtonPrimary").opacity(0.045))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("Line").opacity(0.85), lineWidth: 1)
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.55)
        .accessibilityElement(children: .combine)
    }
}

struct GardenAvailabilityGlow: View {
    var body: some View {
        Circle()
            .fill(Color(red: 0.78, green: 0.68, blue: 0.30).opacity(0.24))
            .blur(radius: 24)
            .blendMode(.screen)
    }
}

#if DEBUG
private struct GardenDebugToolbarItem: ToolbarContent {
    let action: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        let _ = languageManager.language

        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .navigationBarLeading) {
                debugButton
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .navigationBarLeading) {
                debugButton
            }
        }
    }

    private var debugButton: some View {
        Button(action: action) {
            Image(systemName: "ladybug")
                .font(.system(size: 17))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.leading, 10)
        .accessibilityLabel(Text(loc("garden.testMode.reset")))
    }
}
#endif
