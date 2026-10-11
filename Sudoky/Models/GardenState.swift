import Foundation

enum GardenSpecies: String, CaseIterable, Codable, Hashable {
    case oak
    case juniper
    case fir
    case maple
    case beech

    var isCurrentlyPlantable: Bool { self == .oak || self == .beech }
}

struct GardenTree: Codable, Equatable, Identifiable {
    let species: GardenSpecies
    var stage: Int

    var id: GardenSpecies { species }

    var imageAssetName: String? {
        guard species.isCurrentlyPlantable, (1...10).contains(stage) else { return nil }
        return String(format: "%@_stage_%02d", species.rawValue, stage)
    }
}

enum GardenTransitionResult: Equatable {
    case changed
    case unchanged
    case unavailable
    case unsupportedSpecies
    case alreadyPlanted
    case noActions
    case noSelectedTree
    case maximumStage
}

enum GardenStorageIssue: Equatable {
    case damagedData
    case unsupportedVersion
    case invalidState
    case writeFailed
}

struct GardenState: Codable, Equatable {
    static let currentSchemaVersion = 1

    var schemaVersion: Int
    var trees: [GardenTree]
    var selectedSpecies: GardenSpecies?
    var availableActions: Int
    var highestCountedLevel: Int
    var hasUsedFirstFreePlanting: Bool

    static func migrated(currentLevel: Int) -> GardenState {
        let level = max(1, currentLevel)
        return GardenState(
            schemaVersion: currentSchemaVersion,
            trees: [],
            selectedSpecies: nil,
            availableActions: level - 1,
            highestCountedLevel: level,
            hasUsedFirstFreePlanting: false
        )
    }

    var selectedTree: GardenTree? {
        guard let selectedSpecies else { return nil }
        return trees.first { $0.species == selectedSpecies }
    }

    var displayedTreeSpecies: [GardenSpecies] {
        GardenSpecies.allCases.filter { species in
            trees.first(where: { $0.species == species })?.imageAssetName != nil
        }
    }

    func adjacentDisplayedTreeSpecies(from species: GardenSpecies, direction: Int) -> GardenSpecies? {
        let displayedSpecies = displayedTreeSpecies
        guard direction != 0,
              displayedSpecies.count > 1,
              let index = displayedSpecies.firstIndex(of: species) else { return nil }
        let count = displayedSpecies.count
        let step = direction > 0 ? 1 : -1
        return displayedSpecies[(index + step + count) % count]
    }

    var hasAvailableDevelopment: Bool {
        availableActions > 0
    }

    var canGrowSelectedTree: Bool {
        guard availableActions > 0, let tree = selectedTree else { return false }
        return tree.species.isCurrentlyPlantable && tree.stage < 10
    }

    func canPlant(_ species: GardenSpecies) -> Bool {
        guard species.isCurrentlyPlantable,
              !trees.contains(where: { $0.species == species }) else { return false }
        return !hasUsedFirstFreePlanting || availableActions > 0
    }

    var isValid: Bool {
        guard schemaVersion == Self.currentSchemaVersion,
              availableActions >= 0,
              highestCountedLevel >= 1,
              trees.count <= GardenSpecies.allCases.count else { return false }

        let species = trees.map(\.species)
        guard Set(species).count == species.count,
              trees.allSatisfy({ (1...10).contains($0.stage) }) else { return false }

        if let selectedSpecies, !species.contains(selectedSpecies) { return false }
        if trees.isEmpty, (selectedSpecies != nil || hasUsedFirstFreePlanting) { return false }
        if !trees.isEmpty, selectedSpecies == nil { return false }
        if !trees.isEmpty, !hasUsedFirstFreePlanting { return false }
        return true
    }

    mutating func observe(level: Int) -> GardenTransitionResult {
        let level = max(1, level)
        guard level > highestCountedLevel else { return .unchanged }

        let newlyEarned = level - highestCountedLevel
        let (newBalance, overflow) = availableActions.addingReportingOverflow(newlyEarned)
        availableActions = overflow ? Int.max : newBalance
        highestCountedLevel = level
        return .changed
    }

    mutating func plant(_ species: GardenSpecies) -> GardenTransitionResult {
        guard species.isCurrentlyPlantable else { return .unsupportedSpecies }
        guard !trees.contains(where: { $0.species == species }) else { return .alreadyPlanted }

        if hasUsedFirstFreePlanting {
            guard availableActions > 0 else { return .noActions }
            availableActions -= 1
        }

        trees.append(GardenTree(species: species, stage: 1))
        selectedSpecies = species
        hasUsedFirstFreePlanting = true
        return .changed
    }

    mutating func selectTree(_ species: GardenSpecies) -> GardenTransitionResult {
        guard species.isCurrentlyPlantable else { return .unsupportedSpecies }
        guard trees.contains(where: { $0.species == species }) else { return .noSelectedTree }
        guard selectedSpecies != species else { return .unchanged }
        selectedSpecies = species
        return .changed
    }

    mutating func growSelectedTree() -> GardenTransitionResult {
        guard let selectedSpecies,
              let index = trees.firstIndex(where: { $0.species == selectedSpecies }) else {
            return .noSelectedTree
        }
        guard trees[index].species.isCurrentlyPlantable else { return .unsupportedSpecies }
        guard trees[index].stage < 10 else { return .maximumStage }
        guard availableActions > 0 else { return .noActions }

        availableActions -= 1
        trees[index].stage += 1
        return .changed
    }

#if DEBUG
    var canDebugGrowAllPlantedTreesToMaximum: Bool {
        trees.contains { $0.species.isCurrentlyPlantable && $0.stage < 10 }
    }

