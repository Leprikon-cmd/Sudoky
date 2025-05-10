//  SettingsView.swift
//  Sudoky

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Form {
            Section(header: Text("Подсказки")) {
                Toggle("Подсвечивать ошибки", isOn: $settings.highlightErrors)
                Toggle("Показать таймер", isOn: $settings.showTimer)
                Toggle("Показать жизни", isOn: $settings.showLives)
            }

            Section(header: Text("Стиль цифр")) {
                Picker("Шрифт", selection: $settings.selectedFont) {
                    ForEach(settings.fontOptions, id: \.self) { option in
                        Text(option)
                    }
                }
            }

            Section(header: Text("Вид поля")) {
                Picker("Стиль", selection: $settings.selectedBoardStyle) {
                    ForEach(settings.boardStyles, id: \.self) { option in
                        Text(option)
                    }
                }
            }

            Section(header: Text("Тема оформления")) {
                Picker("Тема", selection: $settings.selectedTheme) {
                    ForEach(settings.themes, id:\.self) { theme in
                        Text(theme)
                    }
                }
            }

            Section(header: Text("Язык интерфейса")) {
                Picker("Язык", selection: $settings.language) {
                    ForEach(settings.languages, id:\.self) { lang in
                        Text(lang.uppercased())
                    }
                }
            }

            Section(header: Text("Звук")) {
                Toggle("Включить звук", isOn: $settings.soundEnabled)
            }

            Section(header: Text("Пользовательский таймер")) {
                Toggle("Ограничить по времени", isOn: $settings.timerMode)
                if settings.timerMode {
                    Stepper(value: $settings.maxTime, in: 60...1800, step: 60) {
                        Text("Макс. время: \(settings.formattedMaxTime())")
                    }
                }
            }
        }
        .navigationTitle("Настройки")
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
}
