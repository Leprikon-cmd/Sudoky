# Яблоня — очистка прозрачности и восстановление горшка

APPLE-ALPHA-ANCHOR, 15 октября 2026.

Владелец сообщил о прозрачности и посадке. Подключённые исходники Aligned
содержали белые ореолы, непрозрачные белые просветы кроны и срезанный низ горшка.
Созданы 10 новых RGBA PNG 1254×1254 через встроенный imagegen; старые исходники
Дизайн/Сад/Яблоня и Bonsai_All_30_Aligned/Apple сохранены без изменений.
Это восстановительные редактирования, не побайтовая коррекция alpha: мелкие
детали рисунка могли измениться, требуется личная художественная приёмка.

Для каждой стадии — отдельный вызов imagegen, не CLI/API. У стадий 04–06
вторая очистка оставшихся белых участков. Положение/основание горшка
измеряется по плотному контуру, а не bbox(alpha>0), поскольку остаются
слабые полупрозрачные краевые пиксели. Не удалять белые цветы пороговым фильтром.

## Основной prompt для каждой стадии NN

Use case: background-extraction / precise-object-edit. Edit target: supplied existing approved apple bonsai stage. Clean up the cutout WITHOUT redesigning the artwork. Remove the opaque WHITE background residue: white halo around the leaves/branches/trunk/pot, and all white negative-space pockets BETWEEN the branches and leaves. Those gaps must become true alpha transparency, not white, black or checkerboard. Preserve the actual pale blossoms, pale leaf details, bark highlights, moss, fruit and blue-grey ceramic pot. Keep stage, silhouette, exact branch arrangement, colors and texture. Repair ONLY the truncated bottom of the pot into a complete naturally rounded ceramic base, no missing bottom or flat cut edge; keep it centered horizontally. Preserve 1254x1254 canvas, existing tree scale and placement. Bottom-center contact point of finished solid pot must be x627,y1204 with transparent margin below. Pot opaque, foliage opaque; transparent only outside objects and in natural gaps. No new objects, no cast shadow, no ground, no text, no background. Output genuinely RGBA transparent PNG. This is stage NN; do not advance its growth.

## Дополнительный prompt стадий 04–06

Use case: background-extraction. Edit this already transparent bonsai cutout. It STILL has opaque blank white patches trapped between the leaves and branches. Remove those leftover WHITE BACKGROUND POCKETS throughout the crown, including enclosed pockets beside the main fork and upper outer leaves. Make actual alpha holes there. Also remove pale/colored edge fringe and any ground shadow below pot. Preserve actual white/pink FLOWER PETALS, pale patterned leaf surfaces, ceramic pot and every real object. Do not delete the blossoms. No repaint, no new foliage, no color change, no added background. Keep exact canvas and tree position. Entire pot, including feet, solid opaque; background and holes fully transparent. This is precision alpha cleanup only.

## Файлы генерации выбранных вариантов

- Apple_Stage_10.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-9a13a986-37d1-4854-b983-276a69f6f9af.png
- Apple_Stage_01.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-b70e67df-bdbe-4745-8ad2-b03f28fab7b7.png
- Apple_Stage_02.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-b22b33ee-17cd-4b2e-90ad-4176123bc739.png
- Apple_Stage_03.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-f04e89c4-1484-4092-83c3-bf0e17748d41.png
- Apple_Stage_04.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-acb81920-2742-46f8-87a8-bbb8a29364eb.png
- Apple_Stage_05.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-0a759e66-5779-4314-ae73-0e8d96cb1813.png
- Apple_Stage_06.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-fac9ca0d-a44f-4fd7-81b1-4c4d29910b3d.png
- Apple_Stage_07.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-3522a8a3-5a49-484f-a6bb-c98874c1c1aa.png
- Apple_Stage_08.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-37cb0719-ef93-40b4-855c-95d4d751b738.png
- Apple_Stage_09.png — /Users/zotchik/.codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef/exec-29dc826d-d15d-4546-8cd0-8f0662d9236a.png

