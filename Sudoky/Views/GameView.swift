//  GameView.swift
//  Sudoky

import SwiftUI

struct GameView: View {
    let difficulty: Difficulty                        // Уровень сложности
    let statsManager: StatsManager                    // Менеджер статистики
    let playerProgressManager: PlayerProgressManager  // Менеджер игрока
    @Binding var path: NavigationPath                 // Навигационный путь (Stack)

    @StateObject private var viewModel: SudokuViewModel  // ViewModel игры
    @State private var showWinAlert = false               // Флаг победного алерта
    @State private var showLoseAlert = false              // Флаг проигрышного алерта

    // MARK: - Инициализация из сохранённой игры
        init(savedGame: SavedGame, statsManager: StatsManager, playerProgressManager: PlayerProgressManager, path: Binding<NavigationPath>) {
            _viewModel = StateObject(wrappedValue: SudokuViewModel(savedGame: savedGame))
            self.difficulty = savedGame.difficulty // <- тянем из сохранённого
            self.statsManager = statsManager
            self._path = path
            self.playerProgressManager = playerProgressManager
        }

        // MARK: - Инициализация новой игры
        init(difficulty: Difficulty, statsManager: StatsManager, playerProgressManager: PlayerProgressManager, path: Binding<NavigationPath>) {
            _viewModel = StateObject(wrappedValue: SudokuViewModel(difficulty: difficulty,
                    showErrors: difficulty != .dokushin,
                    highlightIdenticals: difficulty != .dokushin
                )
            )
            self.difficulty = difficulty
            self.statsManager = statsManager
            self._path = path
            self.playerProgressManager = playerProgressManager
        }

    // MARK: - Тело View
    var body: some View {
        VStack {
            // Текущий уровень сложности
            Text("Сложность: \(difficulty.rawValue.capitalized)")
                .font(.headline)

            // Отображение оставшихся жизней (сердечки)
            HStack(spacing: 4) {
                ForEach(0..<viewModel.livesRemaining, id: \.self) { _ in
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            
            .onDisappear {
                viewModel.saveGame() //Сохраняемся при выходе
            }
            
            .padding(.bottom, 8)

            // Таймер
            Text("Время: \(Int(viewModel.elapsedTime)) сек")
                .font(.subheadline)

            // Игровое поле
            GeometryReader { geo in
                let gridSize = min(geo.size.width, geo.size.height * 0.7)
                let cellSize = gridSize / 9

                VStack {
                    Spacer()

                    ZStack {
                        // Ячейки судоку
                        SudokuGridView(
                            cells: viewModel.board.cells,
                            onCellTap: { row, col in viewModel.selectCell(row: row, col: col) },
                            highlightedValue: viewModel.highlightedValue,
                            highlightEnabled: viewModel.highlightIdenticals,
                            showErrors: viewModel.showErrors,
                            cellSize: cellSize
                        )

                        // Сетка (разметка 3x3)
                        GridOverlayView(gridSize: gridSize)
                    }
                    .frame(width: gridSize, height: gridSize)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()
                }
            }

            // Кнопочная панель
            KeypadView { number in
                viewModel.enterNumber(number)
            }
        }

        // MARK: - Реакция на окончание игры
        .onChange(of: viewModel.isGameOver) { _, newValue in
            if newValue {
                // Наказание за проигрыш
                playerProgressManager.applyLossPenalty()

                // Записываем статистику
                statsManager.recordGame(
                    difficulty: difficulty,
                    won: false,
                    time: viewModel.elapsedTime,
                    flawless: false
                )
                showLoseAlert = true
            }
        }
        .onChange(of: viewModel.isGameWon) { _, newValue in
            if newValue {
                playerProgressManager.addXP(
                    difficulty: difficulty,
                    livesRemaining: viewModel.livesRemaining,
                    elapsedTime: viewModel.elapsedTime
                )

                statsManager.recordGame(
                    difficulty: difficulty,
                    won: true,
                    time: viewModel.elapsedTime,
                    flawless: viewModel.livesRemaining == difficulty.lives
                )
                showWinAlert = true
            }
        }

        // MARK: - Алерт: проигрыш
        .alert("Ты проиграл!", isPresented: $showLoseAlert) {
            Button("Заново") {
                restartGame()
            }
            Button("Новая игра") {
                path.append(Route.difficulty)
            }
            Button("Статистика") {
                path.append(Route.stats)
            }
            Button("Меню") {
                path.removeLast(path.count)
            }
        } message: {
            Text("Все жизни закончились… попробуй ещё раз!")
        }

        // MARK: - Алерт: победа
        .alert("Победа!", isPresented: $showWinAlert) {
            Button("Заново") {
                restartGame()
            }
            Button("Новая игра") {
                path.append(Route.difficulty)
            }
            Button("Статистика") {
                path.append(Route.stats)
            }
            Button("Меню") {
                path.removeLast(path.count)
            }
        } message: {
            Text("Ты победил за \(formatTime(viewModel.elapsedTime))")
        }

        .padding()
        .navigationTitle("Игра")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Метод перезапуска
    private func restartGame() {
        viewModel.restartGame(with: difficulty)
    }
}

// MARK: - Форматирование таймера
private func formatTime(_ seconds: TimeInterval) -> String {
    let minutes = Int(seconds) / 60
    let secs = Int(seconds) % 60
    return String(format: "%02d:%02d", minutes, secs)
}

// MARK: - Превью
#Preview {
    GameView(
        difficulty: .новичок,
        statsManager: StatsManager(),
        playerProgressManager: PlayerProgressManager.shared, // ← ВАЖНО
        path: .constant(NavigationPath())
    )
}
