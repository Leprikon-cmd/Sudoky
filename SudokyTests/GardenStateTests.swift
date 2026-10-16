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

    func testJuniperAndMapleAreAvailableWhileFirRemainsLegacyOnly() {
        for species in [GardenSpecies.juniper, .maple] {
            var state = GardenState.migrated(currentLevel: 20)
            XCTAssertTrue(state.canPlant(species))
            XCTAssertEqual(state.plant(species), .changed)
            XCTAssertEqual(state.selectedTree?.species, species)
            XCTAssertTrue(state.isValid)
        }

        var legacy = GardenState.migrated(currentLevel: 20)
        XCTAssertFalse(legacy.canPlant(.fir))
        XCTAssertEqual(legacy.plant(.fir), .unsupportedSpecies)
        XCTAssertTrue(legacy.trees.isEmpty)
        XCTAssertEqual(legacy.availableActions, 19)
    }

    func testFiveOrderedSpeciesCanBeSelectedAndEmptySlotBrowsingDoesNotSpendActions() {
        XCTAssertEqual(GardenSpecies.orderedGardenSpecies, [.oak, .beech, .maple, .juniper, .apple])
        XCTAssertEqual(GardenSpecies(rawValue: "fir"), .fir)

        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 5)
        XCTAssertEqual(repository.plant(.oak), .changed)
        let balance = repository.state?.availableActions

        for species in GardenSpecies.orderedGardenSpecies where species != .oak {
            XCTAssertEqual(repository.selectSlot(species), .changed)
            XCTAssertEqual(repository.lastViewedSpecies, species)
            XCTAssertEqual(repository.state?.selectedSpecies, .oak)
            XCTAssertEqual(repository.state?.selectedTree?.species, .oak)
            XCTAssertEqual(repository.state?.availableActions, balance)
            XCTAssertTrue(repository.state?.isValid == true)
        }
        XCTAssertEqual(repository.selectSlot(.apple), .unchanged)
        XCTAssertEqual(repository.state?.availableActions, balance)
    }

    func testEmptySingleMultipleAndFiveTreeSlotNavigation() {
        var empty = GardenState.migrated(currentLevel: 1)
        XCTAssertEqual(empty.adjacentGardenSlot(from: .oak, direction: 1), .beech)
        XCTAssertEqual(empty.adjacentGardenSlot(from: .oak, direction: -1), .apple)
        XCTAssertNil(empty.adjacentGardenSlot(from: .oak, direction: 0))
        XCTAssertEqual(empty.selectTree(.oak), .noSelectedTree)
        XCTAssertTrue(empty.isValid)

        XCTAssertEqual(empty.plant(.oak), .changed)
        XCTAssertEqual(empty.adjacentGardenSlot(from: .oak, direction: 1), .beech)

        var multiple = GardenState.migrated(currentLevel: 3)
        for species in [GardenSpecies.oak, .beech, .maple] {
            XCTAssertEqual(multiple.plant(species), .changed)
        }
        XCTAssertEqual(multiple.trees.count, 3)
        XCTAssertEqual(multiple.adjacentGardenSlot(from: .beech, direction: 1), .maple)
        XCTAssertTrue(multiple.isValid)

        var full = GardenState.migrated(currentLevel: 5)
        for species in GardenSpecies.orderedGardenSpecies {
            XCTAssertEqual(full.plant(species), .changed)
        }
        XCTAssertEqual(full.trees.count, 5)
        XCTAssertFalse(GardenSpecies.orderedGardenSpecies.contains(where: { full.canPlant($0) }))
        XCTAssertTrue(full.isValid)
    }

    func testAllFiveSpeciesUseAllTenImageStagesWithManualGrowth() {
        for species in GardenSpecies.orderedGardenSpecies {
            var state = GardenState.migrated(currentLevel: 10)
            XCTAssertEqual(state.plant(species), .changed)
            for stage in 1...10 {
                XCTAssertEqual(state.selectedTree?.stage, stage)
                XCTAssertEqual(state.selectedTree?.imageAssetName, String(format: "%@_stage_%02d", species.rawValue, stage))
                if stage < 10 { XCTAssertEqual(state.growSelectedTree(), .changed) }
            }
            XCTAssertEqual(state.growSelectedTree(), .maximumStage)
            XCTAssertEqual(state.availableActions, 0)
            XCTAssertTrue(state.isValid)
        }
    }

    func testEmptyLastViewedSlotRestoresWithoutChangingSelectedArchiveTree() {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 4)
        XCTAssertEqual(repository.plant(.beech), .changed)
        XCTAssertEqual(repository.selectSlot(.apple), .changed)
        let balance = repository.state?.availableActions

        let restored = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(restored.lastViewedSpecies, .apple)
        XCTAssertEqual(restored.state?.selectedSpecies, .beech)
        XCTAssertEqual(restored.state?.selectedTree?.species, .beech)
        XCTAssertEqual(restored.state?.availableActions, balance)
        XCTAssertTrue(restored.state?.isValid == true)
    }

    func testSchemaOneOakBeechFirArchiveRemainsReadable() {
        let archive = Data(#"{"schemaVersion":1,"trees":[{"species":"oak","stage":6},{"species":"beech","stage":3},{"species":"fir","stage":2}],"selectedSpecies":"oak","availableActions":2,"highestCountedLevel":8,"hasUsedFirstFreePlanting":true}"#.utf8)
        let persistence = MemoryGardenPersistence(value: .data(archive))
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertNil(repository.issue)
        XCTAssertEqual(repository.state?.trees.map(\.species), [.oak, .beech, .fir])
        XCTAssertEqual(repository.state?.selectedSpecies, .oak)
        XCTAssertEqual(repository.lastViewedSpecies, .oak)
        XCTAssertNil(repository.state?.trees.first(where: { $0.species == .fir })?.imageAssetName)
        XCTAssertTrue(repository.state?.isValid == true)
    }

    func testLastViewedSlotWriteFailurePreservesGardenArchiveAndBalance() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 3)
        XCTAssertEqual(repository.plant(.oak), .changed)
        let stateBefore = try XCTUnwrap(repository.state)
        let archiveBefore = try XCTUnwrap(persistence.data(forKey: GardenStateRepository.defaultStorageKey))

        persistence.failsWrites = true
        XCTAssertEqual(repository.selectSlot(.maple), .unavailable)
        XCTAssertEqual(repository.issue, .writeFailed)
        XCTAssertEqual(repository.state, stateBefore)
        XCTAssertEqual(repository.state?.availableActions, stateBefore.availableActions)
        XCTAssertEqual(persistence.data(forKey: GardenStateRepository.defaultStorageKey), archiveBefore)
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
        XCTAssertEqual(state.displayedTreeSpecies, [.oak, .beech, .juniper])
        XCTAssertEqual(state.adjacentDisplayedTreeSpecies(from: .oak, direction: 1), .beech)
        XCTAssertEqual(state.adjacentDisplayedTreeSpecies(from: .beech, direction: 1), .juniper)
        XCTAssertEqual(state.adjacentDisplayedTreeSpecies(from: .oak, direction: -1), .juniper)
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
            trees: [GardenTree(species: .fir, stage: 1)],
            selectedSpecies: .fir,
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
    func testDebugTestGardenConsumesFortyNineStepsForFiveFullyGrownTreesAndRestores() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(repository.state?.availableActions, 0)
        XCTAssertEqual(repository.resetDebugTestGarden(), .changed)
        XCTAssertEqual(repository.state?.availableActions, 100)
        XCTAssertEqual(repository.lastViewedSpecies, .oak)
        XCTAssertTrue(repository.state?.isValid == true)

        for species in GardenSpecies.orderedGardenSpecies {
            XCTAssertEqual(repository.plant(species), .changed)
        }
        XCTAssertEqual(repository.state?.availableActions, 96)

        for species in GardenSpecies.orderedGardenSpecies {
            XCTAssertEqual(repository.selectTree(species), .changed)
            for _ in 2...10 {
                XCTAssertEqual(repository.growSelectedTree(), .changed)
            }
        }

        XCTAssertEqual(repository.state?.trees.map(\.stage), [10, 10, 10, 10, 10])
        XCTAssertEqual(repository.state?.availableActions, 51)
        XCTAssertEqual(100 - (repository.state?.availableActions ?? 100), 49)
        XCTAssertEqual(repository.state?.highestCountedLevel, 1)
        XCTAssertEqual(repository.lastViewedSpecies, .apple)

        let relaunchedRepository = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(relaunchedRepository.state?.trees.map(\.stage), [10, 10, 10, 10, 10])
        XCTAssertEqual(relaunchedRepository.state?.availableActions, 51)
        XCTAssertEqual(relaunchedRepository.lastViewedSpecies, .apple)

        XCTAssertEqual(relaunchedRepository.resetDebugTestGarden(), .changed)
        var expectedFreshState = GardenState.migrated(currentLevel: 1)
        expectedFreshState.availableActions = 100
        XCTAssertEqual(relaunchedRepository.state, expectedFreshState)
        XCTAssertEqual(relaunchedRepository.lastViewedSpecies, .oak)
        XCTAssertEqual(persistence.data(forKey: "\(GardenStateRepository.defaultStorageKey).lastViewedSpecies"), Data("oak".utf8))
        let afterResetRelaunch = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(afterResetRelaunch.state?.availableActions, 100)
        XCTAssertTrue(afterResetRelaunch.state?.trees.isEmpty == true)
        XCTAssertEqual(afterResetRelaunch.lastViewedSpecies, .oak)

        let ordinaryGarden = GardenStateRepository(persistence: MemoryGardenPersistence(), currentLevel: 1)
        XCTAssertEqual(ordinaryGarden.state?.availableActions, 0)
    }

    func testDebugTestGardenResetWriteFailurePreservesArchiveAndLastViewedSlot() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(repository.resetDebugTestGarden(), .changed)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.selectSlot(.maple), .changed)
        let stateBefore = try XCTUnwrap(repository.state)
        let archiveBefore = try XCTUnwrap(persistence.data(forKey: GardenStateRepository.defaultStorageKey))
        let slotBefore = try XCTUnwrap(persistence.data(forKey: "\(GardenStateRepository.defaultStorageKey).lastViewedSpecies"))

        persistence.failsWrites = true
        XCTAssertEqual(repository.resetDebugTestGarden(), .unavailable)
        XCTAssertEqual(repository.issue, .writeFailed)
        XCTAssertEqual(repository.state, stateBefore)
        XCTAssertEqual(repository.lastViewedSpecies, .maple)
        XCTAssertEqual(persistence.data(forKey: GardenStateRepository.defaultStorageKey), archiveBefore)
        XCTAssertEqual(persistence.data(forKey: "\(GardenStateRepository.defaultStorageKey).lastViewedSpecies"), slotBefore)
    }

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
        for species in GardenSpecies.orderedGardenSpecies {
            XCTAssertEqual(repository.plant(species), .changed)
        }
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        XCTAssertEqual(repository.selectSlot(.maple), .changed)
        XCTAssertEqual(repository.state?.availableActions, 2)
        XCTAssertEqual(repository.state?.highestCountedLevel, 8)
        XCTAssertEqual(Set(repository.state?.trees.map(\.species) ?? []), Set(GardenSpecies.orderedGardenSpecies))
        XCTAssertTrue(repository.state?.hasUsedFirstFreePlanting == true)
        XCTAssertEqual(repository.lastViewedSpecies, .maple)

        XCTAssertEqual(repository.resetForTestMode(), .changed)
        XCTAssertEqual(repository.state, GardenState.migrated(currentLevel: 1))
        XCTAssertTrue(repository.state?.trees.isEmpty == true)
        XCTAssertNil(repository.state?.selectedTree)
        XCTAssertEqual(repository.state?.availableActions, 0)
        XCTAssertEqual(repository.state?.highestCountedLevel, 1)
        XCTAssertFalse(repository.state?.hasUsedFirstFreePlanting ?? true)
        XCTAssertEqual(repository.lastViewedSpecies, .oak)
        XCTAssertEqual(persistence.data(forKey: "\(GardenStateRepository.defaultStorageKey).lastViewedSpecies"), Data("oak".utf8))

        let restored = GardenStateRepository(persistence: persistence, currentLevel: 1)
        XCTAssertEqual(restored.state, GardenState.migrated(currentLevel: 1))
        XCTAssertEqual(restored.lastViewedSpecies, .oak)
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
        XCTAssertEqual(repository.selectSlot(.beech), .changed)
        XCTAssertEqual(repository.growSelectedTree(), .changed)
        let oldState = try XCTUnwrap(repository.state)
        let oldArchive: Data
        if case .data(let data) = persistence.value {
            oldArchive = data
        } else {
            return XCTFail("Expected persisted working garden")
        }
        let oldViewedSlot = try XCTUnwrap(persistence.data(forKey: "\(GardenStateRepository.defaultStorageKey).lastViewedSpecies"))

        persistence.failsWrites = true
        XCTAssertEqual(repository.resetForTestMode(), .unavailable)
        XCTAssertEqual(repository.state, oldState)
        XCTAssertEqual(repository.lastViewedSpecies, .beech)
        XCTAssertEqual(repository.issue, .writeFailed)
        XCTAssertEqual(persistence.data(forKey: "\(GardenStateRepository.defaultStorageKey).lastViewedSpecies"), oldViewedSlot)
        if case .data(let data) = persistence.value {
            XCTAssertEqual(data, oldArchive)
        } else {
            XCTFail("Failed reset must preserve the previous archive")
        }
    }

    func testDebugAddActionAddsExactlyOneStepWithoutChangingOtherGardenState() throws {
        let persistence = MemoryGardenPersistence()
        let repository = GardenStateRepository(persistence: persistence, currentLevel: 4)
        XCTAssertEqual(repository.plant(.oak), .changed)
        XCTAssertEqual(repository.plant(.beech), .changed)
        XCTAssertEqual(repository.selectSlot(.apple), .changed)
        let before = try XCTUnwrap(repository.state)

        XCTAssertEqual(repository.debugAddAction(), .changed)
        let after = try XCTUnwrap(repository.state)
        XCTAssertEqual(after.availableActions, before.availableActions + 1)
        XCTAssertEqual(after.trees, before.trees)
        XCTAssertEqual(after.selectedSpecies, before.selectedSpecies)
        XCTAssertEqual(after.highestCountedLevel, before.highestCountedLevel)
        XCTAssertEqual(after.hasUsedFirstFreePlanting, before.hasUsedFirstFreePlanting)
        XCTAssertEqual(repository.lastViewedSpecies, .apple)
    }

    func testIsolatedDebugGardenResetRestoresFreshTestOnlyState() throws {
        let workingSuite = "com.sudoky.garden-working-tests.\(UUID().uuidString)"
        let testSuite = "com.sudoky.garden-debug-tests.\(UUID().uuidString)"
        let workingDefaults = try XCTUnwrap(UserDefaults(suiteName: workingSuite))
        let testDefaults = try XCTUnwrap(UserDefaults(suiteName: testSuite))
        defer {
            workingDefaults.removePersistentDomain(forName: workingSuite)
            testDefaults.removePersistentDomain(forName: testSuite)
        }

        let workingManager = GardenManager.makeIsolatedManager(
            defaults: workingDefaults,
            storageKey: "isolatedWorkingGarden",
            isDebugSandbox: false
        )
        let testManager = GardenManager.makeIsolatedManager(
            defaults: testDefaults,
            storageKey: "isolatedDebugGarden",
            isDebugSandbox: true
        )
        XCTAssertEqual(workingManager.plant(.oak), .changed)
        let workingStateBeforeReset = try XCTUnwrap(workingManager.state)

        XCTAssertEqual(testManager.resetDebugTestGarden(testModeEnabled: false), .unavailable)
        XCTAssertEqual(testManager.resetDebugTestGarden(testModeEnabled: true), .changed)
        XCTAssertEqual(testManager.state?.availableActions, 100)
        XCTAssertTrue(testManager.state?.trees.isEmpty == true)
        XCTAssertEqual(testManager.lastViewedSpecies, .oak)

        XCTAssertEqual(testManager.plant(.oak), .changed)
        XCTAssertEqual(testManager.selectSlot(.maple), .changed)
        XCTAssertEqual(testManager.resetDebugTestGarden(testModeEnabled: true), .changed)
        XCTAssertEqual(testManager.state?.availableActions, 100)
        XCTAssertTrue(testManager.state?.trees.isEmpty == true)
        XCTAssertEqual(testManager.lastViewedSpecies, .oak)
        XCTAssertEqual(workingManager.state, workingStateBeforeReset)
        XCTAssertEqual(workingManager.lastViewedSpecies, .oak)
        XCTAssertEqual(workingManager.resetDebugTestGarden(testModeEnabled: true), .unavailable)
    }
