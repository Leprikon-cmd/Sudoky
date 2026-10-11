import SwiftUI

struct DefeatView: View {
    let difficulty: Difficulty
    let elapsedTime: TimeInterval
    let errorCount: Int
    let onRestart: () -> Void
    let onNewGame: () -> Void
    let onStats: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var titleFontSize: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var messageFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .body) private var actionFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var subtitleFontSize: CGFloat = 13

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let compact = geometry.size.height < 640
                || geometry.size.width < 360
                || dynamicTypeSize.isAccessibilitySize
            let panelFrame = CGSize(
                width: min(520, geometry.size.width - 16),
                height: min(geometry.size.height - 16, compact ? 590 : 560)
            )

            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                ZStack {
                    Image("victory_parchment_blank_v1")
                        .resizable()
                        .frame(width: panelFrame.width, height: panelFrame.height)
                        .accessibilityHidden(true)

                    VStack(spacing: compact ? 5 : 9) {
                        Text(loc("defeat.title"))
                            .textStyle(size: titleFontSize)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .accessibilityAddTraits(.isHeader)

                        HStack(spacing: compact ? 4 : 10) {
                            VictoryMetricView(
                                title: loc("victory.metric.difficulty"),
                                value: difficulty.localizedName,
                                symbol: "square.grid.3x3"
                            )
                            VictoryMetricView(
                                title: loc("victory.metric.time"),
                                value: formattedTime,
                                symbol: "clock"
                            )
                            VictoryMetricView(
                                title: loc("victory.metric.errors"),
                                value: String(max(0, errorCount)),
                                symbol: "exclamationmark"
                            )
                        }

                        Rectangle()
                            .fill(Color("Line").opacity(0.85))
                            .frame(height: 1)
                            .padding(.vertical, compact ? 0 : 3)

                        Text(loc("defeat.message"))
                            .textStyle(size: messageFontSize)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

                        VStack(spacing: compact ? 4 : 6) {
                            VictoryActionButton(
                                title: loc("alert.restart"),
                                subtitle: loc("defeat.restart.subtitle"),
                                iconName: "garden_icon_branch_v1",
                                iconVisibleBounds: CGRect(x: 126, y: 151, width: 1002, height: 975),
                                highlighted: false,
                                titleFontSize: actionFontSize,
                                subtitleFontSize: subtitleFontSize,
                                action: onRestart
                            )
                            VictoryActionButton(
                                title: loc("alert.newGame"),
                                subtitle: loc("defeat.newGame.subtitle"),
                                iconName: "garden_icon_sprout_v2",
                                iconVisibleBounds: CGRect(x: 129, y: 151, width: 998, height: 984),
                                highlighted: false,
                                titleFontSize: actionFontSize,
                                subtitleFontSize: subtitleFontSize,
                                action: onNewGame
                            )
                            VictoryActionButton(
                                title: loc("alert.stats"),
                                subtitle: loc("defeat.stats.subtitle"),
                                iconName: "stats_games_grid",
                                iconVisibleBounds: nil,
                                highlighted: false,
                                titleFontSize: actionFontSize,
                                subtitleFontSize: subtitleFontSize,
                                action: onStats
                            )
                            VictoryActionButton(
                                title: loc("alert.menu"),
                                subtitle: loc("defeat.home.subtitle"),
                                iconName: "garden_icon_torii_v1",
                                iconVisibleBounds: CGRect(x: 153, y: 160, width: 951, height: 942),
                                highlighted: false,
                                titleFontSize: actionFontSize,
                                subtitleFontSize: subtitleFontSize,
                                action: onHome
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, compact ? 14 : 24)
                    .frame(width: panelFrame.width, height: panelFrame.height)
                }
                .frame(width: panelFrame.width, height: panelFrame.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
    }

    private var formattedTime: String {
        let totalSeconds = max(0, Int(elapsedTime))
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
