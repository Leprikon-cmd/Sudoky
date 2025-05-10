import SwiftUI

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case новичок, ученик, мастер, сенсей, dokushin
    var id: String { self.rawValue }
    var lives: Int {
        switch self {
        case .новичок: return 10
        case .ученик: return 6
        case .мастер: return 4
        case .сенсей: return 3
        case .dokushin: return 1
        }
    }
}

struct DifficultyPickerView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath

    var body: some View {
        List(Difficulty.allCases) { difficulty in
            Button(difficulty.rawValue.capitalized) {
                path.append(Route.game(difficulty))
            }
        }
        .navigationTitle("Выбор сложности")
    }
}

#Preview {
    DifficultyPickerView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
}
