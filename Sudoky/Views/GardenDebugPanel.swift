#if DEBUG
import SwiftUI

struct GardenDebugPanel: View {
    @EnvironmentObject private var gardenManager: GardenManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var playerProgressManager: PlayerProgressManager
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var fontManager: FontManager
    @Environment(\.dismiss) private var dismiss

    @State private var showingResetConfirmation = false

    var body: some View {
        let _ = languageManager.language

        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    paperButton("garden.testMode.reset", action: requestReset)
                    paperButton("garden.testMode.addStep", action: addOneStep)

                    if gardenManager.issue != nil {
                        Text(loc("garden.storage.error"))
                            .textStyle(size: 15)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .frame(maxWidth: 520, maxHeight: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(loc("garden.testMode.title"))
                        .textStyle(size: 18)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .accessibilityAddTraits(.isHeader)
                }
                RoundBrushIconToolbarItem(
                    assetName: "nav_close_brush_v2",
                    accessibilityLabelKey: "common.close",
                    placement: .navigationBarTrailing
                ) {
                    dismiss()
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .alert(loc("garden.testMode.resetConfirmation.title"), isPresented: $showingResetConfirmation) {
            Button(loc("common.yes"), role: .destructive, action: resetGarden)
            Button(loc("common.no"), role: .cancel) { }
        } message: {
            Text(loc("garden.testMode.resetConfirmation.message"))
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    private func paperButton(_ titleKey: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PaperSectionCard {
                Text(loc(titleKey))
                    .textStyle(size: 17)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
        }
        .buttonStyle(.plain)
    }

    private func requestReset() {
        guard settingsManager.testModeEnabled else { return }
        showingResetConfirmation = true
    }

    private func resetGarden() {
        guard settingsManager.testModeEnabled else { return }
        guard case .reset = gardenManager.resetWorkingGardenForTestMode(using: settingsManager) else { return }
        playerProgressManager.reset()
    }

    private func addOneStep() {
        guard settingsManager.testModeEnabled else { return }
        _ = gardenManager.addOneGardenStepForTestMode(using: settingsManager)
    }
}
#endif
