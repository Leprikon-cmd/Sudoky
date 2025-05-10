//
//  Settings Manager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.


import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    // MARK: - Подсказки
    @AppStorage("highlightErrors") var highlightErrors: Bool = true
    @AppStorage("showTimer") var showTimer: Bool = true
    @AppStorage("showLives") var showLives: Bool = true

    // MARK: - Визуальные стили
    @AppStorage("selectedFont") var selectedFont: String = "Стандартный"
    @AppStorage("selectedBoardStyle") var selectedBoardStyle: String = "Классика"
    @AppStorage("selectedTheme") var selectedTheme: String = "Светлая"

    // MARK: - Звук и язык
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("language") var language: String = Locale.current.language.languageCode?.identifier ?? "ru"
    // MARK: - Таймер
    @AppStorage("timerMode") var timerMode: Bool = false // true — пользователь сам ставит лимит
    @AppStorage("maxTime") var maxTime: Int = 600 // в секундах (по умолчанию 10 мин)

    // MARK: - Варианты выбора
    let fontOptions = ["Стандартный", "Моноширинный", "Рукописный"]
    let boardStyles = ["Классика", "Минимал", "Япония"]
    let themes = ["Светлая", "Тёмная", "Системная"]
    let languages = ["ru", "en", "ja"]

    // MARK: - Форматирование времени
    func formattedMaxTime() -> String {
        let minutes = maxTime / 60
        let seconds = maxTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