#endif

#if DEBUG
    func testRootManagerSelectionKeepsTestGardenIsolated() throws {
        let workingSuite = "com.sudoky.garden-root-working-tests.\(UUID().uuidString)"
        let testSuite = "com.sudoky.garden-root-debug-tests.\(UUID().uuidString)"
        let workingDefaults = try XCTUnwrap(UserDefaults(suiteName: workingSuite))
        let testDefaults = try XCTUnwrap(UserDefaults(suiteName: testSuite))
        defer {
            workingDefaults.removePersistentDomain(forName: workingSuite)
            testDefaults.removePersistentDomain(forName: testSuite)
        }
        let workingManager = GardenManager.makeIsolatedManager(
            defaults: workingDefaults,
            storageKey: "rootWorkingGarden",
            isDebugSandbox: false
        )
        let testManager = GardenManager.makeIsolatedManager(
            defaults: testDefaults,
            storageKey: "rootDebugGarden",
            isDebugSandbox: true
        )

        XCTAssertTrue(GardenManager.effectiveRootManager(
            testModeEnabled: true,
            workingManager: workingManager,
            debugManager: testManager
        ) === testManager)
        XCTAssertTrue(GardenManager.effectiveRootManager(
            testModeEnabled: false,
            workingManager: workingManager,
            debugManager: testManager
        ) === workingManager)
    }
#endif
}

private final class MemoryGardenPersistence: GardenPersistence {
    private var values: [String: GardenStoredValue] = [:]
    var failsWrites: Bool

    var value: GardenStoredValue {
        get { read(GardenStateRepository.defaultStorageKey) }
        set { values[GardenStateRepository.defaultStorageKey] = newValue }
    }

    init(value: GardenStoredValue = .missing, failsWrites: Bool = false) {
        values[GardenStateRepository.defaultStorageKey] = value
        self.failsWrites = failsWrites
    }

    func read(_ key: String) -> GardenStoredValue { values[key] ?? .missing }

    func data(forKey key: String) -> Data? {
        guard case .data(let data) = read(key) else { return nil }
        return data
    }

    func write(_ data: Data, forKey key: String) throws {
        guard !failsWrites else { throw WriteFailure.failed }
        values[key] = .data(data)
    }

    private enum WriteFailure: Error { case failed }
}
