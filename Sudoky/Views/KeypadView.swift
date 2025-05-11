import SwiftUI

struct KeypadView: View {
    var onNumberTap: (Int) -> Void

    // Новая структура клавиатуры
    let numbers = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
        [0] // нижний ряд с нулём
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            onNumberTap(number)
                        }) {
                            Text(number == 0 ? "⌫" : "\(number)")
                                .frame(width: 30, height: 30)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                                .font(.title2)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
