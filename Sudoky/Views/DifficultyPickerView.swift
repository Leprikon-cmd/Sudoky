import SwiftUI

// MARK: - Уровни сложности
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case новичок, ученик, мастер, сенсей, dokushin
    
    var id: String { self.rawValue }
    
    /// Количество жизней в зависимости от уровня
    var lives: Int {
        switch self {
        case .новичок: return 10
        case .ученик:  return 6
        case .мастер:  return 4
        case .сенсей:  return 3
        case .dokushin: return 1
        }
    }
}

// MARK: - Экран выбора сложности
struct DifficultyPickerView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView() // ← наш фоновый рисунок (рандомный)
                .ignoresSafeArea()

            List(Difficulty.allCases) { difficulty in
                Button(action: {
                    path.append(Route.game(difficulty))
                }) {
                    Text(difficulty.rawValue.capitalized)
                        .font(.custom("Pacifico", size: 24))                    // ← Размер шрифта
                        .foregroundColor(.primary)        // ← Цвет текста (адаптивный)
                        .frame(maxWidth: .infinity)       // ← Центрируем по ширине
                        .multilineTextAlignment(.center)  // ← Центрируем текст
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2)) // ← Фон кнопки
                        )
                }
                .listRowBackground(Color.clear)           // ← Строка без фона
            }
            .scrollContentBackground(.hidden)             // ← Убираем фон всего списка
            .background(Color.clear)                      // ← Подстраховка
            .navigationTitle("Выбор сложности")
        }
    }
}

#Preview {
    DifficultyPickerView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
}
