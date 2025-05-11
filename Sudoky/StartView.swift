import SwiftUI

struct StartView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @AppStorage("playerMotto") private var playerMotto: String = ""
    @State private var hasSave: Bool = false
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов

    @EnvironmentObject var playerProgress: PlayerProgressManager

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView() // ← всё сделает сам
                .ignoresSafeArea()
    
            
            VStack() {
                
                Spacer()
                
                // Облачко для мудрости — визуальный блок с возможностью ввода текста
                ZStack(alignment: .topLeading) {
                    
                // Фон облачка: закруглённый прямоугольник
                RoundedRectangle(cornerRadius: 16) // ← Радиус скругления углов "облачка". Больше — мягче форма, меньше — строже.
                    .fill(Color.white.opacity(0.3)) // ← Прозрачность фона: 0.3 — хорошо видно фон. Увеличь до 0.5 — будет плотнее.
                    .overlay(
                RoundedRectangle(cornerRadius: 16) // ← Должен совпадать с основным радиусом, чтобы обводка легла чётко по краям
                .stroke(Color.white.opacity(0.4), lineWidth: 1) // ← Цвет и толщина рамки. 0.4 — еле заметная, 1 — аккуратная толщина
                        )
                .shadow(radius: 3) // ← Мягкая тень под блоком. Radius = 3 делает лёгкий объём. Увеличь — будет сильнее «всплывать».
                // Поле ввода текста внутри облачка
                TextField("Впиши свою мудрость...", text: $playerMotto)
                        .padding() // ← Внутренний отступ текста от краёв рамки. Стандартное значение (обычно 16)
                        .foregroundColor(.black) // ← Цвет вводимого текста
                        .multilineTextAlignment(.leading) // ← Текст будет выравниваться по левому краю
                        .font(fontManager.font(size: 16)) // Размер и стиль шрифта.
                }
                // Размер блока облачка
                .frame(maxWidth: 300, minHeight: 20, maxHeight: 50) // ← Максимальная ширина = 300 поинтов, мин. высота = 20 мин. высота 50
                // Отступ снизу от следующего элемента
                .padding(.bottom, 10) // ← Отступ вниз. Если снизу элемент прилипает — увеличь.
                
                // Аватар мудреца (заглушка)
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .cornerRadius(16)
                    .overlay(
                        Text("🧘")
                            .font(.largeTitle)
                    )
                
                // Уровень и имя
                Text("Уровень \(playerProgress.currentLevel)")
                    .font(fontManager.font(size: 12)) // Размер и стиль шрифта.
                    .foregroundColor(.white)
                
                // Уровень и прогресс
                Text("Уровень: \(playerProgress.currentLevel)")
                    .font(fontManager.font(size: 12)) // Размер и стиль шрифта.
                
                ProgressView(
                    value: progressPercent(),
                    total: 1.0
                )
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .frame(width: 200)
                
                Text(String(format: "%.0f / %.0f XP", playerProgress.currentXP.truncatingRemainder(dividingBy: xpForNext()), xpForNext()))
                    .font(fontManager.font(size: 12)) // Размер и стиль шрифта.
                    .foregroundColor(.gray)

                // Кнопки
                Button("🧩 Новый Путь") {
                    path.append(Route.difficulty)
                }
                .buttonStyle(.borderedProminent)
                .font(fontManager.font(size: 16)) // Размер и стиль шрифта.

                Button("📜 Уровни познания") {
                    path.append(Route.stats)
                }
                .buttonStyle(.bordered)
                .font(fontManager.font(size: 16)) // Размер и стиль шрифта.

                if hasSave {
                    Button("🛤 Продолжить путь") {
                        path.append(Route.resume)
                    }
                    .buttonStyle(.bordered)
                    .font(fontManager.font(size: 16)) // Размер и стиль шрифта.
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center) // Выравнивание по центру
            .padding()

            // Кнопка настроек
            Button(action: {
                path.append(Route.settings)
            }) {
                Image(systemName: "book.fill")
                    .padding(12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()
        }
        .onAppear {
            hasSave = hasSavedGame()
            for family in UIFont.familyNames.sorted() {
                    print("🔤 \(family)")
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("   👉 \(name)")
                    }
                }
            }
        }

    private func progressPercent() -> Double {
        let current = playerProgress.currentXP
        let level = playerProgress.currentLevel
        let prevXP = Double(level * level * 10)
        let nextXP = Double((level + 1) * (level + 1) * 10)
        return (current - prevXP) / (nextXP - prevXP)
    }

    private func xpForNext() -> Double {
        let next = (playerProgress.currentLevel + 1)
        return Double(next * next * 10)
    }
    
    func hasSavedGame() -> Bool {
        GamePersistenceManager.shared.load() != nil
    }
}

#Preview {
    StartView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
    .environmentObject(PlayerProgressManager.shared)
}
