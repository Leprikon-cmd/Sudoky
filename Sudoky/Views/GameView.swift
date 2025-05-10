//  GameView.swift
//  Sudoky

import SwiftUI

struct GameView: View {
    let difficulty: Difficulty                        // Уровень сложности
    let statsManager: StatsManager                    // Менеджер статистики
    @Binding var path: NavigationPath                 // Навигационный путь (Stack)

    @StateObject private var viewModel: SudokuViewModel  // ViewModel игры
    @State private var showWinAlert = false               // Флаг победного алерта
    @State private var showLoseAlert = false              // Флаг проигрышного алерта

    // MARK: - Инициализация
    init(difficulty: Difficulty, statsManager: StatsManager, path: Binding<NavigationPath>) {
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
                // Если игрок победил или проиграл — удаляем сохранение, оно больше не нужно
                if viewModel.isGameWon || viewModel.isGameOver {
                    GamePersistenceManager.shared.clear() // 🧹 Удаляем сохранённую игру
                } else {
                    // Иначе — сохраняем текущее состояние
                    viewModel.saveGame() // 💾 Сохраняем текущий прогресс
                }
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
        path: .constant(NavigationPath())
    )
}
