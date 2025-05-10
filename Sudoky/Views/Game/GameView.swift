//  GameView.swift
//  Sudoky

import SwiftUI

struct GameView: View {
    let difficulty: Difficulty                        // Уровень сложности
    let statsManager: StatsManager                    // Менеджер статистики
    let playerProgressManager: PlayerProgressManager  // Менеджер игрока
    @Binding var path: NavigationPath                 // Навигационный путь (Stack)

    @StateObject private var viewModel: SudokuViewModel   // ViewModel игры
    @State private var showWinAlert = false               // Флаг победного алерта
    @State private var showLoseAlert = false              // Флаг проигрышного алерта
    @State private var gainedXP: Int = 0                  // Сколько опыта получено или потеряно

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
        ZStack {
            VStack {
                GameHeaderView(
                    difficulty: difficulty,
                    timeElapsed: viewModel.elapsedTime,
                    livesRemaining: viewModel.livesRemaining
                )
                
                GeometryReader { geo in
                    GameBoardView(
                        cells: viewModel.board.cells,
                        highlightedValue: viewModel.highlightedValue,
                        highlightEnabled: viewModel.highlightIdenticals,
                        showErrors: viewModel.showErrors,
                        onCellTap: { row, col in viewModel.selectCell(row: row, col: col) },
                        geo: geo
                    )
                }
                
                // Кнопочная панель
                KeypadView { number in
                    viewModel.enterNumber(number)
                }
            }
            
            // MARK: - Реакция на окончание игры
            .onChange(of: viewModel.isGameOver) { _, newValue in
                print("🔥 isGameWon changed to \(newValue)")
                if newValue {
                    let penalty = playerProgressManager.applyLossPenalty()
                    gainedXP = -Int(penalty)
                    
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
                print("🔥 isGameWon changed to \(newValue)")
                if newValue {
                    let xp = playerProgressManager.addXP(
                        difficulty: difficulty,
                        livesRemaining: viewModel.livesRemaining,
                        elapsedTime: viewModel.elapsedTime
                    )
                    gainedXP = Int(xp)
                    
                    statsManager.recordGame(
                        difficulty: difficulty,
                        won: true,
                        time: viewModel.elapsedTime,
                        flawless: viewModel.livesRemaining == difficulty.lives
                    )
                    showWinAlert = true
                }
            }
            
            GameAlertsView(
                showWinAlert: $showWinAlert,
                showLoseAlert: $showLoseAlert,
                gainedXP: gainedXP,
                elapsedTime: viewModel.elapsedTime,
                flawless: viewModel.livesRemaining == difficulty.lives,
                onRestart: restartGame,
                onNewGame: { path.append(Route.difficulty) },
                onStats: { path.append(Route.stats) },
                onMenu: { path.removeLast(path.count) }
            )
            
            .padding()
            .navigationTitle("Игра")
            .navigationBarTitleDisplayMode(.inline)
        }
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
