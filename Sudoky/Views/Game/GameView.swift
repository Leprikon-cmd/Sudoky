//  GameView.swift
//  Sudoky

import SwiftUI

struct GameView: View {
    let difficulty: Difficulty                        // Уровень сложности
    let statsManager: StatsManager                    // Менеджер статистики
    let playerProgressManager: PlayerProgressManager  // Менеджер игрока
    @Binding var path: NavigationPath                 // Навигационный стек
    @EnvironmentObject var fontManager: FontManager   // Менеджер шрифтов
    
    @StateObject private var viewModel: SudokuViewModel   // ViewModel игры
    @State private var showWinAlert = false               // Показывать алерт победы?
    @State private var showLoseAlert = false              // Показывать алерт проигрыша?
    @State private var gainedXP: Int = 0                  // Опыт, полученный за партию
    
    // MARK: - Инициализация из сохранения
    init(savedGame: SavedGame, statsManager: StatsManager, playerProgressManager: PlayerProgressManager, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: SudokuViewModel(savedGame: savedGame))
        self.difficulty = savedGame.difficulty
        self.statsManager = statsManager
        self._path = path
        self.playerProgressManager = playerProgressManager
    }
    
    // MARK: - Инициализация новой игры
    init(difficulty: Difficulty, statsManager: StatsManager, playerProgressManager: PlayerProgressManager, path: Binding<NavigationPath>) {
        _viewModel = StateObject(
            wrappedValue: SudokuViewModel(
                difficulty: difficulty,
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
                BackgroundView()
                    .ignoresSafeArea()

                GeometryReader { geo in
                    let screenWidth = UIScreen.main.bounds.width
                    let frameThickness: CGFloat = 18
                    let gridSize = screenWidth - frameThickness * 2

                    
                    VStack {
                        // 🔝 Верхняя панель
                        GameHeaderView(
                            difficulty: difficulty,
                            timeElapsed: viewModel.elapsedTime,
                            livesRemaining: viewModel.livesRemaining
                        )

                        // 🎮 Игровое поле
                        HStack {
                            Spacer(minLength: 0)

                            GameBoardView(
                                cells: viewModel.board.cells,
                                highlightedValue: viewModel.highlightedValue,
                                highlightEnabled: viewModel.highlightIdenticals,
                                showErrors: viewModel.showErrors,
                                onCellTap: { row, col in viewModel.selectCell(row: row, col: col) },
                                gridSize: gridSize
                            )
                            .fixedSize() // ❗️важно, чтобы не сжималось
                            .frame(width: gridSize)

                            Spacer(minLength: 0)
                        }

                        Spacer(minLength: 0)

                        // ⌨️ Клавиатура
                        HStack(alignment: .top, spacing: 0) {
                            Spacer(minLength: 0)

                            NotesKeypadView { note in viewModel.toggleNote(note) }
                                .frame(maxWidth: .infinity)

                            KeypadView(
                                onNumberTap: { viewModel.enterNumber($0) },
                                selectedValue: viewModel.selectedCellValue
                            )
                            .frame(maxWidth: .infinity)

                            Spacer(minLength: 0)
                        }
                        .frame(height: 180)
                        .background(Color.white.opacity(0.1))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                
            
            // MARK: - Реакция на проигрыш
            .onChange(of: viewModel.isGameOver) { _, newValue in
                print("🔥 isGameOver changed to \(newValue)")
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
            
            // MARK: - Реакция на победу
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
            
            // АЛЕРТЫ победы/проигрыша
            .overlay(
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
            )
            
            .padding()
            .navigationTitle("Игра")
            .tint(Color("ButtonPrimary"))
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                viewModel.saveGame() // ← сохраняем прогресс при выходе
            }
        }
    }
    // MARK: - Перезапуск игры
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
        playerProgressManager: PlayerProgressManager.shared,
        path: .constant(NavigationPath())
    )
}
