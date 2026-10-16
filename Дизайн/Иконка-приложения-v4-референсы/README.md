# Форма иконки и референсы — 13 октября 2026

V3 отклонена владельцем: деревянные углы срезаны системной маской.
Новые варианты в AppIcon НЕ подключать без отдельного утверждения.
Действующая иконка не менялась этим этапом.

## Фиксируем контракт

Исходник приложения: квадрат 1024×1024. В текущем PNG-пути — непрозрачный.
Внешнее скругление выполняет iOS. Не запекать собственную форму иконки,
не вырезать прозрачные углы, не подбирать произвольный cornerRadius.
Для точной внешней маски использовать официальные шаблоны Apple или
системное представление, не маску, нарисованную генератором.

Официальные источники проверены:
https://developer.apple.com/design/human-interface-guidelines/app-icons
https://developer.apple.com/documentation/xcode/configuring-your-app-icon
https://developer.apple.com/design/resources/

Apple задаёт форму исходника и системную маску, а не обязательную деревянную
рамку или универсальный отступ 16%. Отступы ниже — наша дизайн-композиция.
В угловой зоне оставлять только фон, всю смысловую графику держать внутри.
Пять цифр и позиции неизменны: [пусто,3,пусто]/[1,4,пусто]/[пусто,8,6].

## Два направления

A-без-рамки.png: центральная сетка без внешнего контура, крупные цифры.
B-доска-внутри.png: отдельная квадратная доска с тонким деревом и широкими
полями вокруг, углы доски не совпадают с углами внешней иконки.

Это image_gen-референсы композиции в большом и уменьшенном виде,
НЕ экспорт системной маски Apple, НЕ снимки iPhone и НЕ готовые AppIcon.
Уменьшенный рисунок в сгенерированной презентации не доказывает размер в pt.
Перед внедрением выбранного направления подготовить отдельный квадратный
исходник и проверить его по официальному шаблону/системному предпросмотру.
Не заменять точную проверку ещё одной приблизительной AI-маской.
Сборка не выполнялась: код и подключённые ресурсы не менялись.

## Промпт A

Use case: ui-mockup. Produce one LANDSCAPE design reference board for variant A of a Sudoku iPhone home-screen icon, not an installable asset, not a phone screenshot. Neutral cool gray background. On left show one enlarged iPhone-style rounded-square icon about 350px wide. On right show the SAME icon much smaller about 90px wide with white Russian label 'Судоку' underneath, like home screen scale. Variant A artwork: full-bleed smooth warm ivory rice paper, subtle texture, NO outer frame, NO rounded outline inside icon. Clean dark sepia Sudoku 3x3 symbol occupying central 72% square of icon, with only two thin horizontal and two thin vertical lines, no outer border. All lines and all digits end comfortably inside that central square, away from outer icon corners. EXACT digits layout row1 [empty,3,empty], row2 [1,4,empty], row3 [empty,8,6]. Bold elegant readable serif numerals, high contrast, ample room, five digits only. No decorations, trees, enso, badges, glows, extra numbers. Outer silhouette in preview represents iPhone icon shape; no second competing rounded rectangle. Heading at top 'A — Без рамки'. Show the real small rendering reference, not only enormous art. Same icon artwork and number positions at both scales. Calm refined game parchment style. NO wooden outline of any kind in this variant.

## Промпт B

Use case: ui-mockup. One LANDSCAPE design reference board for variant B of a Sudoku iPhone home-screen icon, not production icon, not phone screenshot. Neutral cool gray background. Left: enlarged iPhone-style rounded-square icon. Right: SAME icon about one quarter its size, compact home-screen style with white label 'Судоку'. Heading 'B — Доска внутри'. Artwork: warm smooth ivory paper extends full bleed to icon silhouette. In its CENTER, a SMALL SEPARATE SQUARE SUDOKU BOARD occupies ONLY 68% of total icon width and height. Visible pale paper margin of 16% on ALL FOUR SIDES around the entire board, unmistakably inset, do not let board touch icon silhouette or corners. Thin narrow dark walnut WOOD FRAME around this interior board, straight sides and SQUARE 90-DEGREE mitered corners, NOT rounded corners, no inner squircle. Wood about 2% of entire icon width, understated wood grain and tiny bevel, thin not chunky. The whole board including all four square corners stays deeply inside the icon silhouette. Grid precise 3x3, thin sepia dividers; five bold elegant dark serif digits EXACTLY: top row [empty,3,empty], middle [1,4,empty], bottom [empty,8,6]. Numerals large within board cells and readable at small scale. Blank other cells, no additional numerals. Strong contrast. No decorations, glows, flowers, extra border following icon edge, perspective, or circular outlines. TWO displays of this ONE variant at different sizes on one comparison board. Essential: inner board must be centered, visually smaller than icon with wide margins; square wood frame corners never coincide with the outer curved mask.
