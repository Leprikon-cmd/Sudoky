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

enum GameFontMetrics: Equatable {
    case standard
    case preview
}

// ✅ Быстрый доступ к стилю текста с автоматическим шрифтом и цветом
extension View {
    func textStyle(size: CGFloat, customColor: Color? = nil) -> some View {
        modifier(AutoTextStyle(size: size, customColor: customColor))
    }

    func textStyle(size: CGFloat, color: Color) -> some View {
        modifier(FixedTextStyle(size: size, color: color))
    }

    func bookTextStyle(size: CGFloat, weight: Font.Weight = .regular, color: Color? = nil) -> some View {
        modifier(BookTextStyle(size: size, weight: weight, color: color))
    }

    func gameTextStyle(
        size: CGFloat,
        characters: String,
        color: Color? = nil,
        metrics: GameFontMetrics = .standard
    ) -> some View {
        modifier(GameTextStyle(size: size, characters: characters, color: color, metrics: metrics))
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
            .font(fontManager.interfaceFont(size: size))
            .foregroundColor(customColor ?? settings.selectedTextColor)
    }
}

// ✅ Фиксированный цвет, шрифт из настроек
private struct FixedTextStyle: ViewModifier {
    let size: CGFloat
    let color: Color
    @EnvironmentObject var fontManager: FontManager

    func body(content: Content) -> some View {
        content
            .font(fontManager.interfaceFont(size: size))
            .foregroundColor(color)
    }
}

private struct BookTextStyle: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    let color: Color?
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var fontManager: FontManager

    func body(content: Content) -> some View {
        content.font(fontManager.bookFont(size: size, weight: weight))
            .foregroundColor(color ?? settings.selectedTextColor)
    }
}

private struct GameTextStyle: ViewModifier {
    let size: CGFloat
    let characters: String
    let color: Color?
    let metrics: GameFontMetrics
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var fontManager: FontManager

    func body(content: Content) -> some View {
        content.font(fontManager.gameFont(size: size, characters: characters))
            .foregroundColor(color ?? settings.selectedTextColor)
            .offset(fontManager.gameTextOffset(size: size, characters: characters, metrics: metrics))
    }
}

// ✅ Главный менеджер шрифтов
class FontManager: ObservableObject {
    static let shared = FontManager()

