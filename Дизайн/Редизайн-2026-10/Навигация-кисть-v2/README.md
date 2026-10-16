# Навигация кистью — v2

12 октября 2026. Задача владельца GARDEN-HELP.2. Три исходных PNG созданы
встроенным imagegen, просмотрены отдельно (это не просмотр приложения).
Старые исходники не заменены. Разработчик импортирует побайтовые копии.

| Исходник / imageset | Символ | Размер | Границы при alpha ≥32 |
| --- | --- | --- | --- |
| nav_back_brush_v2 | Кистевой шеврон < без древка | 1254×1254 | x75…1171, y93…1169 |
| nav_help_brush_v2 | Кистевой ? с точкой | 1254×1254 | x75…1172, y93…1167 |
| nav_close_brush_v2 | Кистевой × | 1254×1254 | x74…1174, y93…1170 |

Все RGBA, alpha0…255, прозрачность снаружи круга; центр бумажный, alpha253.
Правая/нижняя границы исключены. Общая нормализация рисунка для трёх:
CGRect(x:74,y:93,width:1100,height:1077). Сохранить пропорции без stretch,
общий видимый диаметр около40pt и hit target ≥44pt. Кнопка сложности
сохраняет свой canvas-якорь и может иметь свой proportional размер.

Под старым нарисованным back в фоне сложности требуется непрозрачная
круглая бумажная подложка: само изображение не гарантирует полное закрытие.
Не использовать tint/template: бумага и сепия нарисованы. Не добавлять
системную toolbar capsule на iOS26. Имена/подсказки кнопок через RU/EN loc.

## Промпты и происхождение

Режим: встроенный image_gen, три отдельных вызова редактирования, transparent_background=true.
Единый reference/edit target:
Sudoky/Assets.xcassets/home_music_flute_off_v2.imageset/home_music_flute_off_v2.png.
Сохранили круг/палитру/штрихи, полностью убрали свирель, добавили бумажную середину.

Общий промпт (для каждого вызова к нему добавлено SYMBOL ниже):

Use case: precise-object-edit. Asset: square painted UI button for a calm
Japanese-inspired Sudoku app. Input image: style/reference target. Keep the
warm dark sepia dry ink brush enso circular outline, centered circular
composition and equal outer margins. Remove flute completely. Within the
circle place ONLY SYMBOL described below, hand painted in the same dark warm
sepia with tapered brush ends and visible bristle texture, legible at40pt.
Interior of circle is softly textured opaque pale cream rice paper (#f7efd9);
outside circle genuinely transparent alpha, no rectangular background.
Circle almost closed with small natural break, no metallic rim, no shadow,
no bevel, no other ornaments, no text labels, no instrument. Square canvas,
circle diameter80% canvas centered, symbol centered in inner40%.

- back SYMBOL: a single left-pointing chevron shaped exactly <, two diagonal
  brush strokes joined; NOT an arrow with a horizontal shaft.
- help SYMBOL: a single question mark ?, curved brush stroke with a separate
  round ink dot.
- close SYMBOL: a single diagonal cross ×, two diagonally crossing short
  brush strokes, NOT a plus.

Первичные изображения сохранены в .codex/generated_images/019f99e4-058c-72f2-83e2-b4e9784dc5ef:
back exec-ec1554b3-2b13-497f-ac35-2a604d1fe3c2.png;
help exec-56f70225-bfee-41e0-9a0f-a1712ac57459.png;
close exec-5d62fb0b-6378-4859-bc14-342c75af4beb.png.
Проект использует копии в этой папке и imageset, не ссылки на generated_images.
