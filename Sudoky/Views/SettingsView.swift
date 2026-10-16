import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @EnvironmentObject private var fontManager: FontManager
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("playerMotto") private var playerMotto: String = ""

    var body: some View {
        let _ = languageManager.language

        ZStack {
            BackgroundView()
                .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    PaperSectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(loc("settings.appearance"))
                                .textStyle(size: 21)
                                .fixedSize(horizontal: false, vertical: true)

                            SettingsChoiceRow(
                                iconName: "life_enso",
                                title: loc("settings.fonts.select"),
                                displayValue: fontDisplayName(fontManager.selectedFontName)
                            ) {
                                Picker(loc("settings.fonts.select"), selection: $fontManager.selectedFontName) {
                                    ForEach(fontManager.availableFonts, id: \.self) { fontName in
                                        Text(fontDisplayName(fontName))
                                            .font(fontManager.interfaceFont(size: 17))
                                            .tag(fontName)
                                    }
                                }
                            }

                            Text(loc("settings.fonts.preview"))
                                .textStyle(size: 16)
                            GeometryReader { geometry in
                                let previewSize = min(252, geometry.size.width)
                                GameBoardView(
                                    cells: FontPreviewBoard.cells,
                                    highlightedValue: nil,
                                    highlightEnabled: false,
                                    showErrors: false,
                                    onCellTap: { _, _ in },
                                    customWidth: previewSize,
                                    presentation: .fontPreview
                                )
                                .frame(width: previewSize, height: previewSize)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .allowsHitTesting(false)
                            }
                            .frame(height: 252)
                        }
                    }

#if DEBUG
                    PaperSectionCard {
                        Toggle(isOn: $settings.testModeEnabled) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(loc("settings.testMode"))
                                    .textStyle(size: 17)
                                Text(loc("settings.testMode.description"))
                                    .textStyle(size: 14)
                                    .foregroundColor(Color("TextColor").opacity(0.75))
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color("ButtonPrimary")))
                        .onChange(of: settings.testModeEnabled) { _, isEnabled in
                            if isEnabled { _ = GardenManager.debugShared }
                        }
                    }
#endif

                    PaperSectionCard {
                        SettingsChoiceRow(
                            iconName: "settings_ink_language",
                            title: loc("settings.language"),
                            displayValue: languageDisplayName(languageManager.language)
                        ) {
                            Picker(loc("settings.language.select"), selection: $languageManager.language) {
                                ForEach(settings.languages, id: \.self) { language in
                                    Text(languageDisplayName(language))
                                        .font(fontManager.interfaceFont(size: 17))
                                        .tag(language)
                                }
                            }
                        }
                    }

                    Link(destination: URL(string: "https://leprikon-cmd.github.io/Sudoky/privacy.html")!) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .accessibilityHidden(true)

                            Text(loc("settings.privacy.policy"))
                                .textStyle(size: 15, color: Color("ButtonPrimary"))
                                .multilineTextAlignment(.center)

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .accessibilityHidden(true)
                        }
                        .foregroundStyle(Color("ButtonPrimary"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(.horizontal, 14)
                        .background(
                            Color("ButtonPrimary").opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("ButtonPrimary").opacity(0.35), lineWidth: 1)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(loc("settings.title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            AppBackToolbarItem {
                dismiss()
            }
        }
    }

    private func fontDisplayName(_ fontName: String) -> String {
        switch fontName {
        case "System": return loc("settings.font.system")
        case "CormorantGaramond": return "Cormorant Garamond"
        case "Medieval": return "Medieval Sharp"
        case "OldStandard": return "Old Standard TT"
        case "RuslanDisplay": return "Ruslan Display"
        case "ShareTech": return "Share Tech Mono"
        case "UncialAntiqua": return "Uncial Antiqua"
        case "GreatVibes": return "Great Vibes"
        default: return fontName
        }
    }

    private func languageDisplayName(_ language: String) -> String {
        switch language {
        case "ru": return loc("settings.language.ru")
        case "en": return loc("settings.language.en")
        default: return language
        }
    }
}

private struct SettingsChoiceRow<Options: View>: View {
    let iconName: String
    let title: String
    let displayValue: String
    let options: Options

    @ScaledMetric(relativeTo: .body) private var titleFontSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var valueFontSize: CGFloat = 16

    init(
        iconName: String,
        title: String,
        displayValue: String,
        @ViewBuilder options: () -> Options
    ) {
        self.iconName = iconName
        self.title = title
        self.displayValue = displayValue
        self.options = options()
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

            }
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)

            Text(title)
                .textStyle(size: titleFontSize)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                options
            } label: {
                HStack(alignment: .center, spacing: 6) {
                    Text(displayValue)
                        .textStyle(size: valueFontSize)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color("ButtonPrimary"))
                        .accessibilityHidden(true)
                }
                .frame(minWidth: 80, minHeight: 48, alignment: .trailing)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .layoutPriority(1)
            .accessibilityLabel(Text(title))
            .accessibilityValue(Text(displayValue))
        }
        .frame(minHeight: 52)
    }
}

private enum FontPreviewBoard {
    private static let givens: [Int: Int] = [0: 5, 4: 7, 8: 2, 10: 6, 13: 1, 17: 9, 20: 8, 24: 3, 28: 4]
    private static let entered: [Int: Int] = [2: 4, 16: 5, 30: 7, 42: 2, 58: 6, 70: 3]
    private static let notes: [Int: [Int]] = [3: [1, 3, 8], 22: [2, 5, 9], 35: [1, 4, 7], 49: [3, 6, 8], 65: [2, 4, 9], 77: [1, 5, 7]]

    static let cells: [[Cell]] = (0..<9).map { row in
        (0..<9).map { col in
            let index = row * 9 + col
            if let value = givens[index] {
                return Cell(row: row, col: col, value: value, isEditable: false, isSelected: false)
            }
            if let value = entered[index] {
                return Cell(row: row, col: col, value: value, isEditable: true, isSelected: false)
            }
            return Cell(row: row, col: col, value: 0, isEditable: true, isSelected: false, notes: notes[index] ?? [])
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(FontManager.shared)
        .environmentObject(LanguageManager())
}
