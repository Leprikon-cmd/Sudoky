import SwiftUI

struct StatsView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @State private var selectedIndex = 0
    @State private var showResetAlert = false // Показывать алерт?
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    @EnvironmentObject var languageManager: LanguageManager // Локализация

    var body: some View {
        let _ = languageManager.language
        ZStack(alignment: .top) {
            BackgroundView() // Фон
                .ignoresSafeArea()

            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(Difficulty.allCases.enumerated()), id: \.offset) { index, difficulty in
                        if let entry = statsManager.stats[difficulty] {
                            
                            ZStack {
                                // 🎨 Картинка-фон по индексу (фикс. размер)
                                Image(difficulty.parchmentImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 650) // ✅ фиксированная высота
                                    .padding(.horizontal, 2)

                                VStack(alignment: .leading, spacing: 10) {
                                    // ++ Название уровня сложности
                                    Text(difficulty.localizedName) // Локализованное название уровня сложности
                                        .textStyle(size: 30) // + Размер и стиль шрифта
                                        .bold()
                                        .padding(.bottom)

                                    // ++ Статистика по этому уровню
                                    Text(loc("stats.gamesPlayed") + ": \(entry.played)")
                                    Text(loc("stats.wins") + ": \(entry.wins)")
                                    Text(loc("stats.bestTime") + ": \(formatTime(entry.bestTime))")
                                    Text(loc("stats.winStreak") + ": \(entry.winStreak) / \(loc("stats.record")): \(entry.maxWinStreak)")
                                    Text(loc("stats.flawlessWins") + ": \(entry.flawlessStreak) / \(loc("stats.record")): \(entry.maxFlawlessStreak)")
                                }
                                .foregroundColor(Color("CardTextColor")) // ← Цвет текста (задать в Assets)
                                .textStyle(size: 16) // Размер и стиль шрифта.
                                .padding()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20) // ← Смещение карточки ближе к низу
                            .tag(index)        // ← Связь с индексом в PageTabView
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 650) // ⬅️ Высота всей области карточек

                // ++ Кнопка сброса
                Button(action: {
                    showResetAlert = true // Показываем подтверждение
                }) {
                    Text(loc("stats.reset"))
                        .font(fontManager.font(size: 18))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .padding(.top, 20)
                .listRowBackground(Color.clear) // ✅ обязательно
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    // 🔙 Кастомная кнопка «Назад» (заменяет стандартную)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            path.removeLast()
                        }) {
                            Image("wooden_back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 40)
                        }
                    }
                }
            }
            .alert(loc("stats.resetConfirmTitle"), isPresented: $showResetAlert) {
                Button(loc("common.yes"), role: .destructive) {
                    statsManager.resetStats()
                }
                Button(loc("common.no"), role: .cancel) { }
            } message: {
                Text(loc("stats.resetConfirmMessage"))
            }
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
