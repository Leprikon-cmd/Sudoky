//
//  LanguageManager.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 16.05.2025.
// 🗂 LanguageManager.swift

import SwiftUI

class LanguageManager: ObservableObject {
    @AppStorage("language") var language: String = "ru" {
        didSet {
            LocalizedBundle.setLanguage(language)
            objectWillChange.send() // 🔁 сообщаем всем, кто подписан
        }
    }

    init() {
        LocalizedBundle.setLanguage(language)
    }
}

