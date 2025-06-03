import SwiftUI

struct StartView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @AppStorage("playerMotto") private var playerMotto: String = ""
    @AppStorage("playerName") private var playerName: String = ""
    @State private var hasSave: Bool = false
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    @EnvironmentObject var languageManager: LanguageManager // Локализация
    @EnvironmentObject var playerProgress: PlayerProgressManager
    @EnvironmentObject var settings: SettingsManager // настройки
    @FocusState private var isMottoFocused: Bool // Фокус для поля мудрости

    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView() // Фон
                .ignoresSafeArea()
            
            // Кнопка настроек
            HStack {
                Spacer()
                Button(action: {
                    path.append(Route.settings)
                }) {
                    Text("📜") // Кнопка настройки
                        .font(.system(size: 40))
                        .padding(6)                          // отступ внутри "круга"
                        .clipShape(Circle())                  // форма — круг
                }
                .padding(.trailing, 35) // отступ справа
                .padding(.top, 25) // отступ сверху
            }
            
            // Оборачиваем всё содержимое в ZStack с фиксированным фоном
                ZStack(alignment: .topLeading) {
                    // Весь фон для тапа — за пределами облачка
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isMottoFocused = false
                        }
                VStack {
                    Spacer()
                    
                    // 🌥️ Облачко для ввода мудрой мысли с поддержкой переноса и плейсхолдером
                    ZStack(alignment: .topLeading) {
                        // 🖼️ Фон и рамка
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("TextColor").opacity(0)) // Прозрачный фон
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("Line").opacity(0.8), lineWidth: 1) // Рамка
                            )
                            .shadow(radius: 3) // Мягкая тень

                        // 💬 Плейсхолдер
                        if playerMotto.isEmpty {
                            Text(loc("start.placeholder.motto"))
                                .foregroundColor(.gray)
                                .padding(10)
                                .font(fontManager.font(size: 14)) // ✅ Шрифт из FontManager
                        }

                        // ✍️ Ввод многострочного текста
                        TextEditor(text: $playerMotto)
                            .padding(3)
                            .foregroundColor(.black)
                            .font(fontManager.font(size: 14)) // ✅ Шрифт из FontManager
                            .scrollContentBackground(.hidden) // 🩹 Убираем фон scrollView внутри TextEditor
                            .background(Color.clear)
                            .focused($isMottoFocused) // 👈 Привязка фокуса
                    }
                    .frame(maxWidth: 350, minHeight: 60, maxHeight: 60)
                    .padding(.bottom, 3)
                    
                    // Аватар мудреца
                    Image("sage_50")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                    
                    
                    // 💬 Имя и уровень — имя вводится, уровень отображается справа
                    ZStack {
                        HStack(spacing: 4) {
                            TextField(loc("start.enterName"), text: $playerName)
                                .textStyle(size: 20)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100) // 🔧 ширина поля

                            Text("— \(String(format: loc("start.levelLong"), playerProgress.currentLevel))")
                                .textStyle(size: 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center) // центрируем визуально
                    
                    // ✅ Прогрессбар (путь мудреца)
                    ProgressView(value: progressPercent(), total: 1) // передаём текущий и максимальный прогресс
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: .green) // Цвет индикатора (зелёный)
                        )
                        .frame(width: 200, height: 50) // Ширина/Высота
                        .padding(.vertical, 2) // Отступ по горизонту
                    
                    // Текущий XP / нужный XP
                    Text(String(format: loc("start.xpProgress"),
                                playerProgress.currentXP.truncatingRemainder(dividingBy: xpForNext()),
                                xpForNext()
                               ))
                    .textStyle(size: 16)
                    .foregroundColor(.gray)
                    
                    // Кнопки — одинаковая ширина
                    VStack(spacing: 12) {
                        Button(loc("start.newGame")) {
                            path.append(Route.difficulty)
                        }
                        .textStyle(size: 24)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        
                        Button(loc("start.stats")) {
                            path.append(Route.stats)
                        }
                        .textStyle(size: 24)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        
                        if hasSave {
                            Button(loc("start.resume")) {
                                path.append(Route.resume)
                            }
                            .textStyle(size: 24)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .ignoresSafeArea(.keyboard)
            }
            .frame(height: 700) // ✅ гарантированная высота всего контента
            .padding(.top, 100) // ← Смещение карточки ближе к низу
        }
        .onAppear {
            //  for name in UIFont.fontNames(forFamilyName: family) {print("🔹 \(name)")}} // Проверка названий шрифтов (если понадобится)
            // 🎵 Запускаем музыку только если она не играет
                if settings.soundEnabled && !MusicManager.shared.isMusicPlaying {
                    MusicManager.shared.playBackgroundMusic("Aurnis_Luthael")
                }

            
            // 💾 Проверяем наличие сохранённой игры
            hasSave = hasSavedGame()
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