    @Published var selectedFontName: String {
        didSet { UserDefaults.standard.set(selectedFontName, forKey: "selectedFont") }
    }
    let availableFonts: [String]

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
        selectedFontName = UserDefaults.standard.string(forKey: "selectedFont") ?? "System"
        availableFonts = allFonts
        configureNavigationBarTypography()
    }

    private func configureNavigationBarTypography() {
        let appearance = UINavigationBar.appearance()
        if let inlineFont = UIFont(name: "OldStandardTT-Regular", size: 17) {
            var attributes = appearance.titleTextAttributes ?? [:]
            attributes[.font] = inlineFont
            appearance.titleTextAttributes = attributes
        }
        if let largeFont = UIFont(name: "OldStandardTT-Regular", size: 34) {
            var attributes = appearance.largeTitleTextAttributes ?? [:]
            attributes[.font] = largeFont
            appearance.largeTitleTextAttributes = attributes
        }
    }

    // MARK: - Проверка: умеет ли шрифт отображать кириллицу?
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

    private func hasGlyphs(_ text: String, in font: UIFont) -> Bool {
        let characters = Array(text.utf16)
        guard !characters.isEmpty else { return true }
        var glyphs = Array<CGGlyph>(repeating: 0, count: characters.count)
        return CTFontGetGlyphsForCharacters(font as CTFont, characters, &glyphs, characters.count)
            && !glyphs.contains(0)
    }

    private func fontName(for choice: String) -> String? {
        switch choice {
        case "Pacifico": return "Pacifico-Regular"
        case "CormorantGaramond": return "CormorantGaramond-Regular"
        case "Medieval": return "MedievalSharp"
        case "OldStandard": return "OldStandardTT-Regular"
        case "RuslanDisplay": return "RuslanDisplay"
        case "ShareTech": return "ShareTechMono-Regular"
        case "UncialAntiqua": return "UncialAntiqua-Regular"
        case "Skranji": return "Skranji"
        case "GreatVibes": return "GreatVibes-Regular"
        case "Deutsch Gothic": return "DeutschGothic"
        default: return nil
        }
    }

    func interfaceFont(size: CGFloat) -> Font {
        if UIFont(name: "OldStandardTT-Regular", size: size) != nil {
            return .custom("OldStandardTT-Regular", size: size)
        }
        return .system(size: size)
    }

    func interfaceMeasurementFont(size: CGFloat) -> UIFont {
        UIFont(name: "OldStandardTT-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    func bookFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if UIFont(name: "CormorantGaramond-Regular", size: size) != nil {
            let font = Font.custom("CormorantGaramond-Regular", size: size)
            return weight == .regular ? font : font.weight(weight)
        }
        return weight == .regular ? .system(size: size) : .system(size: size, weight: weight, design: .serif)
    }

    func bookMeasurementFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let regular = UIFont(name: "CormorantGaramond-Regular", size: size) ?? .systemFont(ofSize: size)
        guard weight != .regular else { return regular }
        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight.rawValue]
        let descriptor = regular.fontDescriptor.addingAttributes([.traits: traits])
        return UIFont(descriptor: descriptor, size: size)
    }

    func gameFont(size: CGFloat, characters: String) -> Font {
        guard let name = fontName(for: selectedFontName), let font = UIFont(name: name, size: size), hasGlyphs(characters, in: font) else {
            return .system(size: size)
        }
        return .custom(name, size: size)
    }

    func gameMeasurementFont(size: CGFloat, characters: String) -> UIFont {
        guard let name = fontName(for: selectedFontName), let font = UIFont(name: name, size: size), hasGlyphs(characters, in: font) else {
            return .systemFont(ofSize: size)
        }
        return font
    }

    func previewNoteFontSize(cellSize: CGFloat) -> CGFloat {
        let noteCellSize = cellSize / 3
        let font = gameMeasurementFont(size: 100, characters: "123456789") as CTFont
        let characters = Array("123456789".utf16)
        var glyphs = Array<CGGlyph>(repeating: 0, count: characters.count)
        guard CTFontGetGlyphsForCharacters(font, characters, &glyphs, characters.count) else {
            return noteCellSize * 0.75
        }
        var bounds = Array<CGRect>(repeating: .zero, count: glyphs.count)
        _ = CTFontGetBoundingRectsForGlyphs(font, .horizontal, &glyphs, &bounds, glyphs.count)
        let largestGlyph = bounds.map(\.height).max() ?? 0
        guard largestGlyph > 0 else { return noteCellSize * 0.75 }

        let sizeForTargetGlyphHeight = 100 * (noteCellSize * 0.74) / largestGlyph
        return min(sizeForTargetGlyphHeight, noteCellSize * 1.15)
    }

    func gameTextOffset(size: CGFloat, characters: String, metrics: GameFontMetrics) -> CGSize {
        guard metrics == .preview else { return offset(for: selectedFontName) }
        let units = Array(characters.utf16)
        guard !units.isEmpty else { return .zero }

        let font = gameMeasurementFont(size: size, characters: characters) as CTFont
        var glyphs = Array<CGGlyph>(repeating: 0, count: units.count)
        guard CTFontGetGlyphsForCharacters(font, units, &glyphs, units.count) else { return .zero }
        var bounds = Array<CGRect>(repeating: .zero, count: glyphs.count)
        _ = CTFontGetBoundingRectsForGlyphs(font, .horizontal, &glyphs, &bounds, glyphs.count)

        let baselineToLineCenter = (CTFontGetAscent(font) - CTFontGetDescent(font)) / 2
        let correction = (bounds.first?.midY ?? 0) - baselineToLineCenter
        let limit = min(1.5, size * 0.16)
        return CGSize(width: 0, height: min(limit, max(-limit, correction)))
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
