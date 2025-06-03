//
//  SettingsManager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Подсказки
    @AppStorage("highlightErrors") var highlightErrors: Bool = true
    @AppStorage("showTimer") var showTimer: Bool = true
    @AppStorage("showLives") var showLives: Bool = true

    // MARK: - Визуальные стили
    @AppStorage("selectedFont") var selectedFont: String = "Стандартный"
    @AppStorage("selectedBoardStyle") var selectedBoardStyle: String = "Классика"
    @AppStorage("selectedTheme") var selectedTheme: String = "Светлая"

    @Published var musicEnabled: Bool = true // Музыка

    // ++ Цвет текста
    @AppStorage("selectedTextColorName") var selectedTextColorName: String = "white" // Сохраняем цвет по имени

    let availableTextColors: [String] = [
        "TextColor"
    ]

    var selectedTextColor: Color {
        Color(selectedTextColorName)
    }

    init() {
        registerDefaults()
        fontManager.updateAvailableFonts(for: language) // ✅ Обновляем шрифты при инициализации
    }

    private func registerDefaults() {
        let defaults: [String: Any] = [
            "selectedTextColorName": "TextColor",
            "selectedFont": "Pacifico"
        ]
        UserDefaults.standard.register(defaults: defaults)
    }

    // MARK: - Звук и язык
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("language") var language: String = Locale.current.language.languageCode?.identifier ?? "ru" {
        didSet {
            fontManager.updateAvailableFonts(for: language) // ✅ Обновляем доступные шрифты при смене языка
        }
    }

    // MARK: - Таймер
    @AppStorage("timerMode") var timerMode: Bool = false
    @AppStorage("maxTime") var maxTime: Int = 600

    // MARK: - Варианты выбора
    let fontOptions = ["Стандартный", "Моноширинный", "Рукописный"]
    let boardStyles = ["Классика", "Минимал", "Япония"]
    let themes = ["Светлая", "Тёмная", "Системная"]
    let languages = ["ru", "en"]

    // MARK: - Форматирование времени
    func formattedMaxTime() -> String {
        let minutes = maxTime / 60
        let seconds = maxTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Менеджер шрифтов (синглтон)
    private let fontManager = FontManager.shared
}
