//
//  FontManager.swift
//  Управление пользовательскими шрифтами в зависимости от настроек
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.
//

import SwiftUI

extension View {
    /// Универсальный стиль текста, автоматически берёт нужные зависимости из Environment
    func textStyle(size: CGFloat, customColor: Color? = nil) -> some View {
        modifier(AutoTextStyle(size: size, customColor: customColor))
    }
}

private struct AutoTextStyle: ViewModifier {
    let size: CGFloat
    let customColor: Color?
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var settings: SettingsManager

    func body(content: Content) -> some View {
        content
            .font(fontManager.font(size: size))
            .foregroundColor(customColor ?? settings.selectedTextColor)
            .offset(fontManager.offset(for: fontManager.selectedFontName)) // добавляем сдвиг
    }
}

class FontManager: ObservableObject {
    static let shared = FontManager()

    @AppStorage("selectedFont") private var selectedFont: String = "system"

    // + Список доступных шрифтов
    let availableFonts: [String] = [
        "System",           // Системный шрифт
        "Pacifico",         // Стильный рукописный
        "CormorantGaramond",// Классика
        "Medieval",         // Средневековый стиль
        "OldStandard",      // Стандарт с засечками
        "RuslanDisplay",    // Кириллический декоративный
        "ShareTech",        // Моноширинный
        "Skranji",          // Весёлый декоративный
        "UncialAntiqua",    // Исторический стиль
        "GreatVibes",       // Красивое
        "Deutsch Gothic"    // Готишное
    ]

    // Отдаёт имя выбранного шрифта
    var selectedFontName: String {
        selectedFont
    }

   
    // Сам шрифт по имени
    func font(size: CGFloat) -> Font {
        switch selectedFont {
        case "Pacifico":
            return Font.custom("Pacifico-Regular", size: size) // ✅
        case "CormorantGaramond":
            return Font.custom("CormorantGaramond-Regular", size: size) // ✅
        case "Medieval":
            return Font.custom("MedievalSharp", size: size) // ✅
        case "OldStandard":
            return Font.custom("OldStandardTT-Regular", size: size) // ✅
        case "RuslanDisplay":
            return Font.custom("RuslanDisplay", size: size) // ✅
        case "ShareTech":
            return Font.custom("ShareTechMono-Regular", size: size) // ✅
        case "UncialAntiqua":
            return Font.custom("UncialAntiqua-Regular", size: size) // ✅
        case "Skranji":
            return Font.custom("Skranji", size: size) // ✅
        case "GreatVibes":
            return Font.custom("GreatVibes-Regular", size: size) // ✅
        case "Deutsch Gothic":
            return Font.custom("DeutschGothic", size: size) // ✅
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
        case "RuslanDisplay": return CGSize(width: 0, height: 4)
        case "ShareTech": return CGSize(width: 0, height: 0)
        case "CormorantGaramond": return CGSize(width: 0, height: -3)
        case "UncialAntiqua": return CGSize(width: 0, height: 0) // + при необходимости поправишь вручную
        case "Skranji": return CGSize(width: 0, height: 0)
        default: return .zero
        }
    }
}
