import SwiftUI

struct StatsView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @State private var selectedIndex = 0

    var body: some View {
        VStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(Difficulty.allCases.enumerated()), id: \.offset) { index, difficulty in
                    if let entry = statsManager.stats[difficulty] {
                        VStack(alignment: .leading, spacing: 10) {
                            Spacer()
                            Text(difficulty.rawValue.capitalized)
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom)

                            Text("Сыграно игр: \(entry.played)")
                            Text("Побед: \(entry.wins)")
                            Text("Лучшее время: \(formatTime(entry.bestTime))")
                            Text("Серия побед: \(entry.winStreak) / рекорд: \(entry.maxWinStreak)")
                            Text("Побед без ошибок: \(entry.flawlessStreak) / рекорд: \(entry.maxFlawlessStreak)")

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 400)

            Button("Сбросить статистику") {
                statsManager.resetStats()
            }
            .foregroundColor(.red)
            .padding(.top, 20)
        }
        .padding()
    }

    func formatTime(_ time: TimeInterval) -> String {
        guard time > 0 else { return "–" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    StatsView(
        statsManager: StatsManager(),
        path: .constant(NavigationPath())
    )
}
