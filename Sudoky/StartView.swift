import SwiftUI

struct StartView: View {
    let statsManager: StatsManager
    @Binding var path: NavigationPath
    @AppStorage("playerMotto") private var playerMotto: String = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("Судоку. Путь мудреца")
                    .font(.largeTitle)
                    .bold()

                TextField("Впиши свою мудрость...", text: $playerMotto)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)

                Button("🧩 Новый Путь") {
                    path.append(Route.difficulty)
                }
                .buttonStyle(.borderedProminent)

                Button("📜 Уровни познания") {
                    path.append(Route.stats)
                }
                .buttonStyle(.bordered)

                if hasSavedGame() {
                    Button("🛤 Продолжить путь") {
                        // TODO: Загрузка сохранённой игры
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding()

            Button(action: {
                path.append(Route.settings)
            }) {
                Image(systemName: "book.fill")
                    .padding(12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()
        }
    }

    func hasSavedGame() -> Bool {
        // TODO: реализовать логику проверки наличия сохранённой игры
        return false
    }
}

#Preview {
    StartView(
        statsManager: StatsManager(),
        path: Binding.constant(NavigationPath())
    )
}
