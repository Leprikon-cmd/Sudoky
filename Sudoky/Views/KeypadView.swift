//
//  NotesKeypadView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.
//
import SwiftUI

struct KeypadView: View {
    @EnvironmentObject var fontManager: FontManager // Менеджер шрифтов
    var onNumberTap: (Int) -> Void
    var selectedValue: Int? // <- текущая цифра в выбранной ячейке

    let numbers = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
    ]

    var body: some View {
        VStack(spacing: 6) { // Вертикально: расстояние между строками
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 6) { // Горизонтально: расстояние между кнопками
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            // Если нажали повторно ту же цифру — очищаем
                            if selectedValue == number {
                            onNumberTap(0)
                            } else {
                            onNumberTap(number)
                            }
                            }) {
                            Text(number == 0 ? "⌫" : "\(number)")
                                .frame(width: 40, height: 40) // [2] Размер кнопки
                                .background(Color.green.opacity(0.2)) // [3] Цвет фона
                                .cornerRadius(6) // [4] Скругление углов
                                .font(.title2) // [1] Размер шрифта
                        }
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}
