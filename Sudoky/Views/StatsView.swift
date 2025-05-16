import SwiftUI

struct StatsView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @State private var selectedIndex = 0
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    @EnvironmentObject var languageManager: LanguageManager // Локализация

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView() // Фон
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(Difficulty.allCases.enumerated()), id: \.offset) { index, difficulty in
                        if let entry = statsManager.stats[difficulty] {
                            
                            VStack(alignment: .leading, spacing: 10) {
                                // ++ Название уровня сложности
                                Text(difficulty.localizedName) // ← если у тебя есть computed property `localizedName`, иначе вернись к rawValue и переводи
                                    .font(fontManager.font(size: 30)) // + Размер и стиль шрифта
                                    .bold()
                                    .padding(.bottom)

                                // ++ Статистика по этому уровню
                                Text(loc("stats.gamesPlayed") + ": \(entry.played)")
                                Text(loc("stats.wins") + ": \(entry.wins)")
                                Text(loc("stats.bestTime") + ": \(formatTime(entry.bestTime))")
                                Text(loc("stats.winStreak") + ": \(entry.winStreak) / \(loc("stats.record")): \(entry.maxWinStreak)")
                                Text(loc("stats.flawlessWins") + ": \(entry.flawlessStreak) / \(loc("stats.record")): \(entry.maxFlawlessStreak)")

                                // ++ Кнопка сброса
                                Button(loc("stats.reset")) {
                                    statsManager.resetStats()
                                }
                                .foregroundColor(.red)
                                .padding(.top, 20)
                            }
                            
                .foregroundColor(Color("CardTextColor")) // ← Цвет текста (задать в Assets)
                .font(fontManager.font(size: 18)) // Размер и стиль шрифта.
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color("NavigationAccent")            // ← Цвет фона карточки
                    .opacity(0.5)                        // ← Прозрачность (0.0–1.0)
                    .blur(radius: 0.5)                   // ← Эффект размытия, можно убрать
                    .cornerRadius(16)                    // ← Скругление углов
                                )
                    .padding(.horizontal, 24)           // ← Отступы по бокам от экрана
                    .padding(.top, 100)              // ← Смещение карточки ближе к низу
                    .tag(index)                         // ← Связь с индексом в PageTabView
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 500)
                
                Button(loc("stats.reset")) {
                    statsManager.resetStats()
                }
                .foregroundColor(.red)
                .padding(.top, 20)
            }
            .padding()
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        guard time > 0 else { return "–" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    StatsView(
        statsManager: StatsManager(),
        path: .constant(NavigationPath())
    )
}
