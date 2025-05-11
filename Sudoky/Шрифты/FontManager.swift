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

    /// Возвращает нужный шрифт с заданным размером
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
}

