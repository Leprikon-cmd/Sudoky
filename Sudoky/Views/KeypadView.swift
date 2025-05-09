//  KeypadView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 09.05.2025.

import SwiftUI

struct KeypadView: View {
    var onNumberTap: (Int) -> Void

    let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 9), spacing: 8) {
            ForEach(numbers, id: \.self) { number in
                Button(action: {
                    onNumberTap(number)
                }) {
                    Text("\(number)")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .font(.title2)
                }
            }
        }
        .padding()
    }
}
