# Фон v6 — росток ниже

15 октября 2026. Точечное уточнение владельца по красной разметке: перенести росток на следующую площадку дороги ниже. Локализованные надписи, доски и области нажатия не меняются. Исходник v5 сохранён.

Новый файл: `../../Фоны/difficulty_path_background_tall_v6.png`.
Встроенный imagegen, редактирование существующего изображения. Первые три
попытки отклонены из-за неверной высоты. Выбран четвёртый вариант с первой
площадкой сразу под исходными камнями. Холст 853×1844.
Финальная визуальная проверка — владелец, без симулятора.

## Prompts

### Выбранный итоговый prompt (от исходного v5)

Edit this illustration very locally. The tiny green seedling at the top left should stand on the FIRST pale roadside ledge immediately BELOW its current boulders, inside the first upper hairpin bend. Move it down only a little: its leaves should be level with the top edge of that pale ledge, and roots on that ledge. Do NOT place it near the second hairpin, and do NOT place it near the first mature green bonsai. It must remain high in the picture, just underneath its original rock mound. Preserve its original size and two leaves. Remove it from the old position. Keep the remainder of the illustration exactly unchanged. Same full canvas, no cropping, no text or UI.

### Исходное перемещение

Use case: precise-object-edit. Edit target: the supplied clean tall background for the Sudoku difficulty screen, 853 by 1844 pixels. Make ONLY this tiny localized change: move the small two-leaf seedling currently centered around x90,y224 DOWN about 105 pixels, to the little pale rocky roadside terrace centered around x98,y330. Keep its exact two leaves, size, silhouette, ink illustration style and mossy planting base. Its roots/base should now sit around x98,y365 instead of y260. Cleanly restore the former seedling location with the existing distant mountains/mist. Keep the winding path coherent; seat the lowered seedling on the edge of its little rock terrace, not floating over the path. All other trees, rocks, mountains, Fuji, paper texture, palette and composition must remain unchanged. No red circles/arrows/markup, no UI, no text. Preserve exact original canvas dimensions and full framing. Do not redesign or add anything.

### Уточнение 1

Use case: precise-object-edit. The current edit placed the seedling TOO LOW. Move ONLY the small two-leaf seedling with its tiny planting base UP exactly 85 pixels from its current location (currently leaves at y380, roots y440). Desired final leaves top around y290, roots/base around y355 on the pale roadside terrace at x95. This is still lower than its original y195 position, but NOT near the large green second tree. Restore its present abandoned spot cleanly as rock/path. Preserve the exact 853x1844 canvas, every other pixel composition, all other trees, road, Fuji, colors and textures. No marks, text or UI.

### Уточнение 2

undefined

