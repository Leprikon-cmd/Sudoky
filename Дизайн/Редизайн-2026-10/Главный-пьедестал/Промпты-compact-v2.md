# Промпты исправленного фона главного

Встроенный imagegen, 11 октября 2026. Финальный файл home_pedestal_background_compact_v2.png.
Первый проход дал низкую тонкую опору и чистую нижнюю бумагу; второй проход
сильно поднял опору, но после уточнения владельца о приоритете крупного бонсая
не выбран. Финальная коррекция выполнена из первого прохода: сохранено
пространство дерева, очищены верхние зоны кнопок. Промежуточные генерации
не подключены и не являются утверждёнными ассетами.

## Базовая композиция

```text
Use case: precise-object-edit.
Asset type: clean opaque portrait BACKGROUND ART for a mobile Sudoku home screen. Image 1 is the EDIT TARGET. Keep the SAME tall 852:1846 aspect ratio (about9:19.5), warm parchment texture, detailed Japanese woodblock/ink illustration, sepia cliffs and pine landscape, soft orange-red sun, sakura blossoms. Recompose the background for a real four-button interface; no UI painted into it.
PRIMARY CHANGE: raise and reduce the height of the existing stone pedestal and create a LARGE CLEAR lower area UNDER the entire pedestal, not on its front face. We will overlay four existing wide horizontal buttons later.
Precise normalized layout:
- Upper composition occupies approximately top0–49% of total height. Preserve a meaningful mountain valley, mist, subtle river/waterfall, pine cliffs framing the sides, orange sun toward upper-right around(x=.79,y=.22), and sakura branches framing upper-left/top edge. Do not tile/repeat mountain clusters or flowers.
- Create ONE centered EMPTY natural stone platform. Broad oval/slightly elliptical FLAT TOP suitable for a bonsai pot, horizontal centerx=.50. Contact line for the pot aroundy=.42. The platform top can span x=.12–.88 and y=.405–.443. Thin realistic stone lip and low rock base end by y=.49. It should resemble the existing weathered grey-beige rock, moss/cracks, not a modern table, not a huge tall plinth. Critical: NO part of the central pedestal or its base below y=.49.
- Leave the region x=.24–.76, y=.16–.42 visually quiet enough for an existing bonsai/tree asset to be placed later. Do NOT paint any bonsai, pot or tree onto the platform. Background mountain detail behind this space can be misty and subtle; landscape pines stay at far edges.
- Bottom HALF y=.50–1.00 is a continuous warm light parchment/rice-paper field. A subtle natural fade from the top landscape/rock into paper near y=.48–.52, no hard horizontal seam or white strip. This is the actual empty space for FOUR full-width buttons, top to bottom. Entire rectangle x=.05–.95,y=.515–.94 MUST be clean, low-contrast parchment with NO rocks, wooden furniture, flowers, leaves, mountains, water, ornamental medallions, raised surfaces, branches or shadows that might clash with buttons. Only restrained paper fibers/grain, same warm paper palette as upper art. Tiny quiet corner decoration is permitted outside that rectangle at the very bottom far corners, not necessary.
- REMOVE the old wooden foreground bench/table and its medallion entirely, and remove the extra low stone terraces; they currently consume the button area.
- Reserve quiet upper-corner spaces for our existing sound/settings icons: left x=.03–.20,y=.065–.15 and right x=.80–.97,y=.065–.15. Keep sakura branch/blossoms away from those two areas; place blossoms along very top edge or further down the far-left edge instead. Quiet top5% for phone statusbar.
Constraints/invariants: preserve source illustration identity, palette, material feel and calm mood. Full bleed background without a device frame. No UI controls, rectangles, button silhouettes, four slot outlines, labels, text, letters, numbers, icons, bonsai, pot, person, pagodas or watermark. Keep enough space BELOW the stone for all four native buttons; don't merely move the original giant platform a tiny bit. This must look like one finished coherent illustration with a compact scenic upper half and a quiet usable lower half.
```

## Финальная коррекция после уточнения владельца

```text
Use case: precise-object-edit.
Image1 is the EDIT TARGET: the home background draft with a thin empty stone platform ending around58% of total image height and quiet parchment below. KEEP this tall852:1846 canvas and this composition. The owner prioritizes a LARGE BEAUTIFUL BONSAI (to be overlaid later) over large buttons, so DO NOT raise the platform further or reduce the scenic upper half.
Keep platform top centered with bonsai pot contact at approximatelyy=.51, rock base ending no later than y=.58, source sun/mountain/river arrangement, empty center space above stone for tree overlay, and the entire bottomy=.60–1 as clean paper for four COMPACT native buttons later. Do not paint a bonsai or buttons.
ONE targeted fix: clear two small spaces for top-corner control icons. Left rectanglex=.03–.20,y=.065–.15 and rightx=.80–.97,y=.065–.15 must be warm lightly textured paper without any flowers/branches/dark mountains. Re-route the sakura branches/blossoms that cross ONLY the left control rectangle up toward the very top edge or inward towardx=.25–.50. Preserve the rich sakura identity elsewhere, no white erased patch, integrate real paper texture seamlessly.
Keep the rest of the image as unchanged as possible: the original thin stone pedestal, broad horizontal top, grey-beige stone/moss, mountain valley and waterfalls, orange sun, birds, restrained side foliage by platform. Absolutely no new pedestals, trees, mountains, temples, furniture, medallions or decoration in lower paper.
Invariants: full-bleed opaque illustration, portrait9:19.5 approximately; no UI, no circles/icons, no labels, no text, no bonsai/pot on platform, no buttons, no slot outlines, no guides, no watermark. This remains a production BACKGROUND, not a mockup.
```

