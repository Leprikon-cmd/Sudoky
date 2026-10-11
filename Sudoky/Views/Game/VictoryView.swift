import SwiftUI

struct VictoryView: View {
    let difficulty: Difficulty
    let elapsedTime: TimeInterval
    let errorCount: Int
    let hasAvailableDevelopment: Bool
    let onNewGame: () -> Void
    let onGarden: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var titleFontSize: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var quoteFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .body) private var actionFontSize: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var subtitleFontSize: CGFloat = 13

    var body: some View {
        let _ = languageManager.language

        GeometryReader { geometry in
            let compact = geometry.size.height < 640 || geometry.size.width < 360 || dynamicTypeSize.isAccessibilitySize
            let panelFrame = CGSize(
                width: min(520, geometry.size.width - 16),
                height: min(geometry.size.height - 16, compact ? 480 : 560)
            )
            let errors = max(0, errorCount)

            ZStack {
                BackgroundView()
                    .ignoresSafeArea()

                ZStack {
                    Image("victory_parchment_blank_v1")
                        .resizable()
                        .frame(width: panelFrame.width, height: panelFrame.height)
                        .accessibilityHidden(true)

                    VStack(spacing: compact ? 5 : 9) {
                        Text(loc("victory.title"))
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
                                value: String(errors),
                                symbol: "exclamationmark"
                            )
                        }

                        Rectangle()
                            .fill(Color("Line").opacity(0.85))
                            .frame(height: 1)
                            .padding(.vertical, compact ? 0 : 3)

                        Text(loc("victory.message"))
                            .textStyle(size: quoteFontSize)
                            .italic()
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)

                        VStack(spacing: compact ? 5 : 8) {
                            VictoryActionButton(
                                title: loc("start.newGame"),
                                subtitle: loc("start.resume"),
                                iconName: "garden_icon_sprout_v2",
                                iconVisibleBounds: CGRect(x: 129, y: 151, width: 998, height: 984),
                                highlighted: false,
                                titleFontSize: actionFontSize,
                                subtitleFontSize: subtitleFontSize,
                                action: onNewGame
                            )

                            VictoryActionButton(
                                title: loc("garden.title"),
                                subtitle: hasAvailableDevelopment ? loc("victory.gardenReady") : nil,
                                iconName: "garden_icon_bonsai_v1",
                                iconVisibleBounds: CGRect(x: 118, y: 139, width: 1039, height: 1013),
                                highlighted: hasAvailableDevelopment,
                                titleFontSize: actionFontSize,
                                subtitleFontSize: subtitleFontSize,
                                action: onGarden
                            )

                            VictoryActionButton(
                                title: loc("victory.home"),
                                subtitle: loc("victory.home.subtitle"),
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
                    .padding(.vertical, compact ? 20 : 24)
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

struct VictoryMetricView: View {
    let title: String
    let value: String
    let symbol: String

    @ScaledMetric(relativeTo: .caption) private var titleFontSize: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var valueFontSize: CGFloat = 15

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("ButtonPrimary"))
                .frame(width: 30, height: 30)
                .overlay {
                    Circle()
                        .stroke(Color("Line").opacity(0.9), lineWidth: 1)
                }
                .accessibilityHidden(true)

            Text(title)
                .textStyle(size: titleFontSize)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(value)
                .textStyle(size: valueFontSize)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct VictoryActionButton: View {
    let title: String
    let subtitle: String?
    let iconName: String
    let iconVisibleBounds: CGRect?
    let highlighted: Bool
    let titleFontSize: CGFloat
    let subtitleFontSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                GardenCircleIcon(
                    assetName: iconName,
                    visibleBounds: iconVisibleBounds,
                    visibleDiameter: 48,
                    containerSide: 60
                )

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .textStyle(size: titleFontSize)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    if let subtitle {
                        Text(subtitle)
                            .textStyle(size: subtitleFontSize)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .frame(minHeight: 56)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("ButtonPrimary").opacity(highlighted ? 0.12 : 0.045))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                highlighted ? Color("ButtonPrimary").opacity(0.8) : Color("Line").opacity(0.9),
                                lineWidth: 1
                            )
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
