//
//  FontManager.swift
//  Управление пользовательскими шрифтами в зависимости от настроек
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.
//

import SwiftUI

class FontManager: ObservableObject {
    static let shared = FontManager()

    @AppStorage("selectedFont") private var selectedFont: String = "system"

    // Список доступных шрифтов (для Picker)
    let availableFonts: [String] = [
        "system",
        "Pacifico",
        "CormorantGaramond",
        "Medieval",
        "OldStandard",
        "RuslanDisplay",
        "ShareTech"
    ]

    // Отдаёт имя выбранного шрифта
    var selectedFontName: String {
        selectedFont
    }

    // Основная функция — отдает стилизованный Text с учётом шрифта и offset
    func styledText(_ string: String, size: CGFloat) -> some View {
        let offset = offset(for: selectedFont)
        return Text(string)
            .font(font(size: size))
            .offset(offset)
    }

    // Сам шрифт по имени
    func font(size: CGFloat) -> Font {
        switch selectedFont {
        case "Pacifico":
            return Font.custom("Pacifico-Regular", size: size)
        case "CormorantGaramond":
            return Font.custom("CormorantGaramond-Regular", size: size)
        case "Medieval":
            return Font.custom("MedievalSharp-Regular", size: size)
        case "OldStandard":
            return Font.custom("OldStandardTT-Regular", size: size)
        case "RuslanDisplay":
            return Font.custom("RuslanDisplay-Regular", size: size)
        case "ShareTech":
            return Font.custom("ShareTechMono-Regular", size: size)
        default:
            return Font.system(size: size)
        }
    }

    // Смещения для конкретных шрифтов
    func offset(for font: String) -> CGSize {
        switch font {
        case "Pacifico": return CGSize(width: 0, height: -3)
        case "OldStandard": return CGSize(width: 0, height: 2)
        case "Medieval": return CGSize(width: 0, height: 1)
        case "RuslanDisplay": return CGSize(width: 0, height: -2)
        case "ShareTech": return CGSize(width: 0, height: 0)
        case "CormorantGaramond": return CGSize(width: 0, height: -3)
        default: return .zero
        }
    }
}
