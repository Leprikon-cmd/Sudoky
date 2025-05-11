//  SettingsView.swift
//  Sudoky

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @AppStorage("selectedFont") private var selectedFont: String = "System"
    @AppStorage("playerMotto") private var playerMotto: String = ""

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
        .navigationTitle("Настройки")
    }

    private var hintsSection: some View {
        Section(header: Text("Подсказки")) {
            Toggle("Подсвечивать ошибки", isOn: $settings.highlightErrors)
            Toggle("Показать таймер", isOn: $settings.showTimer)
            Toggle("Показать жизни", isOn: $settings.showLives)
        }
    }

    private var fontsSection: some View {
        Section(header: Text("Шрифты")) {
            let fonts = ["System", "Pacifico", "CormorantGaramond", "Medieval", "OldStandard", "RuslanDisplay", "ShareTech"]

            Picker("Выбери шрифт", selection: $selectedFont) {
                ForEach(fonts, id: \.self) { fontName in
                    Text(fontName)
                        .font(FontManager.shared.font(size: 16))
                }
            }
        }
    }

    private var boardStyleSection: some View {
        Section(header: Text("Вид поля")) {
            Picker("Стиль", selection: $settings.selectedBoardStyle) {
                ForEach(settings.boardStyles, id: \.self) { option in
                    Text(option)
                }
            }
        }
    }

    private var themeSection: some View {
        Section(header: Text("Тема оформления")) {
            Picker("Тема", selection: $settings.selectedTheme) {
                ForEach(settings.themes, id: \.self) { theme in
                    Text(theme)
                }
            }
        }
    }

    private var languageSection: some View {
        Section(header: Text("Язык интерфейса")) {
            Picker("Язык", selection: $settings.language) {
                ForEach(settings.languages, id: \.self) { lang in
                    Text(lang.uppercased())
                }
            }
        }
    }

    private var soundSection: some View {
        Section(header: Text("Звук")) {
            Toggle("Включить звук", isOn: $settings.soundEnabled)
        }
    }

    private var timerSection: some View {
        Section(header: Text("Пользовательский таймер")) {
            Toggle("Ограничить по времени", isOn: $settings.timerMode)
            if settings.timerMode {
                Stepper(value: $settings.maxTime, in: 60...1800, step: 60) {
                    Text("Макс. время: \(settings.formattedMaxTime())")
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
