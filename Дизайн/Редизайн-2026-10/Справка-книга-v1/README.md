# Основа буклета «Как устроен сад мудреца» — 12 октября 2026

garden_help_book_right_v1.png — подготовлен встроенным imagegen, отдельный
исходник, старый пергамент не перезаписан. PNG 987×1593 RGBA, alpha 0…255.
Видимые границы alpha>=32: (34,56)…(958,1545), правый/нижний предел исключён.
Правый лист открытой книги с узким корешком слева. Без запечённого текста.

Координаты относительно всего PNG: безопасное поле для живого текста
x=0.16…0.90, y=0.075…0.92. Номер страницы вверху справа внутри этого поля;
его высоту исключать из текстовой области. Размеры картинки и текста должны
выводиться из одного фактически отображаемого image rect, scaledToFit.
Не растягивать по осям. Прозрачные поля не являются полями для текста.

## Финальный промпт (встроенная генерация, не CLI)

Use case: stylized-concept. Asset type: production transparent PNG book right-page background for an iPhone instruction booklet, not a phone mockup. Primary request: a single blank RIGHT-HAND leaf of an open old Japanese sage's book viewed perfectly straight from above, portrait proportions approximately 0.62 width to height. The narrow book gutter/spine is visible along the LEFT edge only, about 7 percent of width, dark warm sepia binding with subtle fine stitches and curved paper shading. The remaining 93 percent is one very large FLAT pale ivory rice-paper writing surface, calm subtle grain, opaque paper. Thin stacked page edges at right and bottom, restrained warm brown cloth cover just peeking behind. Outer shape almost rectangular with gently rounded worn corners, NOT ripped or burnt parchment. Hand-painted watercolor and sepia ink illustration matching a peaceful Japanese mountain bonsai game. Very subtle cast shadow at outside edges. The blank page fills at least 94% of canvas height and 94% width with small equal transparent margins. Keep x=0.16..0.91 and y=0.07..0.93 uniformly light and blank for live body text. No text, no letters, no page numbers, no icons, no flowers, no trees, no bookmark, no ornaments on the writing surface. No perspective tilt, no whole two-page spread, no left page visible, no table, no scene, no hands, no UI or phone frame, no watermarks. Genuine transparent alpha outside the book, with opaque cream paper within.
