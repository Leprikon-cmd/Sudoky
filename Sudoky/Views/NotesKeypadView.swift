//
//  NotesKeypadView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.
//
import SwiftUI

struct NotesKeypadView: View {
    var onNoteTap: (Int) -> Void

    private let numbers = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            onNoteTap(number)
                        }) {
                            Text("\(number)")
                                .frame(width: 30, height: 30) // Меньше чем у основной
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                                .font(.caption) // Меньший шрифт
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
