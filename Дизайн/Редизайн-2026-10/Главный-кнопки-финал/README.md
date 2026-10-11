# Финальные кнопки главного — RD-01C

11 октября 2026. Владелец принял ступени и кисть с чернильницей, разрешил интеграцию («делаем»).
Созданы навыком imagegen через встроенный image_gen: три PNG RGBA 1983×793, прозрачный внешний фон, бумага внутри. Исходники сохранены здесь вне Assets; импорт — разработчиком. Старые ресурсы не удалять.

| Надпись RU | Надпись EN | Рисунок / файл |
| --- | --- | --- |
| Продолжить путь | Существующий перевод start.resume | Переиспользовать home_button_new_path, дорога с горой |
| Новая партия | New Game | home_button_new_game_v1.png, росток |
| Ступени мастерства | Steps of Mastery | home_button_mastery_v1.png, три ступени |
| О проекте | Существующий перевод settings.about | home_button_about_v1.png, кисть с чернильницей |

При alpha ≥32 видимые границы (правый/нижний предел исключён):
- new_game: x=130…1853, y=210…588 (1723×378).
- mastery: x=131…1852, y=210…588 (1721×378).
- about: x=131…1852, y=210…588 (1721×378).
- continue / существующая new_path: x=131…1852, y=210…588 (1721×378).

Сохранить пропорции, общую видимую ширину, единую левую линию живого текста после рисунка. Не растягивать PNG по осям, не масштабировать всю кнопку до размеров прозрачного холста. Едва прозрачные внешние артефакты исключать областью отображения; исходные PNG не переписывать. Для новых названий допустим перенос, не обрезать текст. Изображения просмотрены, alpha/размеры программно проверены. UI лично принимает владелец.

Область RD-01C: метрики/выбор artwork в StartView, импорт трёх PNG, значения start.newGame/start.stats в RU/EN (start.stats также заголовок статистики). Действия кнопок, hasSave, managers, механика, XP, сохранения и About-тексты неизменны. Одна успешная Debug-компиляция без запуска, без симуляторов, без несвязанных тестов. Далее ждать приёмки.

## Промпты встроенной генерации

### new_game

Use case: precise-object-edit. Asset type: ONE production game UI button PNG with transparent exterior and no text.
Input images: Image1 is the edit target — existing horizontal rice-paper button. Image2 is ONLY pictogram style/subject reference, not a layout to reproduce.
Primary request: Change ONLY the existing mountain-and-road pictogram at the left of image1 into the TWO-LEAF SPROUT inside an open Enso brush circle from reference image2 row3 column2. Keep the two olive leaves, simple stalk and small ground mark. No pot.
Invariants: Preserve the original rounded rectangular paper tile, thin double gold-sepia contour, warm pale paper texture, tile proportions and position, subtle edge depth and all blank space to the right. Keep canvas around 1983x793 with the tile visible approximately x131..1852,y210..588. New circular pictogram should occupy approximately x230..475,y274..517, same optical size/position as original. The ring must be a broad softly irregular dry-brush open circle, keep it exactly round and inside the button. The right 75% of the tile is blank for live localized UI text added later.
Constraints: single button only, no captions, no text, no numbers, no label, no contact sheet, no watermark. Genuinely transparent background OUTSIDE the rounded tile, preserve opaque pale paper INSIDE the tile including ring interior. Do not add full-canvas parchment backdrop, black background, checkerboard pattern or white rectangle. No changes to button body/geometry except replacing its left pictogram.

### mastery

Use case: precise-object-edit. Asset type: ONE production game UI button PNG with transparent exterior and no text.
Input images: Image1 is the edit target — existing horizontal rice-paper button. Image2 is ONLY pictogram style/subject reference, not a layout to reproduce.
Primary request: Change ONLY the existing mountain-and-road pictogram at the left of image1 into the THREE ASCENDING STONE STEPS inside an open Enso brush circle from reference image2 BOTTOM LEFT. Exactly three simple separate horizontal stone steps from lower-left to upper-right, warm sepia, no mountain/path/sprout.
Invariants: Preserve the original rounded rectangular paper tile, thin double gold-sepia contour, warm pale paper texture, tile proportions and position, subtle edge depth and all blank space to the right. Keep canvas around 1983x793 with the tile visible approximately x131..1852,y210..588. New circular pictogram should occupy approximately x230..475,y274..517, same optical size/position as original. The ring must be a broad softly irregular dry-brush open circle, keep it exactly round and inside the button. The right 75% of the tile is blank for live localized UI text added later.
Constraints: single button only, no captions, no text, no numbers, no label, no contact sheet, no watermark. Genuinely transparent background OUTSIDE the rounded tile, preserve opaque pale paper INSIDE the tile including ring interior. Do not add full-canvas parchment backdrop, black background, checkerboard pattern or white rectangle. No changes to button body/geometry except replacing its left pictogram.

### about

Use case: precise-object-edit. Asset type: ONE production game UI button PNG with transparent exterior and no text.
Input images: Image1 is the edit target — existing horizontal rice-paper button. Image2 is ONLY pictogram style/subject reference, not a layout to reproduce.
Primary request: Change ONLY the existing mountain-and-road pictogram at the left of image1 into the BAMBOO CALLIGRAPHY PAINTBRUSH with small INK POT inside an open Enso brush circle from reference image2 TOP LEFT. Keep diagonal bamboo handle from upper-right to lower-left and tapered dark bristle tuft, ink pot at lower-right; no quill or feather.
Invariants: Preserve the original rounded rectangular paper tile, thin double gold-sepia contour, warm pale paper texture, tile proportions and position, subtle edge depth and all blank space to the right. Keep canvas around 1983x793 with the tile visible approximately x131..1852,y210..588. New circular pictogram should occupy approximately x230..475,y274..517, same optical size/position as original. The ring must be a broad softly irregular dry-brush open circle, keep it exactly round and inside the button. The right 75% of the tile is blank for live localized UI text added later.
Constraints: single button only, no captions, no text, no numbers, no label, no contact sheet, no watermark. Genuinely transparent background OUTSIDE the rounded tile, preserve opaque pale paper INSIDE the tile including ring interior. Do not add full-canvas parchment backdrop, black background, checkerboard pattern or white rectangle. No changes to button body/geometry except replacing its left pictogram.

