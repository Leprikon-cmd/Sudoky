import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @EnvironmentObject private var fontManager: FontManager
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("selectedFont") private var selectedFont: String = "System"
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
                                displayValue: fontDisplayName(selectedFont),
                                sampleCharacter: languageManager.language == "ru" ? "А" : "A"
                            ) {
                                Picker(loc("settings.fonts.select"), selection: $selectedFont) {
                                    ForEach(fontManager.availableFonts, id: \.self) { fontName in
                                        Text(fontDisplayName(fontName))
                                            .tag(fontName)
                                    }
                                }
                            }
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
                                        .tag(language)
                                }
                            }
                            .onChange(of: languageManager.language) { _, newLanguage in
                                fontManager.updateAvailableFonts(for: newLanguage)
                            }
                        }
                    }
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
    let sampleCharacter: String?
    let options: Options

    @ScaledMetric(relativeTo: .body) private var titleFontSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var valueFontSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var sampleFontSize: CGFloat = 18

    init(
        iconName: String,
        title: String,
        displayValue: String,
        sampleCharacter: String? = nil,
        @ViewBuilder options: () -> Options
    ) {
        self.iconName = iconName
        self.title = title
        self.displayValue = displayValue
        self.sampleCharacter = sampleCharacter
        self.options = options()
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                if let sampleCharacter {
                    Text(sampleCharacter)
                        .textStyle(size: sampleFontSize)
                        .fixedSize()
                }
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

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
        .environmentObject(FontManager.shared)
        .environmentObject(LanguageManager())
}
