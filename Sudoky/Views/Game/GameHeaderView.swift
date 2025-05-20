//
//  GameHeaderView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 10.05.2025.

import SwiftUI

struct GameHeaderView: View {
    let difficulty: Difficulty        // ← уровень сложности
    let timeElapsed: TimeInterval    // ← сколько прошло времени
    let livesRemaining: Int          // ← сколько осталось жизней
    @EnvironmentObject var languageManager: LanguageManager // Локализация
    @EnvironmentObject var fontManager: FontManager   // Менеджер шрифтов

    var body: some View {
        VStack(spacing: 4) {
            // + Сложность (в формате "Сложность: Мастер" / "Difficulty: Master")
            Text(String(format: loc("header.difficulty"), difficulty.localizedName))
                .textStyle(size: 14) // Размер, стиль и цвет шрифта.

            // + Жизни (🔔)
            HStack(spacing: 4) {
                ForEach(0..<livesRemaining, id: \.self) { _ in
                    Text("🔔")
                        .foregroundColor(.red)
                }
            }

            // + Таймер в секундах
            Text(String(format: loc("header.time"), Int(timeElapsed)))
                .textStyle(size: 14) // Размер, стиль и цвет шрифта.
        }
        .padding(.bottom, 8)
    }
}
