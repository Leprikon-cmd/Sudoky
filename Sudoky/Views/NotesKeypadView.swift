//
//  NotesKeypadView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.
//
import SwiftUI

struct NotesKeypadView: View {
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    var onNoteTap: (Int) -> Void
    

    private let numbers = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ]

    var body: some View {
        VStack(spacing: 6) { // Вертикально: расстояние между строками
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 6) { // Горизонтально: расстояние между кнопками
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            onNoteTap(number)
                        }) {
                            Text("\(number)")
                                .foregroundColor((Color("ButtonPrimary")))
                                .frame(width: 40, height: 40) // Меньше чем у основной
                                .background(Color("CellBackground").opacity(0.8))
                                .cornerRadius(8)
                                .font(fontManager.font(size: 14)) // Размер и стиль шрифта.
                        }
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}
