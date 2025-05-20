//
//  GameCustomAlert.swift
//  Sudoky
//
//  Created by Евгений Зотчик on 16.05.2025.
//
import SwiftUI

//Кнопка
struct AlertAction: Identifiable {
    let id = UUID()
    let title: String
    let handler: () -> Void
}

//Сообщение
struct GameCustomAlert: View {
    let title: String
    let message: String
    let actions: [AlertAction]
    @EnvironmentObject var fontManager: FontManager
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 📜 Пергамент на фоне
                Image("parchment_bg")
                    .resizable()
                    .scaledToFit() // ✅ сохраняет пропорции
                    .frame(height: UIScreen.main.bounds.height * 0.7) // 🔧 Растягиваем по высоте на 5–10%
                    .shadow(radius: 10)

                VStack(spacing: 16) {
                    Text(title)
                        .textStyle(size: 20) // Размер, стиль и цвет шрифта.
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(message)
                        .textStyle(size: 16) // Размер, стиль и цвет шрифта.
                        .multilineTextAlignment(.center)

                    VStack(spacing: 8) {
                        ForEach(actions) { action in
                            Button(action.title) {
                                isPresented = false // ✅ Закрыть алерт
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            action.handler()
                                    }
                                }
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                            .textStyle(size: 16) // Размер, стиль и цвет шрифта.
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
                .frame(width: geo.size.width * 0.7)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        .edgesIgnoringSafeArea(.all)
        .transition(.scale)
    }
}
