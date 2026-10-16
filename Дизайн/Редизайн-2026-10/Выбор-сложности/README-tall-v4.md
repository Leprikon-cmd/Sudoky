# Читаемость выбора сложности — 15 октября 2026

Готовый фон: `../../Фоны/difficulty_path_background_tall_v4.png`.
Размер 852 × 1846. Исходник v3 сохранён без изменений.

По указанию владельца зелёное дерево «Мастер» и оранжевое дерево «Сенсей»
сдвинуты влево, чтобы освободить колонку для увеличенных подписей.
Остальные деревья, мини-доски, Фудзи и общий стиль сохранены.
Текста в PNG нет — подписи остаются локализованными элементами SwiftUI.

Способ: встроенный imagegen, редактирование существующего фонового PNG.
Задание генератору (финальный prompt):

Use case: precise-object-edit. Edit target: the provided tall 852 x 1846 pixel background illustration for an existing iPhone Sudoku difficulty selector. Preserve its exact 852:1846 aspect ratio and all original composition, palette, old warm paper, detailed ink-brush mountains, winding path, five trees, Mount Fuji, back-arrow circle and five aligned 3x3 mini boards. This is a surgical UI readability correction, NOT a new illustration. Move ONLY the THIRD tree (large green bonsai, Master, currently crown spans x approximately 290–595 at y780–970) and the FOURTH tree (orange bonsai, Sensei, currently crown spans x270–595 at y1090–1270) approximately 100 original-image pixels to the LEFT, keeping their vertical positions, scale, silhouette, shape and colors. Move their immediate rock bases to support each tree naturally and seamlessly repair the exposed old locations with quiet light parchment/mist. Their crowns must end at x<=490, leaving a clear pale quiet text area from x500 to690 at those two levels. Keep the original narrow winding path naturally connected. Do not change the other three trees, the left-edge mountains, Fuji, upper-left back button, or ANY of the five mini-board positions, sizes, cell borders or filled-cell patterns. Board rectangles must remain exactly at normalized left .818075, width .132629, height .061213; tops .122427, .265980, .442578, .623510, .810401. Do NOT add text, labels, numbers, UI panels, outlines or extra objects. Output the complete background only, no phone frame, no mockup. The rest of the image must remain as close as possible to the original.

Перед подключением проверить координаты досок по фактическому PNG.
Код: колонку текста приблизить к доскам, увеличить названия и описания,
проверить RU/EN и метрики поддерживаемых шрифтов. Игровая механика прежняя.
Компиляция без запуска; исключение симулятора для горшков сюда не переносится.
