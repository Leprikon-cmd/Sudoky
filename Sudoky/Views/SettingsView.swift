//
//  SettingsView.swift
//  Sudoky
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @AppStorage("selectedFont") private var selectedFont: String = "System"
    @AppStorage("playerMotto") private var playerMotto: String = ""
    @State private var languageTrigger = false // ++ Триггер для перерисовки при смене языка
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов

    var body: some View {
        Form {
            hintsSection          // ++ Подсказки
            fontsSection          // ++ Шрифты + Цвет текста
            boardStyleSection     // ++ Стиль доски
            themeSection          // ++ Тема
            languageSection       // ++ Язык
            soundSection          // ++ Звук
            timerSection          // ++ Таймер
        }
        .navigationTitle(loc("settings.title")) // ++ Локализованный заголовок
        .environment(\.font, fontManager.font(size: 16)) //Шрифт
        .foregroundColor(Color("NavigationAccent")) // ← Цвет текста (задать в Assets)
    }

    // MARK: - Подсказки
    private var hintsSection: some View {
        Section(header: Text(loc("settings.hints"))) {
            Toggle(loc("settings.hints.showErrors"), isOn: $settings.highlightErrors)
            Toggle(loc("settings.hints.showTimer"), isOn: $settings.showTimer)
            Toggle(loc("settings.hints.showLives"), isOn: $settings.showLives)
        }
    }

    // MARK: - Шрифты + Цвет текста
    private var fontsSection: some View {
        Section(header: Text(loc("settings.fonts"))) {
            

            Picker(loc("settings.fonts.select"), selection: $selectedFont) {
                ForEach(fontManager.availableFonts, id: \.self) { fontName in
                    Text(fontName)
                        .textStyle(size: 16) // Размер, стиль и цвет шрифта.
                }
            }

            // ++ Цвет текста
            Picker(loc("settings.textColor.select"), selection: $settings.selectedTextColorName) {
                ForEach(settings.availableTextColors, id: \.self) { colorName in
                    Text(colorName.capitalized)
                        .foregroundColor(Color(colorName)) // ++ Цвет — сразу визуально виден
                }
            }
        }
    }

    // MARK: - Стиль доски
    private var boardStyleSection: some View {
        Section(header: Text(loc("settings.board"))) {
            Picker(loc("settings.board.style"), selection: $settings.selectedBoardStyle) {
                ForEach(settings.boardStyles, id: \.self) { option in
                    Text(option)
                }
            }
        }
    }

    // MARK: - Тема
    private var themeSection: some View {
        Section(header: Text(loc("settings.theme"))) {
            Picker(loc("settings.theme.select"), selection: $settings.selectedTheme) {
                ForEach(settings.themes, id: \.self) { theme in
                    Text(theme)
                }
            }
        }
    }

    // MARK: - Язык
    private var languageSection: some View {
        Section(header: Text(loc("settings.language"))) {
            Picker(loc("settings.language.select"), selection: $settings.language) {
                ForEach(settings.languages, id: \.self) { lang in
                    Text(lang.uppercased())
                }
            }
            .onChange(of: settings.language) { newLang in
                LocalizedBundle.setLanguage(newLang) // ++ Обновляем бандл
                languageTrigger.toggle()             // ++ Форсим перерисовку
            }
        }
    }

    // MARK: - Звук
    private var soundSection: some View {
        Section(header: Text(loc("settings.sound"))) {
            Toggle(loc("settings.sound"), isOn: $settings.soundEnabled)
                .onChange(of: settings.soundEnabled) { _, isOn in
                    if isOn {
                        MusicManager.shared.playBackgroundMusic("Aurnis_Luthael")
                    } else {
                        MusicManager.shared.stopMusic()
                    }
                    
                }
        }
    }

    // MARK: - Таймер
    private var timerSection: some View {
        Section(header: Text(loc("settings.timer"))) {
            Toggle(loc("settings.timer.enable"), isOn: $settings.timerMode)
            if settings.timerMode {
                Stepper(value: $settings.maxTime, in: 60...1800, step: 60) {
                    Text(loc("settings.timer.max")) + Text(": ") + Text(settings.formattedMaxTime())
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(FontManager.shared)
}
