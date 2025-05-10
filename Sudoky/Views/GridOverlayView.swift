//
//  GridOverlayView.swift
//  Sudoky
//  Отвечает за сетки и оформление блоков
//  Created by Евгений Зотчик on 10.05.2025.
//
import SwiftUI

struct GridOverlayView: View {
    let gridSize: CGFloat

    var body: some View {
        ZStack {
            // Горизонтальные линии
            ForEach(0...9, id: \.self) { i in
                Rectangle()
                    .fill(i % 3 == 0 ? Color.black : Color.gray)
                    .frame(height: i % 3 == 0 ? 2 : 0.5)
                    .offset(y: CGFloat(i) * gridSize / 9 - gridSize / 2)
            }

            // Вертикальные линии
            ForEach(0...9, id: \.self) { i in
                Rectangle()
                    .fill(i % 3 == 0 ? Color.black : Color.gray)
                    .frame(width: i % 3 == 0 ? 2 : 0.5)
                    .offset(x: CGFloat(i) * gridSize / 9 - gridSize / 2)
            }
        }
        .frame(width: gridSize, height: gridSize)
    }
}

