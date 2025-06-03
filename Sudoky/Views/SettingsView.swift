//
//  SettingsView.swift
//  Sudoky
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var fontManager: FontManager

    @AppStorage("selectedFont") private var selectedFont: String = "System"
    @AppStorage("playerMotto") private var playerMotto: String = ""
    @State private var languageTrigger = false // ++ Триггер для перерисовки при смене языка
    @State private var showAboutSheet = false

    var body: some View {
        Form {
            fontsSection          // ++ Шрифты + Цвет текста
            languageSection       // ++ Язык
            soundSection          // ++ Звук
            aboutSection          // ++ О проекте
        }
        .navigationTitle(loc("settings.title")) // ++ Локализованный заголовок
        .environment(\.font, fontManager.font(size: 16))
        .foregroundColor(Color("NavigationAccent")) // ← Цвет текста (задать в Assets)
    }

    // MARK: - Шрифты + Цвет текста
    private var fontsSection: some View {
        Section(header: Text(loc("settings.fonts"))) {
            Picker(loc("settings.fonts.select"), selection: $selectedFont) {
                ForEach(fontManager.availableFonts, id: \.self) { fontName in
                    Text(fontName)
                        .textStyle(size: 16)
                }
            }

            Picker(loc("settings.textColor.select"), selection: $settings.selectedTextColorName) {
                ForEach(settings.availableTextColors, id: \.self) { colorName in
                    Text(colorName.capitalized)
                        .foregroundColor(Color(colorName))
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
                LocalizedBundle.setLanguage(newLang)
                fontManager.updateAvailableFonts(for: newLang)
                languageTrigger.toggle()
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
    // MARK: - О проекте
    private var aboutSection: some View {
        Section {
            Button("✨ " + loc("settings.about")) {
                showAboutSheet = true
            }
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutProjectSheet()
        }
    }
}


#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(FontManager.shared)
}
