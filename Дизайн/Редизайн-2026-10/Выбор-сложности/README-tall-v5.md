# Фон v5 и прозрачный возврат — 15 октября 2026

Фон: `../../Фоны/difficulty_path_background_tall_v5.png`.
Кнопка: `../../Кнопки/nav_back_brush_transparent_v3.png`.
Созданы встроенным imagegen редактированием прежних PNG; прежние варианты сохранены.
Фактический размер результата фона 853×1844 (исходник/prompt 852×1846);
при размещении использовать реальные пропорции, файл не растягивать.
Фон не содержит интерфейсных элементов. Все пять досок/тексты/нажатия
размещаются общим SwiftUI-макетом поверх одного фонового изображения.

## Prompt фона

Use case: precise-object-edit. Edit target: supplied 852x1846 tall old parchment landscape for an existing Sudoku difficulty screen. Make a careful composition revision, NOT a different illustration. Keep the same five trees in order and same approximate vertical levels: tiny green sprout at y230, small green bonsai at y550, larger green bonsai at y880, orange bonsai at y1200, ancient bare bonsai at y1540. Keep all five trees recognizable, the ink-brush linework, warm pale aged paper, winding mountain road and Mount Fuji in the lower right. Shift the decorative landscape as a whole about 75 original-image pixels LEFT by trimming some of the repetitive far-left cliff and conifers. This should make ALL tree crowns finish before x450 and leave a wider calm pale paper area from x460 to the right edge for readable UI. Do not squeeze or distort tree shapes. Restore naturally exposed mist/path where needed, keep road connecting five stations. IMPORTANT remove the drawn circular back arrow at upper left AND remove ALL FIVE 3x3 mini boards: fill their former areas seamlessly with matching light parchment. No UI is baked into this new background: NO buttons, squares, boards, icons, letters, numbers, labels, panels, status bar, or text. The top 150px should be continuous calm paper/mist without any horizontal seam or repeated strip. Preserve the tall 852:1846 portrait ratio and overall style, avoid duplicated mountain motifs, no pagodas or extra flowers. Full image background only, opaque.

## Prompt прозрачной кнопки

Use case: background-extraction. Edit target: the provided existing 1254x1254 navigation icon. Remove ONLY the pale cream parchment/paper filling from inside the brush circle, making it genuinely fully transparent alpha. Preserve the existing dark warm-sepia rough dry-brush circle and the left-pointing hand-painted '<' chevron, their positions, stroke texture, scale, shapes, and all fine brush edges. The area inside the circle but not occupied by ink must be transparent, same as outside the circle. No white or beige disk, no paper texture, no checkerboard baked into pixels, no shadows, no added elements, no redesign. Maintain the square 1254x1254 canvas and the original generous transparent edge margins. Output a real transparent RGBA PNG with just the circle and arrow ink.
