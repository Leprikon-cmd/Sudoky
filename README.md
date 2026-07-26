# Судоку. Путь мудреца

Спокойная офлайн-игра Sudoku для iPhone и iPad, созданная без рекламы,
встроенных покупок, аналитики и сбора персональных данных.

Проект сочетает классические правила Sudoku с атмосферой восточной мудрости,
собственным визуальным оформлением, музыкой и системой прогресса игрока.

## Основные возможности

- головоломки с единственным решением;
- несколько уровней сложности;
- заметки и подсветка одинаковых цифр;
- проверка ошибок и система жизней;
- сохранение незавершённой партии;
- статистика прохождений;
- опыт и уровни игрока;
- выбор оформления, цвета текста и шрифта;
- фоновая музыка;
- работа без подключения к интернету;
- локализации на русском и английском языках;

## Технологии

- Swift;
- SwiftUI;
- MVVM;
- AppStorage;
- NavigationStack;
- XCTest и XCUITest.

Минимальная версия системы, указанная в проекте: iOS/iPadOS 18.4.

## Структура проекта

```text
Sudoky/
├── Sudoky.xcodeproj
├── Sudoky/
│   ├── Models/
│   ├── ViewModels/
│   ├── Views/
│   ├── Services/
│   ├── Helpers/
│   ├── Assets.xcassets/
│   ├── Audio/
│   ├── Шрифты/
│   └── Проектная документация/
├── SudokyTests/
└── SudokyUITests/
```

Основные компоненты:

- `SudokuGenerator` — создание головоломок и проверка уникальности решения;
- `SudokuViewModel` — состояние и управление игровой сессией;
- `GamePersistenceManager` — сохранение текущей партии;
- `SettingsManager` — пользовательские настройки;
- `StatsManager` — статистика;
- `PlayerProgressManager` — опыт и прогресс игрока;
- `LanguageManager` — выбор языка;
- `FontManager` — управление пользовательскими шрифтами;
- `MusicManager` — воспроизведение фоновой музыки.

## Запуск

1. Откройте `Sudoky.xcodeproj` в Xcode.
2. Выберите целевое устройство или симулятор с iOS 18.4 или новее.
3. Запустите схему `Sudoky`.

## Тесты

В проект включены:

- модульные тесты приложения;
- тесты генератора Sudoku;
- UI-тесты.

Их можно запустить в Xcode командой **Product → Test**.

## Документация

- [Контекст проекта](Sudoky/Проектная%20документация/Контекст%20проекта.md)
- [Политика конфиденциальности](Sudoky/privacy_policy.md)

## Принципы проекта

- уважение к игроку;
- отсутствие рекламы и навязчивой монетизации;
- локальное хранение прогресса;
- полная офлайн-работа;
- спокойный и выразительный интерфейс;
- минимальное количество лишних действий.

## Авторство

Идея и реализация — **Евгений Зотчик (Leprikon)**.

Музыка — **Anna Aurnis (Aurnis Luthael)**.

При создании проекта также использовались AI-инструменты ChatGPT, Шедеврум
и DeepSeek.

## Конфиденциальность

Приложение не собирает, не хранит и не передаёт персональные данные.
Настройки и игровой прогресс сохраняются только на устройстве пользователя.

---

## English summary

**Sudoku. Path of the Sage** is a calm, fully offline Sudoku game for iPhone
and iPad. It contains no advertising, in-app purchases, analytics, or personal
data collection.

The app includes uniquely solvable puzzles, multiple difficulty levels, notes,
mistake checking, game saves, statistics, player progression, custom fonts,
visual themes, background music, and several interface languages.

The project is built with SwiftUI using an MVVM-based architecture.
