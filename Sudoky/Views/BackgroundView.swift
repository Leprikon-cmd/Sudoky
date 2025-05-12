//
//  BackgroundView.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.

import SwiftUI

struct BackgroundView: View {
    @State private var imageName: String = "scroll1"
    
    var body: some View {
        GeometryReader { geo in
            Image(imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.2) // ← увеличивает изображение
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .ignoresSafeArea()
                .onAppear {
                    // Выбор случайного изображения при каждом появлении
                    let randomIndex = Int.random(in: 1...13)
                    imageName = "scroll\(randomIndex)"
                }
        }
    }
}
