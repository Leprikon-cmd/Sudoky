//
//  FontManager.swift
//  Управление пользовательскими шрифтами в зависимости от настроек и языка
//  Sudoky
//
//  Created by Евгений Зотчик on 11.05.2025.
//

import SwiftUI
import UIKit
import CoreText

// ✅ Быстрый доступ к стилю текста с автоматическим шрифтом и цветом
extension View {
    func textStyle(size: CGFloat, customColor: Color? = nil) -> some View {
        modifier(AutoTextStyle(size: size, customColor: customColor))
    }

    func textStyle(size: CGFloat, color: Color) -> some View {
        modifier(FixedTextStyle(size: size, color: color))
    }
}

// ✅ Авто-стиль: шрифт и цвет берутся из настроек
private struct AutoTextStyle: ViewModifier {
    let size: CGFloat
    let customColor: Color?
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var settings: SettingsManager

    func body(content: Content) -> some View {
        content
            .font(fontManager.font(size: size))
            .foregroundColor(customColor ?? settings.selectedTextColor)
            .offset(fontManager.offset(for: fontManager.selectedFontName))
    }
}

// ✅ Фиксированный цвет, шрифт из настроек
private struct FixedTextStyle: ViewModifier {
    let size: CGFloat
    let color: Color
    @EnvironmentObject var fontManager: FontManager

    func body(content: Content) -> some View {
        content
            .font(fontManager.font(size: size))
            .foregroundColor(color)
    }
}

// ✅ Главный менеджер шрифтов
class FontManager: ObservableObject {
    static let shared = FontManager()

    @AppStorage("selectedFont") private var selectedFont: String = "System"
    @Published var availableFonts: [String] = []

    /// Полный список всех шрифтов проекта
    private let allFonts: [String] = [
        "System",
        "Pacifico",
        "CormorantGaramond",
        "Medieval",
        "OldStandard",
        "RuslanDisplay",
        "ShareTech",
        "Skranji",
        "UncialAntiqua",
        "GreatVibes",
        "Deutsch Gothic"
    ]

    init() {
        updateAvailableFonts(for: Locale.current.language.languageCode?.identifier ?? "en")
    }

    // MARK: - Обновление списка шрифтов под язык
    func updateAvailableFonts(for language: String) {
        if language == "ru" {
            availableFonts = allFonts.filter { fontSupportsCyrillic($0) }
        } else {
            availableFonts = allFonts
        }

        // 🔒 Проверка: если выбранный шрифт больше не доступен — сбрасываем
        if !availableFonts.contains(selectedFontName) {
            selectedFontName = availableFonts.first ?? "System"
        }
    }

    // MARK: - Проверка: умеет ли шрифт отображать кириллицу?
    private func fontSupportsCyrillic(_ fontName: String) -> Bool {
        let testString = "ЖЯБ" // + Можно расширить при желании
        guard let uiFont = uiFontFor(fontName, size: 14) else { return false }

        let ctFont = uiFont as CTFont
        let characters = Array(testString.utf16)
        var glyphs = Array<CGGlyph>(repeating: 0, count: characters.count)

        let success = CTFontGetGlyphsForCharacters(ctFont, characters, &glyphs, characters.count)

        return success && !glyphs.contains(0)
    }

    // MARK: - Получение UIFont по имени
    private func uiFontFor(_ font: String, size: CGFloat) -> UIFont? {
        switch font {
        case "Pacifico": return UIFont(name: "Pacifico-Regular", size: size)
        case "CormorantGaramond": return UIFont(name: "CormorantGaramond-Regular", size: size)
        case "Medieval": return UIFont(name: "MedievalSharp", size: size)
        case "OldStandard": return UIFont(name: "OldStandardTT-Regular", size: size)
        case "RuslanDisplay": return UIFont(name: "RuslanDisplay", size: size)
        case "ShareTech": return UIFont(name: "ShareTechMono-Regular", size: size)
        case "UncialAntiqua": return UIFont(name: "UncialAntiqua-Regular", size: size)
        case "Skranji": return UIFont(name: "Skranji", size: size)
        case "GreatVibes": return UIFont(name: "GreatVibes-Regular", size: size)
        case "Deutsch Gothic": return UIFont(name: "DeutschGothic", size: size)
        default: return UIFont.systemFont(ofSize: size)
        }
    }

    // MARK: - Текущий выбранный шрифт
    var selectedFontName: String {
        get { selectedFont }
        set { selectedFont = newValue }
    }

    // MARK: - Возврат шрифта для SwiftUI
    func font(size: CGFloat) -> Font {
        switch selectedFont {
        case "Pacifico": return Font.custom("Pacifico-Regular", size: size)
        case "CormorantGaramond": return Font.custom("CormorantGaramond-Regular", size: size)
        case "Medieval": return Font.custom("MedievalSharp", size: size)
        case "OldStandard": return Font.custom("OldStandardTT-Regular", size: size)
        case "RuslanDisplay": return Font.custom("RuslanDisplay", size: size)
        case "ShareTech": return Font.custom("ShareTechMono-Regular", size: size)
        case "UncialAntiqua": return Font.custom("UncialAntiqua-Regular", size: size)
        case "Skranji": return Font.custom("Skranji", size: size)
        case "GreatVibes": return Font.custom("GreatVibes-Regular", size: size)
        case "Deutsch Gothic": return Font.custom("DeutschGothic", size: size)
        default: return Font.system(size: size)
        }
    }

    // MARK: - Смещение текста для выравнивания
    func offset(for font: String) -> CGSize {
        switch font {
        case "Pacifico": return CGSize(width: 0, height: -3)
        case "OldStandard": return CGSize(width: 0, height: 2)
        case "Medieval": return CGSize(width: 0, height: 1)
        case "RuslanDisplay": return CGSize(width: 0, height: 4)
        case "ShareTech": return CGSize(width: 0, height: 0)
        case "CormorantGaramond": return CGSize(width: 0, height: -3)
        case "UncialAntiqua": return CGSize(width: 0, height: 0)
        case "Skranji": return CGSize(width: 0, height: 0)
        default: return .zero
        }
    }
}
