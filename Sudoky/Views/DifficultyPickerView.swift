import SwiftUI

// MARK: - Уровни сложности
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case новичок, ученик, мастер, сенсей, dokushin
    
    var id: String { self.rawValue }

    var localizedName: String {
        loc("difficulty.\(self.rawValue)") // ✅ Единый универсальный ключ
    }

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
    @EnvironmentObject var languageManager: LanguageManager // Локализация

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView() // ← наш фоновый рисунок (рандомный)
                .ignoresSafeArea()
            
            // ⬇️ ТРИГГЕР НА ПЕРЕРИСОВКУ
                    let _ = languageManager.language // ++ Обновит View при смене языка

            List(Difficulty.allCases) { difficulty in
                Button(action: {
                    path.append(Route.game(difficulty))
                }) {
                    Text(difficulty.localizedName) // ++ Локализованное название уровня
                        .font(fontManager.font(size: 24)) // Размер и стиль шрифта.
                        .foregroundColor((Color("ButtonPrimary")))        // ← Цвет текста (адаптивный)
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
            .navigationTitle(loc("difficulty.title")) // ++ Локализованный заголовок
        }
    }
}

#Preview {
    DifficultyPickerView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
}
