import SwiftUI

struct StatsView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath

    @State private var selectedIndex = 0
    @State private var showResetAlert = false
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleFontSize: CGFloat = 30
    @ScaledMetric(relativeTo: .title2) private var difficultyFontSize: CGFloat = 22
    @ScaledMetric(relativeTo: .body) private var resetFontSize: CGFloat = 16

    private var selectedDifficulty: Difficulty {
        Difficulty.allCases[selectedIndex]
    }

    private var selectedEntry: StatsEntry {
        // Missing data is only defaulted for display; browsing never writes it back.
        statsManager.stats[selectedDifficulty] ?? StatsEntry()
    }

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let compactLayout = geometry.size.height < 740 || dynamicTypeSize.isAccessibilitySize

            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: compactLayout ? 8 : 12) {
                    Text(loc("start.stats"))
                        .textStyle(size: compactLayout ? titleFontSize * 0.9 : titleFontSize)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)

                    difficultySelector

                    StatsDifficultyPage(entry: selectedEntry, compact: compactLayout)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        // Horizontal swipes change difficulty; vertical drags are ignored and ends never wrap.
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    let horizontal = value.translation.width
                                    guard abs(horizontal) > abs(value.translation.height), abs(horizontal) > 40 else { return }

                                    if horizontal < 0, selectedIndex < Difficulty.allCases.count - 1 {
                                        selectedIndex += 1
                                    } else if horizontal > 0, selectedIndex > 0 {
                                        selectedIndex -= 1
                                    }
                                }
                        )

                    Spacer(minLength: 0)

                    resetButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, compactLayout ? 6 : 12)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            AppBackToolbarItem {
                path.removeLast()
            }
        }
        .alert(loc("stats.resetConfirmTitle"), isPresented: $showResetAlert) {
            Button(loc("common.yes"), role: .destructive) {
                performReset()
            }
            Button(loc("common.no"), role: .cancel) { }
        } message: {
            Text(loc("stats.resetConfirmMessage"))
        }
    }

    private var difficultySelector: some View {
        Text(selectedDifficulty.localizedName)
            .textStyle(size: difficultyFontSize)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 120, minHeight: 44)
            .frame(maxWidth: .infinity)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    if selectedIndex < Difficulty.allCases.count - 1 {
                        selectedIndex += 1
                    }
                case .decrement:
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                @unknown default:
                    break
                }
            }
    }

    private var resetButton: some View {
        Button {
            showResetAlert = true
        } label: {
            Text(loc("stats.reset"))
                .textStyle(size: resetFontSize, customColor: Color(red: 0.62, green: 0.31, blue: 0.26))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text(loc("stats.resetHint")))
    }

    private func performReset() {
        statsManager.resetStats()
    }
}

private struct StatsDifficultyPage: View {
    let entry: StatsEntry
    let compact: Bool

    var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            resultsCard

            StatsSeriesCard(
                titleKey: "stats.winStreak",
                iconName: "stats_win_streak",
                current: entry.winStreak,
                record: entry.maxWinStreak,
                iconSize: CGSize(width: 58, height: 23),
                compact: compact
            )

            StatsSeriesCard(
                titleKey: "stats.flawlessStreak",
                iconName: "stats_flawless",
                current: entry.flawlessStreak,
                record: entry.maxFlawlessStreak,
                iconSize: CGSize(width: 30, height: 30),
                compact: compact
            )
        }
    }

    private var resultsCard: some View {
        StatsPaperCard(compact: compact) {
            VStack(alignment: .leading, spacing: compact ? 8 : 10) {
                Text(loc("stats.results"))
                    .textStyle(size: compact ? 18 : 20)
                    .fixedSize(horizontal: false, vertical: true)

                StatsMetricRow(
                    iconName: "stats_games_grid",
                    iconSize: CGSize(width: 30, height: 30),
                    labelKey: "stats.gamesPlayed",
                    value: "\(entry.played)"
                )

                Divider().overlay(Color("Line").opacity(0.6))

                StatsMetricRow(
                    iconName: "life_enso",
                    iconSize: CGSize(width: 30, height: 30),
                    labelKey: "stats.wins",
                    value: "\(entry.wins)"
                )

                Divider().overlay(Color("Line").opacity(0.6))

                StatsMetricRow(
                    iconName: "stats_best_time",
                    iconSize: CGSize(width: 24, height: 32),
                    labelKey: "stats.bestTime",
                    value: formatTime(entry.bestTime)
                )
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time > 0 else { return "–" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct StatsMetricRow: View {
    let iconName: String
    let iconSize: CGSize
    let labelKey: String
    let value: String

    @ScaledMetric(relativeTo: .body) private var labelFontSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var valueFontSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 12) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize.width, height: iconSize.height)
                .frame(width: 34, height: 34)
                .accessibilityHidden(true)

            Text(loc(labelKey))
                .textStyle(size: labelFontSize)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .textStyle(size: valueFontSize)
                .monospacedDigit()
                .fixedSize()
        }
        .accessibilityElement(children: .combine)
    }
}

private struct StatsSeriesCard: View {
    let titleKey: String
    let iconName: String
    let current: Int
    let record: Int
    let iconSize: CGSize
    let compact: Bool

    @ScaledMetric(relativeTo: .body) private var titleFontSize: CGFloat = 19
    @ScaledMetric(relativeTo: .body) private var valueFontSize: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var labelFontSize: CGFloat = 15

    var body: some View {
        StatsPaperCard(compact: compact) {
            VStack(alignment: .leading, spacing: compact ? 6 : 8) {
                HStack(spacing: 12) {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize.width, height: iconSize.height)
                        .accessibilityHidden(true)

                    Text(loc(titleKey))
                        .textStyle(size: titleFontSize)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 10) {
                    Text("\(current)")
                        .textStyle(size: valueFontSize)
                        .monospacedDigit()
                        .fixedSize(horizontal: true, vertical: false)
                    Text(loc("stats.current"))
                        .textStyle(size: labelFontSize)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("\(loc("stats.record")): \(record)")
                    .textStyle(size: labelFontSize)
                    .monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

private struct StatsPaperCard<Content: View>: View {
    let compact: Bool
    let content: Content

    init(compact: Bool, @ViewBuilder content: () -> Content) {
        self.compact = compact
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(compact ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("ButtonPrimary").opacity(0.055))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("Line").opacity(0.9), lineWidth: 1)
                }
                .shadow(color: Color("ButtonPrimary").opacity(0.08), radius: 3, y: 1)
        }
    }
}

#Preview {
    StatsView(
        statsManager: StatsManager(),
        path: .constant(NavigationPath())
    )
    .environmentObject(SettingsManager())
    .environmentObject(FontManager.shared)
    .environmentObject(LanguageManager())
}