    mutating func debugGrowAllPlantedTreesToMaximum() -> GardenTransitionResult {
        guard canDebugGrowAllPlantedTreesToMaximum else { return .unchanged }
        for index in trees.indices where trees[index].species.isCurrentlyPlantable {
            trees[index].stage = 10
        }
        return .changed
    }

    mutating func debugAddAction() -> GardenTransitionResult {
        let (balance, overflow) = availableActions.addingReportingOverflow(1)
        availableActions = overflow ? Int.max : balance
        return .changed
    }
#endif
}

enum GardenStoredValue {
    case missing
    case data(Data)
    case invalid
}

protocol GardenPersistence {
    func read(_ key: String) -> GardenStoredValue
    func write(_ data: Data, forKey key: String) throws
}

struct UserDefaultsGardenPersistence: GardenPersistence {
    let defaults: UserDefaults

    func read(_ key: String) -> GardenStoredValue {
        guard let value = defaults.object(forKey: key) else { return .missing }
        guard let data = value as? Data else { return .invalid }
        return .data(data)
    }

    func write(_ data: Data, forKey key: String) throws {
        defaults.set(data, forKey: key)
    }
}

final class GardenStateRepository {
    static let defaultStorageKey = "wisdomGardenState"

    private let persistence: GardenPersistence
    private let storageKey: String
    private(set) var state: GardenState?
    private(set) var issue: GardenStorageIssue?

    init(
        persistence: GardenPersistence,
        currentLevel: Int,
        storageKey: String = GardenStateRepository.defaultStorageKey
    ) {
        self.persistence = persistence
        self.storageKey = storageKey
        load(currentLevel: currentLevel)
    }

    @discardableResult
    func observe(level: Int) -> GardenTransitionResult {
        update { $0.observe(level: level) }
    }

    @discardableResult
    func plant(_ species: GardenSpecies) -> GardenTransitionResult {
        update { $0.plant(species) }
    }

    @discardableResult
    func selectTree(_ species: GardenSpecies) -> GardenTransitionResult {
        update { $0.selectTree(species) }
    }

    @discardableResult
    func growSelectedTree() -> GardenTransitionResult {
        update { $0.growSelectedTree() }
    }

    @discardableResult
    func reload(currentLevel: Int) -> GardenTransitionResult {
        state = nil
        issue = nil
        load(currentLevel: currentLevel)
        return issue == nil ? .changed : .unavailable
    }

#if DEBUG
    @discardableResult
    func debugGrowAllPlantedTreesToMaximum() -> GardenTransitionResult {
        update { $0.debugGrowAllPlantedTreesToMaximum() }
    }

    @discardableResult
    func debugAddAction() -> GardenTransitionResult {
        update { $0.debugAddAction() }
    }

    @discardableResult
    func debugReset(currentLevel: Int) -> GardenTransitionResult {
        let freshState = GardenState.migrated(currentLevel: currentLevel)
        do {
            try persist(freshState)
            state = freshState
            issue = nil
            return .changed
        } catch {
            issue = .writeFailed
            return .unavailable
        }
    }

    @discardableResult
    func resetForTestMode() -> GardenTransitionResult {
        let freshState = GardenState.migrated(currentLevel: 1)
        guard freshState.isValid else {
            issue = .invalidState
            return .unavailable
        }

        do {
            try persist(freshState)
            state = freshState
            issue = nil
            return .changed
        } catch {
            issue = .writeFailed
            return .unavailable
        }
    }

    @discardableResult
    func debugDamageArchive(currentLevel: Int) -> GardenTransitionResult {
        do {
            try persistence.write(Data("invalid garden test archive".utf8), forKey: storageKey)
        } catch {
            issue = .writeFailed
            return .unavailable
        }
        return reload(currentLevel: currentLevel)
    }
#endif

    private func update(_ transform: (inout GardenState) -> GardenTransitionResult) -> GardenTransitionResult {
        guard issue == nil, var updated = state else { return .unavailable }
        let result = transform(&updated)
        guard result == .changed else { return result }
        guard updated.isValid else {
            issue = .invalidState
            return .unavailable
        }

        do {
            try persist(updated)
            state = updated
            return .changed
        } catch {
            issue = .writeFailed
            return .unavailable
        }
    }

    private func load(currentLevel: Int) {
        switch persistence.read(storageKey) {
        case .missing:
            let migrated = GardenState.migrated(currentLevel: currentLevel)
            guard migrated.isValid else {
                issue = .invalidState
                return
            }
            do {
                try persist(migrated)
                state = migrated
            } catch {
                issue = .writeFailed
            }

        case .invalid:
            issue = .damagedData

        case .data(let data):
            if let probe = try? JSONDecoder().decode(GardenVersionProbe.self, from: data),
               probe.schemaVersion != GardenState.currentSchemaVersion {
                issue = .unsupportedVersion
                return
            }

            guard let decoded = try? JSONDecoder().decode(GardenState.self, from: data),
                  decoded.isValid else {
                issue = .damagedData
                return
            }

            state = decoded
            _ = observe(level: currentLevel)
        }
    }

    private func persist(_ state: GardenState) throws {
        try persistence.write(try JSONEncoder().encode(state), forKey: storageKey)
    }
}

private struct GardenVersionProbe: Decodable {
    let schemaVersion: Int
}
