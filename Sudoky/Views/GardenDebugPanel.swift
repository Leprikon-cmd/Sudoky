#if DEBUG
import SwiftUI

struct GardenDebugPanel: View {
    var body: some View {
        NavigationStack {
            Group {
                if let manager = GardenManager.debugShared {
                    GardenDebugControls(manager: manager)
                } else {
                    Text(loc("garden.debug.unavailable"))
                        .textStyle(size: 17)
                        .padding()
                }
            }
            .navigationTitle(loc("garden.debug.title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct GardenDebugControls: View {
    @ObservedObject var manager: GardenManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section(loc("garden.debug.state")) {
                if let assetName = manager.selectedTree?.imageAssetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .id(assetName)
                        .frame(maxWidth: .infinity)
                } else {
                    Image("garden_icon_sprout_v2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .frame(maxWidth: .infinity)
                }
                LabeledContent(loc("garden.debug.actions"), value: "\(manager.state?.availableActions ?? 0)")
                LabeledContent(loc("garden.debug.stage"), value: "\(manager.selectedTree?.stage ?? 0)")
                if manager.issue != nil {
                    Text(loc("garden.storage.error"))
                        .foregroundStyle(.red)
                }
            }

            Section(loc("garden.debug.scenarios")) {
                Button(loc("garden.debug.newUser")) {
                    manager.debugReset(currentLevel: 1)
                }
                Button(loc("garden.debug.levelSix")) {
                    manager.debugReset(currentLevel: 6)
                }
                Button(loc("garden.debug.addAction")) {
                    manager.debugAddAction()
                }
                Button(loc("garden.debug.reload")) {
                    manager.debugReload()
                }
                Button(loc("garden.debug.damageArchive")) {
                    manager.debugDamageArchive()
                }
                Button(loc("garden.action.plant")) {
                    manager.plant(.oak)
                }
                .disabled(!manager.canPlant(.oak))
                Button(loc("garden.species.beech")) {
                    manager.plant(.beech)
                }
                .disabled(!manager.canPlant(.beech))
                if manager.state?.trees.contains(where: { $0.species == .oak }) == true,
                   manager.state?.trees.contains(where: { $0.species == .beech }) == true {
                    Button(loc("garden.oak.name")) {
                        manager.selectTree(.oak)
                    }
                    Button(loc("garden.species.beech")) {
                        manager.selectTree(.beech)
                    }
                }
                Button(loc("garden.action.grow")) {
                    manager.growSelectedTree()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(loc("common.close")) { dismiss() }
            }
        }
    }
}
#endif
