import Foundation
import XCTest
@testable import Sudoky

final class GardenStateTests: XCTestCase {
    func testMigrationAndFirstFreePlanting() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 6)

        XCTAssertEqual(repository.state?.availableActions, 5)
        XCTAssertEqual(repository.state?.highestCountedLevel, 6)
        XCTAssertTrue(repository.state?.trees.isEmpty == true)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.state?.availableActions, 5)
        XCTAssertEqual(repository.state?.selectedTree?.stage, 1)

        let restored = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(restored.state?.availableActions, 5)
        XCTAssertEqual(restored.state?.selectedTree?.stage, 1)
        XCTAssertEqual(restored.plant(.oak), .alreadyPlanted)
        XCTAssertEqual(restored.growSelectedTree(), .changed)

        let afterRestart = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(afterRestart.state?.availableActions, 4)
        XCTAssertEqual(afterRestart.state?.selectedTree?.stage, 2)
    }

    func testLevelJumpsAndHighWatermarkPreventDuplicateAwards() {
        var state = GardenState.migrated(currentLevel: 1)
        XCTAssertEqual(state.observe(level: 4), .changed)
        XCTAssertEqual(state.availableActions, 3)
        XCTAssertEqual(state.observe(level: 2), .unchanged)
        XCTAssertEqual(state.observe(level: 4), .unchanged)
        XCTAssertEqual(state.observe(level: 6), .changed)
        XCTAssertEqual(state.availableActions, 5)
    }

    func testLevelTenExhaustsActionsAtStageTenAndCannotGrowFurther() {
        var state = GardenState.migrated(currentLevel: 10)
        XCTAssertEqual(state.plant(.fir), .unsupportedSpecies)
        XCTAssertEqual(state.plant(.oak), .changed)
        XCTAssertEqual(state.plant(.oak), .alreadyPlanted)

        for expectedStage in 2...10 {
            XCTAssertEqual(state.growSelectedTree(), .changed)
            XCTAssertEqual(state.selectedTree?.stage, expectedStage)
        }
        XCTAssertEqual(state.growSelectedTree(), .maximumStage)
        XCTAssertEqual(state.availableActions, 0)
        XCTAssertFalse(state.hasAvailableDevelopment)
        XCTAssertTrue(state.isValid)
    }

    func testBeechCanBeTheOneTimeFreeFirstPlanting() {
        var state = GardenState.migrated(currentLevel: 1)
        XCTAssertEqual(state.plant(.beech), .changed)
        XCTAssertEqual(state.availableActions, 0)
        XCTAssertEqual(state.selectedTree?.species, .beech)
        XCTAssertEqual(state.selectedTree?.imageAssetName, "beech_stage_01")
        XCTAssertTrue(state.isValid)
    }

    func testSecondSpeciesCostsOneActionInEitherPlantingOrder() {
        for order in [[GardenSpecies.oak, .beech], [.beech, .oak]] {
            var state = GardenState.migrated(currentLevel: 2)
            XCTAssertEqual(state.plant(order[0]), .changed)
            XCTAssertEqual(state.availableActions, 1)
            XCTAssertEqual(state.plant(order[1]), .changed)
            XCTAssertEqual(state.availableActions, 0)
            XCTAssertEqual(state.trees.map(\.species), order)
            XCTAssertTrue(state.isValid)
        }
    }

    func testSecondPlantingWithoutActionsAndDuplicateSpeciesDoNotChangeState() {
        var state = GardenState.migrated(currentLevel: 1)
        XCTAssertEqual(state.plant(.beech), .changed)
        let afterFirst = state
        XCTAssertEqual(state.plant(.beech), .alreadyPlanted)
        XCTAssertEqual(state, afterFirst)
        XCTAssertEqual(state.plant(.oak), .noActions)
        XCTAssertEqual(state, afterFirst)

        var funded = GardenState.migrated(currentLevel: 2)
        XCTAssertEqual(funded.plant(.oak), .changed)
        XCTAssertEqual(funded.plant(.oak), .alreadyPlanted)
        XCTAssertEqual(funded.availableActions, 1)
    }

    func testOakAndBeechSelectionGrowIndependently() {
        var state = GardenState.migrated(currentLevel: 5)
        XCTAssertEqual(state.plant(.oak), .changed)
        XCTAssertEqual(state.plant(.beech), .changed)
        XCTAssertEqual(state.availableActions, 3)

        XCTAssertEqual(state.selectTree(.oak), .changed)
        XCTAssertEqual(state.growSelectedTree(), .changed)
        XCTAssertEqual(state.trees.first(where: { $0.species == .oak })?.stage, 2)
        XCTAssertEqual(state.trees.first(where: { $0.species == .beech })?.stage, 1)

        XCTAssertEqual(state.selectTree(.beech), .changed)
        XCTAssertEqual(state.growSelectedTree(), .changed)
        XCTAssertEqual(state.selectedTree?.species, .beech)
        XCTAssertEqual(state.selectedTree?.stage, 2)
        XCTAssertEqual(state.availableActions, 1)
        XCTAssertTrue(state.isValid)
    }

    func testBeechSupportsAllTenStagesAndStopsAtTen() {
        var state = GardenState.migrated(currentLevel: 10)
        XCTAssertEqual(state.plant(.beech), .changed)
        for stage in 1...10 {
            XCTAssertEqual(state.selectedTree?.stage, stage)
            XCTAssertEqual(state.selectedTree?.imageAssetName, String(format: "beech_stage_%02d", stage))
            if stage < 10 { XCTAssertEqual(state.growSelectedTree(), .changed) }
        }
        XCTAssertEqual(state.growSelectedTree(), .maximumStage)
        XCTAssertEqual(state.availableActions, 0)
    }

    func testBeechAndOakStateRestoreWithSelectionStagesAndBalance() {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 7)
        XCTAssertEqual(repository.plant(.beech), .changed)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.selectTree(.beech), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)

        let restored = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(restored.state?.selectedSpecies, .beech)
        XCTAssertEqual(restored.state?.trees.first(where: { $0.species == .oak })?.stage, 1)
        XCTAssertEqual(restored.state?.trees.first(where: { $0.species == .beech })?.stage, 2)
        XCTAssertEqual(restored.state?.availableActions, 4)
        XCTAssertTrue(restored.state?.isValid == true)
    }

    func testPreviouslyStoredOakArchiveStillLoadsUnchanged() {
        let oldOakState = GardenState(
            schemaVersion: 1,
            trees: [GardenTree(species: .oak, stage: 6)],
            selectedSpecies: .oak,
            availableActions: 2,
            highestCountedLevel: 8,
            hasUsedFirstFreePlanting: true
        )
        let oldData = Data(#"{"schemaVersion":1,"trees":[{"species":"oak","stage":6}],"selectedSpecies":"oak","availableActions":2,"highestCountedLevel":8,"hasUsedFirstFreePlanting":true}"#.utf8)
        let persistence = MemoryGardenPersistence(value: .data(oldData))
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertNil(repository.issue)
        XCTAssertEqual(repository.state, oldOakState)
        XCTAssertEqual(repository.state?.selectedTree?.imageAssetName, "oak_stage_06")
    }

    func testJuniperFirAndMapleRemainUnavailable() {
        var state = GardenState.migrated(currentLevel: 20)
        for species in [GardenSpecies.juniper, .fir, .maple] {
            XCTAssertFalse(state.canPlant(species))
            XCTAssertEqual(state.plant(species), .unsupportedSpecies)
        }
        XCTAssertTrue(state.trees.isEmpty)
        XCTAssertEqual(state.availableActions, 19)
    }

    func testDisplayedTreeCyclingUsesSpeciesOrderAndWrapsBothWays() {
        let state = GardenState(
            schemaVersion: GardenState.currentSchemaVersion,
            trees: [
                GardenTree(species: .beech, stage: 4),
                GardenTree(species: .juniper, stage: 3),
                GardenTree(species: .oak, stage: 2)
            ],
            selectedSpecies: .oak,
            availableActions: 2,
            highestCountedLevel: 3,
            hasUsedFirstFreePlanting: true
        )
        XCTAssertEqual(state.displayedTreeSpecies, [.oak, .beech])
        XCTAssertEqual(state.adjacentDisplayedTreeSpecies(from: .oak, direction: 1), .beech)
        XCTAssertEqual(state.adjacentDisplayedTreeSpecies(from: .beech, direction: 1), .oak)
        XCTAssertEqual(state.adjacentDisplayedTreeSpecies(from: .oak, direction: -1), .beech)
        XCTAssertNil(state.adjacentDisplayedTreeSpecies(from: .oak, direction: 0))

        let oneTree = GardenState(
            schemaVersion: GardenState.currentSchemaVersion,
            trees: [GardenTree(species: .oak, stage: 1)],
            selectedSpecies: .oak,
            availableActions: 0,
            highestCountedLevel: 1,
            hasUsedFirstFreePlanting: true
        )
        XCTAssertNil(oneTree.adjacentDisplayedTreeSpecies(from: .oak, direction: 1))
        XCTAssertNil(GardenState.migrated(currentLevel: 1).adjacentDisplayedTreeSpecies(from: .oak, direction: 1))
    }

    func testLevelElevenKeepsOneActionAfterOakIsFullyGrown() {
        var state = GardenState.migrated(currentLevel: 11)
        XCTAssertEqual(state.plant(.oak), .changed)

        for expectedStage in 2...10 {
            XCTAssertEqual(state.growSelectedTree(), .changed)
            XCTAssertEqual(state.selectedTree?.stage, expectedStage)
        }

        XCTAssertEqual(state.availableActions, 1)
        XCTAssertTrue(state.hasAvailableDevelopment)
        XCTAssertEqual(state.growSelectedTree(), .maximumStage)
        XCTAssertEqual(state.selectedTree?.stage, 10)
        XCTAssertEqual(state.availableActions, 1)
    }

    func testUnsupportedSpeciesCannotGrowAndMissingSelectionIsInvalid() {
        var unsupported = GardenState(
            schemaVersion: GardenState.currentSchemaVersion,
            trees: [GardenTree(species: .juniper, stage: 1)],
            selectedSpecies: .juniper,
            availableActions: 1,
            highestCountedLevel: 2,
            hasUsedFirstFreePlanting: true
        )
        XCTAssertFalse(unsupported.canGrowSelectedTree)
        XCTAssertEqual(unsupported.growSelectedTree(), .unsupportedSpecies)
        XCTAssertEqual(unsupported.trees.first?.stage, 1)

        unsupported.selectedSpecies = nil
        XCTAssertFalse(unsupported.isValid)

        var removedTree = GardenState.migrated(currentLevel: 1)
        removedTree.hasUsedFirstFreePlanting = true
        XCTAssertFalse(removedTree.isValid)
    }

    func testCorruptAndUnknownArchivesFailClosed() throws {
        let corrupt = MemoryGardenPersistence(value: .data(Data("{broken".utf8)))
        let corruptRepository = GardenStateRepository(persistence: corrupt, currentLevel: 20)
        XCTAssertNil(corruptRepository.state)
        XCTAssertEqual(corruptRepository.issue, .damagedData)
        XCTAssertEqual(corruptRepository.plant(.oak), .unavailable)

        let unknownArchive = Data("{\"schemaVersion\":99}".utf8)
        let unknown = MemoryGardenPersistence(value: .data(unknownArchive))
        let unknownRepository = GardenStateRepository(persistence: unknown, currentLevel: 20)
        XCTAssertNil(unknownRepository.state)
        XCTAssertEqual(unknownRepository.issue, .unsupportedVersion)
        if case .data(let preserved) = unknown.value {
            XCTAssertEqual(preserved, unknownArchive)
        } else {
            XCTFail("Unsupported archive was overwritten")
        }
    }

    func testExistingArchiveIsNotMutatedWhenAwardWriteFails() throws {
        let persistence = MemoryGardenPersistence(failsWrites: true)
        let initial = GardenState.migrated(currentLevel: 1)
        persistence.failsWrites = false
        try persistence.write(JSONEncoder().encode(initial), forKey: GardenStateRepository.defaultStorageKey)
        persistence.failsWrites = true

        let repository = GardenStateRepository(persistence: persistence, currentLevel: 2)
        XCTAssertEqual(repository.issue, .writeFailed)
        XCTAssertEqual(repository.state?.availableActions, 0)
        XCTAssertEqual(repository.plant(.oak), .unavailable)
    }

#if DEBUG
    func testDebugGrowAllPlantedTreesToMaximumPreservesGardenProgress() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 12)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.plant(.beech), .changed)
        XCTAssertEqual(repository.selectTree(.oak), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        XCTAssertEqual(repository.selectTree(.beech), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        let before = try XCTUnwrap(repository.state)
        XCTAssertEqual(before.trees.map(\.stage), [3, 2])

        XCTAssertTrue(before.canDebugGrowAllPlantedTreesToMaximum)
        XCTAssertEqual(repository.debugGrowAllPlantedTreesToMaximum(), .changed)
        let grown = try XCTUnwrap(repository.state)
        XCTAssertEqual(grown.trees.map(\.stage), [10, 10])
        XCTAssertEqual(grown.selectedSpecies, before.selectedSpecies)
        XCTAssertEqual(grown.availableActions, before.availableActions)
        XCTAssertEqual(grown.highestCountedLevel, before.highestCountedLevel)
        XCTAssertEqual(grown.hasUsedFirstFreePlanting, before.hasUsedFirstFreePlanting)

        let restored = GardenStateRepository(persistence: persistence, currentLevel: 12)
        XCTAssertEqual(restored.state, grown)
        XCTAssertEqual(restored.debugGrowAllPlantedTreesToMaximum(), .unchanged)
        XCTAssertFalse(restored.state?.canDebugGrowAllPlantedTreesToMaximum ?? true)
    }

    func testDebugGrowAllIsNoOpForEmptyGardenAndPreservesArchiveOnWriteFailure() throws {
        let emptyPersistence = MemoryGardenPersistence()
        let emptyRepository = GardenStateRepository(persistence: emptyPersistence, currentLevel: 4)
        let emptyState = try XCTUnwrap(emptyRepository.state)
        XCTAssertFalse(emptyState.canDebugGrowAllPlantedTreesToMaximum)
        XCTAssertEqual(emptyRepository.debugGrowAllPlantedTreesToMaximum(), .unchanged)
        XCTAssertEqual(emptyRepository.state, emptyState)

        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 6)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.plant(.beech), .changed)
        let oldState = try XCTUnwrap(repository.state)
        let oldArchive: Data
        if case .data(let data) = persistence.value {
            oldArchive = data
        } else {
            return XCTFail("Expected persisted two-tree garden")
        }

        persistence.failsWrites = true
        XCTAssertEqual(repository.debugGrowAllPlantedTreesToMaximum(), .unavailable)
        XCTAssertEqual(repository.state, oldState)
        XCTAssertEqual(repository.issue, .writeFailed)
        if case .data(let data) = persistence.value {
            XCTAssertEqual(data, oldArchive)
        } else {
            XCTFail("Failed test growth must preserve the previous archive")
        }
    }

    func testTestModeResetClearsWorkingGardenAndAllowsFreshProgress() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 8)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.plant(.beech), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        XCTAssertEqual(repository.state?.availableActions, 5)
        XCTAssertEqual(repository.state?.highestCountedLevel, 8)
        XCTAssertEqual(Set(repository.state?.trees.map(\.species) ?? []), Set([.oak, .beech]))

        XCTAssertEqual(repository.resetForTestMode(), .changed)
        XCTAssertEqual(repository.state, GardenState.migrated(currentLevel: 1))
        XCTAssertTrue(repository.state?.trees.isEmpty == true)
        XCTAssertNil(repository.state?.selectedTree)
        XCTAssertEqual(repository.state?.availableActions, 0)
        XCTAssertEqual(repository.state?.highestCountedLevel, 1)
        XCTAssertFalse(repository.state?.hasUsedFirstFreePlanting ?? true)

        let restored = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(restored.state, GardenState.migrated(currentLevel: 1))
        XCTAssertTrue(restored.state?.trees.isEmpty == true)
        XCTAssertEqual(restored.plant(.oak), .changed)
        XCTAssertEqual(restored.state?.availableActions, 0)
        XCTAssertEqual(restored.resetForTestMode(), .changed)
        XCTAssertEqual(restored.state, GardenState.migrated(currentLevel: 1))

        XCTAssertEqual(restored.observe(level: 2), .changed)
        XCTAssertEqual(restored.state?.availableActions, 1)
        XCTAssertEqual(restored.state?.highestCountedLevel, 2)
    }

    func testTestModeResetWriteFailurePreservesStoredAndPublishedGarden() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 6)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        let oldState = try XCTUnwrap(repository.state)
        let oldArchive: Data
        if case .data(let data) = persistence.value {
            oldArchive = data
        } else {
            return XCTFail("Expected persisted working garden")
        }

        persistence.failsWrites = true
        XCTAssertEqual(repository.resetForTestMode(), .unavailable)
        XCTAssertEqual(repository.state, oldState)
        XCTAssertEqual(repository.issue, .writeFailed)
        if case .data(let data) = persistence.value {
            XCTAssertEqual(data, oldArchive)
        } else {
            XCTFail("Failed reset must preserve the previous archive")
        }
    }
#endif
}

private final class MemoryGardenPersistence: GardenPersistence {
    var value: GardenStoredValue
    var failsWrites: Bool

    init(value: GardenStoredValue = .missing, failsWrites: Bool = false) {
        self.value = value
        self.failsWrites = failsWrites
    }

    func read(_ key: String) -> GardenStoredValue { value }

    func write(_ data: Data, forKey key: String) throws {
        guard !failsWrites else { throw WriteFailure.failed }
        value = .data(data)
    }

    private enum WriteFailure: Error { case failed }
}
