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

    var body: some View {
        VStack(spacing: 4) {
            // Название сложности
            Text("Сложность: \(difficulty.rawValue.capitalized)")
                .font(.headline)

            // Сердечки (жизни)
            HStack(spacing: 4) {
                ForEach(0..<livesRemaining, id: \.self) { _ in
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }

            // Время
            Text("Время: \(Int(timeElapsed)) сек")
                .font(.subheadline)
        }
        .padding(.bottom, 8)
    }
}
