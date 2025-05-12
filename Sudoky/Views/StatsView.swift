import SwiftUI

struct StatsView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @State private var selectedIndex = 0
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView() // Фон
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(Difficulty.allCases.enumerated()), id: \.offset) { index, difficulty in
                        if let entry = statsManager.stats[difficulty] {
                            VStack(alignment: .leading, spacing: 10) {
                                // Название уровня сложности
                                    Text(difficulty.rawValue.capitalized)
                                    .font(fontManager.font(size: 30)) // Размер и стиль шрифта.
                                        .bold()
                                        .padding(.bottom)

                                    // Статистика по этому уровню
                                    Text("Сыграно игр: \(entry.played)")
                                    Text("Побед: \(entry.wins)")
                                    Text("Лучшее время: \(formatTime(entry.bestTime))")
                                    Text("Серия побед: \(entry.winStreak) / рекорд: \(entry.maxWinStreak)")
                                    Text("Побед без ошибок: \(entry.flawlessStreak) / рекорд: \(entry.maxFlawlessStreak)")
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
                
                Button("Сбросить статистику") {
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
