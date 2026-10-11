import SwiftUI

struct GardenView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var gardenManager: GardenManager
    @EnvironmentObject private var settingsManager: SettingsManager

    @State private var showingDebugPanel = false
    @State private var showingPlantingSheet = false
    @ScaledMetric(relativeTo: .title2) private var titleFontSize: CGFloat = 30
    @ScaledMetric(relativeTo: .body) private var subtitleFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .body) private var actionFontSize: CGFloat = 14

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let compact = geometry.size.height < 650
            let tree = gardenManager.selectedTree

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
                    .overlay {
                        if gardenManager.hasAvailableDevelopment {
                            GardenAvailabilityGlow()
                                .padding(30)
                                .allowsHitTesting(false)
                        }
                    }
                    .accessibilityLabel(Text(loc(tree.map { speciesNameKey($0.species) } ?? "garden.empty.title")))
                    .animation(.easeInOut(duration: 0.25), value: tree?.imageAssetName)

                    Text(loc(tree.map { speciesNameKey($0.species) } ?? "garden.empty.title"))
                        .textStyle(size: titleFontSize)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(loc(gardenManager.issue != nil
                             ? "garden.storage.error"
                             : tree.map { speciesSubtitleKey($0.species) } ?? "garden.empty.message"))
                        .textStyle(size: subtitleFontSize)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if hasBothPlantableSpecies {
                        HStack(spacing: 8) {
                            ForEach([GardenSpecies.oak, .beech], id: \.self) { species in
                                let selected = species == tree?.species
                                Button {
                                    gardenManager.selectTree(species)
                                } label: {
                                    Text(loc(speciesNameKey(species)))
                                        .textStyle(size: 14)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background {
                                            Capsule().fill(Color("ButtonPrimary").opacity(selected ? 0.16 : 0.05))
                                        }
                                        .overlay {
                                            Capsule().stroke(Color("Line").opacity(selected ? 1 : 0.6), lineWidth: 1)
                                        }
                                        .frame(minWidth: 44, minHeight: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(selected ? .isSelected : [])
                            }
                        }
                    }

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
                            enabled: gardenManager.canPlantAnyAvailableSpecies
                        ) {
                            showingPlantingSheet = true
                        }

                        GardenActionButton(
                            title: loc("garden.action.grow"),
                            iconName: "garden_icon_branch_v1",
                            visibleBounds: CGRect(x: 126, y: 151, width: 1002, height: 975),
                            fontSize: actionFontSize,
                            enabled: gardenManager.issue == nil && gardenManager.canGrowSelectedTree
                        ) {
                            gardenManager.growSelectedTree()
                        }

                        GardenActionButton(
                            title: loc("garden.action.stone"),
                            iconName: "garden_icon_stone_v1",
                            visibleBounds: CGRect(x: 110, y: 104, width: 1048, height: 1046),
                            fontSize: actionFontSize,
                            enabled: false,
                            action: {}
                        )
                    }
                    .padding(.bottom, 12)

#if DEBUG
                    if settingsManager.testModeEnabled {
                        Button {
                            gardenManager.debugGrowAllPlantedTreesToMaximum(using: settingsManager)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .accessibilityHidden(true)
                                Text(loc("garden.debug.growAllToMaximum"))
                                    .textStyle(size: 15)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal, 12)
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(!gardenManager.canDebugGrowAllPlantedTreesToMaximum)
                        .opacity(gardenManager.canDebugGrowAllPlantedTreesToMaximum ? 1 : 0.55)
                        .background {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color("ButtonPrimary").opacity(0.055))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color("Line").opacity(0.9), lineWidth: 1)
                                }
                                .shadow(color: Color("ButtonPrimary").opacity(0.08), radius: 3, y: 1)
                        }
                        .padding(.bottom, 8)
                    }
#endif
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 560, maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(loc("garden.title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            AppBackToolbarItem {
                path.removeLast()
            }
#if DEBUG
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingDebugPanel = true
                } label: {
                    Image(systemName: "ladybug")
                }
                .accessibilityLabel(loc("garden.debug.title"))
            }
#endif
        }
        .sheet(isPresented: $showingPlantingSheet) {
            GardenPlantingSheet(state: gardenManager.state) { species in
                gardenManager.plant(species)
            }
            .environmentObject(languageManager)
        }
#if DEBUG
        .sheet(isPresented: $showingDebugPanel) {
            GardenDebugPanel()
        }
#endif
    }

    private var hasBothPlantableSpecies: Bool {
        let species = Set(gardenManager.state?.trees.map(\.species) ?? [])
        return species.contains(.oak) && species.contains(.beech)
    }

    private func speciesNameKey(_ species: GardenSpecies) -> String {
        species == .oak ? "garden.oak.name" : "garden.species.\(species.rawValue)"
    }

    private func speciesSubtitleKey(_ species: GardenSpecies) -> String {
        species == .oak ? "garden.oak.subtitle" : "garden.beech.subtitle"
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

private struct GardenPlantingSheet: View {
    let state: GardenState?
    let onSelect: (GardenSpecies) -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let _ = languageManager.language

        NavigationStack {
            List {
                ForEach(GardenSpecies.allCases, id: \.self) { species in
                    let planted = state?.trees.contains(where: { $0.species == species }) == true
                    let available = state?.canPlant(species) == true
                    let subtitleKey: String = {
                        guard species.isCurrentlyPlantable else { return "garden.species.unavailable" }
                        if planted { return "garden.species.planted" }
                        if available {
                            return state?.hasUsedFirstFreePlanting == true
                                ? "garden.costsAction"
                                : "garden.freePlanting"
                        }
                        return "garden.needsAction"
                    }()
                    Button {
                        guard available else { return }
                        onSelect(species)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: available ? "leaf" : "lock")
                                .foregroundStyle(Color("ButtonPrimary"))
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(loc(species == .oak ? "garden.oak.name" : "garden.species.\(species.rawValue)"))
                                    .textStyle(size: 17)
                                Text(loc(subtitleKey))
                                    .textStyle(size: 13)
                                    .foregroundStyle(Color("TextColor").opacity(0.75))
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!available)
                }
            }
            .scrollContentBackground(.hidden)
            .background(BackgroundView())
            .navigationTitle(loc("garden.planting.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(loc("common.close")) { dismiss() }
                }
            }
        }
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
