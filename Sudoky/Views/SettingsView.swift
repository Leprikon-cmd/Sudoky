//  SettingsView.swift
//  Sudoky

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @AppStorage("selectedFont") private var selectedFont: String = "System"
    @AppStorage("playerMotto") private var playerMotto: String = ""
    @State private var languageTrigger = false // + триггер для перерисовки


    var body: some View {
        Form {
            hintsSection
            fontsSection
            boardStyleSection
            themeSection
            languageSection
            soundSection
            timerSection
        }
        .navigationTitle(loc("settings.title")) // + Заголовок настраивается через локализацию
    }

    private var hintsSection: some View {
        Section(header: Text(loc("settings.hints"))) {
            Toggle(loc("settings.hints.showErrors"), isOn: $settings.highlightErrors)
            Toggle(loc("settings.hints.showTimer"), isOn: $settings.showTimer)
            Toggle(loc("settings.hints.showLives"), isOn: $settings.showLives)
        }
    }

    private var fontsSection: some View {
        Section(header: Text(loc("settings.fonts"))) {
            let fonts = ["System", "Pacifico", "CormorantGaramond", "Medieval", "OldStandard", "RuslanDisplay", "ShareTech"]

            Picker(loc("settings.fonts.select"), selection: $selectedFont) {
                ForEach(fonts, id: \.self) { fontName in
                    Text(fontName)
                        .font(FontManager.shared.font(size: 16))
                }
            }
        }
    }

    private var boardStyleSection: some View {
        Section(header: Text(loc("settings.board"))) {
            Picker(loc("settings.board.style"), selection: $settings.selectedBoardStyle) {
                ForEach(settings.boardStyles, id: \.self) { option in
                    Text(option)
                }
            }
        }
    }

    private var themeSection: some View {
        Section(header: Text(loc("settings.theme"))) {
            Picker(loc("settings.theme.select"), selection: $settings.selectedTheme) {
                ForEach(settings.themes, id: \.self) { theme in
                    Text(theme)
                }
            }
        }
    }

    private var languageSection: some View {
        Section(header: Text(loc("settings.language"))) {
            Picker(loc("settings.language.select"), selection: $settings.language) {
                ForEach(settings.languages, id: \.self) { lang in
                    Text(lang.uppercased())
                }
            }
            .onChange(of: settings.language) { newLang in
                LocalizedBundle.setLanguage(newLang) // ✅ переключаем локаль
                languageTrigger.toggle()             // ✅ форсим перерисовку
            }
        }
    }

    private var soundSection: some View {
        Section(header: Text(loc("settings.sound"))) {
            Toggle(loc("settings.sound.enable"), isOn: $settings.soundEnabled)
        }
    }

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
