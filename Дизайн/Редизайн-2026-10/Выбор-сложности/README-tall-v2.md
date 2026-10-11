# Высокий фон выбора сложности — v2

11 октября 2026. Владелец подтвердил работу RD-02B и попросил заполнить
высоту экрана рисунком, увеличив отступы между выборами и длину дороги.

Файл: `difficulty_path_background_tall_v2.png`, 852×1847 px, непрозрачный PNG.
Соотношение сторон близко к 1179×2556 из снимка владельца.
Подготовлен встроенным imagegen из утверждённого фона без текста.
Пять ступеней и пять мини-досок сохранены, промежутки и дорога дорисованы.
Это новая композиция, а не побайтовое расширение оригинала: деревья,
мини-доски и стрелка получили новые координаты. Надписей в изображении нет.

Статус: арт передан на утверждение; в Assets и приложение пока не подключён.
Старый фон сохранён. Исходники приложения не менялись, сборка не требуется.

При подключении разработчик должен заново определить относительные зоны
текстов и нажатий по этому файлу. Не использовать координаты README.md
для старого холста 1024×1536. Не растягивать по независимым осям.
Обеспечить согласованное масштабирование рисунка, живых текстов и кнопок,
сохранив RU/EN и запуск существующих сложностей. Визуальная приёмка владельцем,
без использования симуляторов агентами.

## Промпт генерации

```text
Use case: precise-object-edit. Asset type: full-height opaque mobile game background illustration WITHOUT any text. Image 1 is the edit target, an approved difficulty-selection artwork. Recompose/extend this SAME artwork to a much taller portrait canvas with width:height 1024:2220 (approximately 9:19.5), not the original 2:3. Main requested change: create more vertical space BETWEEN the five difficulty stations and lengthen the winding mountain road connecting them. Draw extra cliff scenery and textured paper between existing stations so the artwork fills an entire tall iPhone screen, rather than adding empty flat strips or stretching objects. Preserve the exact warm parchment texture, Japanese woodblock/ink illustration style, sepia cliffs, olive foliage, orange-red leaves, and delicately drawn pagodas. Preserve exactly FIVE station subjects in top-to-bottom order: small two-leaf sprout, small olive green bonsai, larger olive green bonsai, orange autumn bonsai, old leafless gnarled tree on a cliff. Keep each tree's identity, horizontal position and size as close as possible to input; only redistribute vertical spacing. Preserve exactly FIVE upright square 3x3 mini Sudoku grids, one to the right of each corresponding tree. Grid olive square patterns must remain exactly: station1 seven olive cells (top row3, middle row3, lower left1); station2 five cells (top3,middle left2); station3 three cells(top left2,middle left1); station4 two cells(top left and center); station5 one cell(top left). Do not stretch trees or grids; each grid must remain a precise square with nine square cells. Layout full-height canvas: top 0-9% mostly softly textured parchment for status bar and native heading; back circle/left chevron at x0.105 y0.080 (same brush style). Station sprout and its grid around y0.205; small bonsai/grid around y0.365; large bonsai/grid around y0.535; orange bonsai/grid around y0.700; bare old bonsai/grid around y0.865. Leave clean light parchment areas between each tree and its grid to overlay native names/descriptions later, preserving original staggered horizontal arrangement. Make road between stations genuinely longer with additional bends through continuous mountain cliffs, not just vertical scaling. Bottom 5% continues landscape naturally all the way to the edge, suitable for home indicator. Full bleed opaque art edge-to-edge; NO blank top/bottom bands. Invariants: exactly five tree stages and five mini-grids, no extra trees serving as stages, no new UI controls, no text, no letters/numbers, no labels, no title, no statusbar, no device frame, no watermark. Do not add a sixth stage. This is a production art asset, not a screenshot.
```
