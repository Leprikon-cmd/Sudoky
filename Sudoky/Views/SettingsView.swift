
//  SettingsView.swift
//  Sudoky

import SwiftUI

struct SettingsView: View {
    @State private var highlightErrors = true
    @State private var selectedFont = "Стандартный"
    @State private var selectedBoardStyle = "Классика"

    let fontOptions = ["Стандартный", "Моноширинный", "Рукописный"]
    let boardStyles = ["Классика", "Минимал", "Япония"]

    var body: some View {
        Form {
            Section(header: Text("Подсказки")) {
                Toggle("Подсвечивать ошибки", isOn: $highlightErrors)
            }

            Section(header: Text("Стиль цифр")) {
                Picker("Шрифт", selection: $selectedFont) {
                    ForEach(fontOptions, id: \.self) { option in
                        Text(option)
                    }
                }
            }

            Section(header: Text("Вид поля")) {
                Picker("Стиль", selection: $selectedBoardStyle) {
                    ForEach(boardStyles, id: \.self) { option in
                        Text(option)
                    }
                }
            }
        }
        .navigationTitle("Настройки")
    }
}

#Preview {
    SettingsView()
}
