# Три варианта — 13 октября 2026

По заданию владельца: два увеличенных А, один увеличенный Б.
Созданы отдельными image_gen-редактированиями, без подключения в приложение.

- A1-без-рамки.png: сетка/цифры почти на всю ширину и высоту.
- A2-тонкая-рамка.png: тот же крупный А с тонкой деревянной кромкой.
- B-увеличенная-доска.png: увеличенная квадратная доска с узкими полями;
  углы ближе к дугам внешнего контура, но не совпадают с ним.

Пять цифр и их позиции визуально сверены. Каждый лист показывает большой
и уменьшенный вариант. Это художественные референсы, не реальный iOS-рендер,
не гарантированные пиксельные размеры/точная системная маска.
Особенно A2 нельзя экспортировать в AppIcon как crop этого мокапа:
контур финальной рамки требуется построить по официальному шаблону Apple.
https://developer.apple.com/design/resources/

Подключённый AppIcon остался побайтно прежним (v3), проект не собирался,
поскольку изменения только в исходном дизайне.
Предыдущие варианты и референсы сохранены.

## Промпт А1

Use case: precise-object-edit. Input image is edit target, existing presentation of Sudoku icon variant A. Keep neutral gray presentation with one large icon on left and same design smaller on right with Russian label 'Судоку'. Change heading to 'А1 — Без рамки'. ENLARGE the Sudoku grid and ALL FIVE NUMERALS substantially in BOTH icons: grid spans about 90% of the icon width AND 90% height, only narrow 5% edge breathing room, NOT the old 72% small central symbol. Four divider lines extend close to outer edges; no outer rectangle, no wooden frame, no drawn rounded outline. Keep the exact same five numeral positions top [empty,3,empty], center [1,4,empty], bottom [empty,8,6]. Larger bold elegant sepia serif digits, height around 22% of whole icon; fully visible inside cells, especially 6 bottom right clear of curved crop. Nine equal cells, exact horizontal/vertical alignments. Warm ivory rice paper full bleed, very subtle texture, no orange burn, no decoration. Maintain one iPhone-style outer silhouette without adding an inner contour. This is a conceptual comparison reference, not a screenshot. Right icon must use IDENTICAL enlarged proportions. Dramatically reduce empty margins compared with reference.

## Промпт А2

Use case: precise-object-edit. Input image: edit target showing enlarged Sudoku icon A1, large on left and same small on right on gray background. Create variant 'А2 — Тонкая рамка'. Preserve this enlarged grid and bold numeral scale nearly to icon edges, same paper and all EXACT digits top [empty,3,empty], center [1,4,empty], bottom [empty,8,6]. Add an EXTREMELY THIN dark walnut wood edging that follows the ENTIRE OUTER ICON SILHOUETTE, consistent width about 2% of icon size. The icon's outer visible shape itself is the wood edge. NO separate rounded rectangle inside, NO paper margin outside wood, NO conflicting corner arcs, NO short straight frame parts cut off at corners. Wood edge is continuous through all four smooth iPhone-style corner curves, visually flush to the outer boundary, slight natural walnut grain, restrained flat satin treatment, no thick bevel. Paper and nine grid cells fill all remaining interior. Four grid dividers meet wood edging; actual cell proportions remain equal except outer silhouette rounds the blank outer corners. Numeral 6 fully visible away from curve; do not shrink all artwork to create broad margins. Icon fills same bounds as A1. Produce same reference presentation with large icon left and smaller identical icon right, label 'Судоку'. Do not change background or add extra icons. This is a conceptual appearance reference, not a verified OS mask export.

## Промпт Б

Use case: precise-object-edit. Input image edit target is Sudoku variant B reference presentation: large icon left, same smaller icon right, gray background. Make revised 'Б — Увеличенная доска'. Significantly ENLARGE the interior square wooden Sudoku board to about 84% of whole icon width AND height; paper margins only about 8% per side, NOT old 16%. The FOUR SQUARE MITERED CORNERS of board approach the central portions of the four outer icon corner arcs, with just a small visible paper clearance; board fully visible, none of corners cut. Keep outer iPhone-style continuous rounded-square silhouette as in reference. Inner board corners stay sharp 90-degree mitered, NOT another rounded rectangle. Thin dark walnut wood frame around board, width approx 1.4% of whole icon, restrained grain and no thick bevel. Grid inside is precise 3x3, four slim sepia dividers. All five numbers EXACT SAME POSITIONS top [empty,3,empty], center [1,4,empty], bottom [empty,8,6]. Increase numerals along with board: bold elegant sepia serif, roughly 20% whole icon height, same readable strength as new variants A. Keep pale warm rice paper with subtle texture, no orange burn. Both large and small previews must show this much larger board, nearly filling icon with only small corner-safe gap. Heading 'Б — Увеличенная доска', right label 'Судоку'. No additional graphics, icons, labels, trees, flowers or shadows outside presentation. Conceptual design reference, not an OS mask verification.
