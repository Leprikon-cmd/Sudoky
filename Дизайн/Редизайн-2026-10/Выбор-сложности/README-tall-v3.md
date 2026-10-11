# Высокий фон выбора сложности — v3

11 октября 2026. Корректировка по разметке владельца.

`difficulty_path_background_tall_v3.png` — чистый фон без текста и разметки,
подготовлен встроенным imagegen. Предыдущие файлы сохранены.
Арт утверждён владельцем 11 октября: «В дело! работаем!». Выдан этап RD-02C
для подключения. Файл 852×1846 px. Подключён отдельным ресурсом
`difficulty_path_background_tall_v3`; Debug-компиляция прошла без запуска.
Ожидается визуальная приёмка реализации владельцем.

## Изменения

- Пять мини-досок расположены в одной правой колонке.
- Пагоды удалены, горные участки и растительность перерисованы без прежних
  повторяющихся декоративных цветов.
- Дерево ученика сдвинуто левее, дерево сенсея немного увеличено
  (запрошенное значение 5% — художественный ориентир, не точное преобразование).
- У Dokushin — гора с широким коническим силуэтом в стиле Фудзи.
- Сохранены пять стадий, длинная дорога, бумажная текстура и стрелка возврата.

## Привязка интерфейса после утверждения

Доски — опорные элементы для единой колонки текста и областей кнопок.
По просмотру арта примерный прямоугольник каждой доски имеет x=0.819,
width=0.133; вертикальные центры около 0.153 / 0.297 / 0.473 / 0.654 / 0.841.
Это предварительные ориентиры: разработчику уточнить границы по финальному PNG
перед подключением, не переносить координаты v1/v2.
Привязать подписи и зоны нажатия к относительной геометрии рисунка;
зона выбора охватывает соответствующую ступень, а не только мини-доску.
Шрифт, RU/EN, Dokushin и запуск существующей партии не менять.
Визуальная приёмка только владельцем, без симуляторов.

## Промпт

```text
Use case: precise-object-edit.
Asset type: opaque full-height mobile game background without any UI text, same tall 852:1847 aspect ratio as the attached image.
Input image: the most recent user-attached image is the edit target with RED EDITORIAL ANNOTATIONS. Red strokes are instructions only, REMOVE ALL red annotation lines, arrows and X marks from final art. Orange/red autumn tree leaves and orange sun are real art and must remain.
Keep the approved warm parchment Japanese woodblock/ink style, five tree identities, five 3x3 grids, long winding road, tall spacing, back arrow/circle in upper left, and blank light areas for live UI labels. Make only these requested composition corrections:
1. ALL FIVE mini Sudoku boards have the same square size, and ALL FIVE RIGHT EDGES align on one vertical line at x=94.7% of canvas width, as indicated by the user's vertical red guide. For width852 each board is approx104px square, right edge807px and left edge703px. Keep original vertical centers approximately y=.149,.315,.494,.660,.844; do not stack them closer. Specifically MOVE first board right substantially, second board right moderately, other boards slightly right, NOT keep staggered columns. Exact consistent board column is critical.
2. First board pattern seven olive cells (top3,middle3,lower left1); second five(top3,middle left2); third three(top left2,middle left1); fourth two(top left and center); fifth one(top left). Black straight outer outline, perfectly square 3x3 cells, cream unfilled cells, no numbers.
3. Move the APPRENTICE tree (second tree, the small green bonsai) a little LEFT, approximately 6% of canvas width, preserve its size, shape, vertical level and roots; repaint supporting rock naturally.
4. Enlarge the SENSEI tree (fourth tree, orange foliage) by approximately 5%, anchored at its root base. Preserve identity/color and vertical level.
5. REMOVE EVERY pagoda/building/tower/temple entirely. Replace their sites with natural rock formations, atmospheric gaps, varied cliffs or a few irregular pines.
6. REMOVE repetitive identical mountains, copy-pasted triangular peak clusters, and repeated orange star-shaped flowers along the left edge. No flower motifs at all. Left edge must still be a connected mountainous landscape but each section unique: vary geological shapes with jagged pinnacles, long weathered slabs, steep rock faces, broken strata, deep chasms and misty negative space. Natural irregular composition, not a repeated wallpaper or a rhythm of cloned triangles. Pines may exist sparingly with diverse grouping/scale, not repeated rows. Reduce clutter. Autumn leaves may remain sparingly near the autumn tree and bottom old tree but do not repeat them down the whole left side.
7. At bottom RIGHT behind the Dokushin leafless tree/last board, replace the marked jagged mountain with ONE graceful Mount-Fuji-inspired mountain: broad clean conical silhouette with gently curving slopes, slightly flattened snow-capped summit, subtle ink texture. This is the only dominant mountain in that lower-right zone, not a duplicated jagged range; keep atmospheric valley/river below. Lower mountain should stay light enough that later text is readable.
8. Preserve five progression subjects top to bottom: sprout, small green bonsai, large green bonsai, orange autumn bonsai, old bare gnarled tree on cliff. Keep road connecting all five, varied and naturally integrated; do not alter tree count, or remove back icon. Maintain warm paper texture edge to edge.
Text: absolutely none.
Avoid: red annotation strokes, guides, arrows except black back chevron, any lettering, title, captions, numbers, statusbar, phone frame, watermark, extra controls, duplicated tree stages, temples, pagodas, repetitive mountains, decorative flowers. Final output must be a clean production illustration, not annotated mockup.
```
