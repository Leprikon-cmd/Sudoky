import Combine
import Foundation

#if DEBUG
enum GardenResetForTestModeResult {
    case reset
    case testModeDisabled
    case failed
}
#endif

final class GardenManager: ObservableObject {
    static let shared = GardenManager(
        defaults: .standard,
        storageKey: GardenStateRepository.defaultStorageKey,
        progressManager: .shared,
        isDebugSandbox: false
    )

#if DEBUG
    private static let debugSeedMarker = "gardenDebugSeeded100Actions"

    static func effectiveRootManager(
        testModeEnabled: Bool,
        workingManager: GardenManager,
        debugManager: GardenManager?
    ) -> GardenManager? {
        testModeEnabled ? debugManager : workingManager
    }

    static func makeIsolatedManager(defaults: UserDefaults, storageKey: String, isDebugSandbox: Bool) -> GardenManager {
        GardenManager(
            defaults: defaults,
            storageKey: storageKey,
            progressManager: nil,
            isDebugSandbox: isDebugSandbox
        )
    }

    static let debugShared: GardenManager? = {
        guard let defaults = UserDefaults(suiteName: "com.sudoky.garden-debug") else { return nil }
        let manager = makeIsolatedManager(defaults: defaults, storageKey: "gardenDebugState", isDebugSandbox: true)
        manager.seedDebugGardenIfNeeded(using: defaults)
        return manager
    }()
#endif

    @Published private(set) var state: GardenState?
    @Published private(set) var issue: GardenStorageIssue?
    @Published private(set) var lastViewedSpecies: GardenSpecies = .oak

    private let repository: GardenStateRepository
    private let isDebugSandbox: Bool
    private var sourceLevel: Int
    private var levelSubscription: AnyCancellable?

    private init(
        defaults: UserDefaults,
        storageKey: String,
        progressManager: PlayerProgressManager?,
        isDebugSandbox: Bool
    ) {
        let level = progressManager?.currentLevel ?? 1
        self.sourceLevel = level
        self.isDebugSandbox = isDebugSandbox
        repository = GardenStateRepository(
            persistence: UserDefaultsGardenPersistence(defaults: defaults),
            currentLevel: level,
            storageKey: storageKey
        )
        state = repository.state
        issue = repository.issue
        lastViewedSpecies = repository.lastViewedSpecies

        if let progressManager {
            // @Published emits the new value before currentLevel itself is updated.
            levelSubscription = progressManager.$currentLevel
                .dropFirst()
                .sink { [weak self] level in
                    guard let self else { return }
                    self.sourceLevel = level
                    _ = self.apply(self.repository.observe(level: level))
                }
        }
    }

    var selectedTree: GardenTree? { state?.selectedTree }
    var hasAvailableDevelopment: Bool { issue == nil && (state?.hasAvailableDevelopment ?? false) }
    var canGrowSelectedTree: Bool { issue == nil && (state?.canGrowSelectedTree ?? false) }
    var canPlantAnyAvailableSpecies: Bool {
        issue == nil && GardenSpecies.orderedGardenSpecies.contains { state?.canPlant($0) == true }
    }

    func canPlant(_ species: GardenSpecies) -> Bool {
        issue == nil && (state?.canPlant(species) ?? false)
    }

#if DEBUG
    var canDebugGrowAllPlantedTreesToMaximum: Bool {
        !isDebugSandbox && issue == nil && (state?.canDebugGrowAllPlantedTreesToMaximum ?? false)
    }

    @discardableResult
    func debugGrowAllPlantedTreesToMaximum(
        using settingsManager: SettingsManager
    ) -> GardenTransitionResult {
        guard !isDebugSandbox, settingsManager.testModeEnabled else { return .unavailable }
        return apply(repository.debugGrowAllPlantedTreesToMaximum())
    }
#endif

    @discardableResult
    func plant(_ species: GardenSpecies) -> GardenTransitionResult {
        apply(repository.plant(species))
    }

    @discardableResult
    func selectTree(_ species: GardenSpecies) -> GardenTransitionResult {
        apply(repository.selectTree(species))
    }

    @discardableResult
    func selectSlot(_ species: GardenSpecies) -> GardenTransitionResult {
        apply(repository.selectSlot(species))
    }

    @discardableResult
    func growSelectedTree() -> GardenTransitionResult {
        apply(repository.growSelectedTree())
    }

    @discardableResult
    func reload() -> GardenTransitionResult {
        apply(repository.reload(currentLevel: sourceLevel))
    }

#if DEBUG
    @discardableResult
    func debugReset(currentLevel: Int) -> GardenTransitionResult {
        guard isDebugSandbox else { return .unavailable }
        let result = repository.debugReset(currentLevel: currentLevel)
        if result == .changed { sourceLevel = max(1, currentLevel) }
        return apply(result)
    }

    @discardableResult
    func debugAddAction() -> GardenTransitionResult {
        guard isDebugSandbox else { return .unavailable }
        return apply(repository.debugAddAction())
    }

    @discardableResult
    func resetDebugTestGarden(testModeEnabled: Bool) -> GardenTransitionResult {
        guard isDebugSandbox, testModeEnabled else { return .unavailable }
        return apply(repository.resetDebugTestGarden())
    }

    private func seedDebugGardenIfNeeded(using defaults: UserDefaults) {
        guard isDebugSandbox, !defaults.bool(forKey: Self.debugSeedMarker) else { return }
        let result = repository.resetDebugTestGarden()
        if result == .changed {
            defaults.set(true, forKey: Self.debugSeedMarker)
        }
        _ = apply(result)
    }

    @discardableResult
    func addOneGardenStepForTestMode(using settingsManager: SettingsManager) -> GardenTransitionResult {
        guard !isDebugSandbox, settingsManager.testModeEnabled else { return .unavailable }
        return apply(repository.debugAddAction())
    }

    @discardableResult
    func debugReload() -> GardenTransitionResult {
        guard isDebugSandbox else { return .unavailable }
        return apply(repository.reload(currentLevel: sourceLevel))
    }

    @discardableResult
    func debugDamageArchive() -> GardenTransitionResult {
        guard isDebugSandbox else { return .unavailable }
        return apply(repository.debugDamageArchive(currentLevel: sourceLevel))
    }

    func resetWorkingGardenForTestMode(
        using settingsManager: SettingsManager
    ) -> GardenResetForTestModeResult {
        guard !isDebugSandbox else { return .failed }
        guard settingsManager.testModeEnabled else { return .testModeDisabled }

        let result = repository.resetForTestMode()
        guard result == .changed else {
            _ = apply(result)
            return .failed
        }

        sourceLevel = 1
        _ = apply(result)
        return .reset
    }
#endif

    private func apply(_ result: GardenTransitionResult) -> GardenTransitionResult {
        state = repository.state
        issue = repository.issue
        lastViewedSpecies = repository.lastViewedSpecies
        return result
    }

}
