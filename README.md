# Corne Choc — 36-key ZMK keymap

Personal [ZMK](https://zmk.dev) firmware configuration for a **Corne Choc** (36-key split keyboard) with **nice!view** displays.

This is a macOS-focused layout with full English and Russian language support.

## Features

- **Home row mods** (Shift / Alt / Ctrl / Cmd) with opposite-hand triggering to avoid misfires
- **Gaming mode** — hold P + the far-right thumb for one second to toggle a WASD cluster aligned with NAV arrows
- **Key repeat** on a thumb key (tap = repeat last key, hold = NAV layer)
- **Mouse emulation** layer with pointer movement, scrolling, and click buttons
- **Conditional layers** — holding NAV + SYM together activates the UTIL layer
- **macOS shortcuts** layer — virtual desktops, window/tab switching, screenshots, Finder actions
- **macOS window tiling** (Sequoia) — tile left/right, fill, and arrange on the NAV layer
- **Unicode symbols** via macOS Option combos (en/em dash, guillemets, math symbols)
- **Russian Universal** custom keyboard layout that keeps symbol positions identical to US English
- **Guarded utility actions** — Bluetooth bond clear and output switching require ~800ms hold

## Russian Universal layout

The `os-keymap/` directory contains a custom macOS keyboard layout (`Russian Universal.bundle`). It maps Cyrillic letters to the standard ЙЦУКЕН positions while keeping punctuation and symbol keys identical to the US layout. This means the SYM and NUM layers produce the same characters regardless of whether English or Russian input is active.

The firmware also includes a local extended Caps Word behavior so the Russian helper letters on non-standard HID keys (`Б/Ю/Э/Ъ/Х`) uppercase correctly without leaving Caps Word.

To install for all users: copy `Russian Universal.bundle` to `/Library/Keyboard Layouts/` (requires administrator permission), then add it in System Settings > Keyboard > Input Sources.

The NUM `+` key sends keypad plus. In this layout, keypad plus produces `+`, Option + keypad plus produces `ъ`, and Option + Shift + keypad plus produces `Ъ`. Holding the BASE `M/Ь` key sends Option + keypad plus; Caps Word adds Shift for `Ъ`. After updating this mapping, install the updated layout bundle and flash the matching firmware together. Test `+`, `ъ`, and `Ъ` in your usual apps, since apps can intercept key combinations before text input.

## Layer maps

In the tables below, `tap/hold` means tap action vs hold action, and `-/hold` means hold-only.

Note: `SYM`/`NUM` symbols assume macOS input source is English (US) **or** `Russian – Universal` layout from `os-keymap/` (it keeps symbols in the same places).

### `BASE (EN)`
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Q</td><td>W</td><td>E</td><td>R</td><td>T</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>Y</td><td>U</td><td>I</td><td>O</td><td>P</td></tr>
    <tr><td>A/⇧</td><td>S/⌥</td><td>D/⌃</td><td>F/⌘</td><td>G</td><td>H</td><td>J/⌘</td><td>K/⌃</td><td>L/⌥</td><td>*/⇧</td></tr>
    <tr><td>Z</td><td>X</td><td>C</td><td>V</td><td>B</td><td>&nbsp;</td><td>&nbsp;</td><td>N</td><td>M/*</td><td>*</td><td>*</td><td>*</td></tr>
    <tr>
      <td colspan="2" style="white-space:nowrap;"><code>⌦/MOUSE</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Space/NUM</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Rep/NAV</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>⏎/SYM</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Tab/MAC</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>⌫/Esc</code></td>
    </tr>
  </tbody>
</table>

`*` These keys are only relevant for the RU keyboard layout.

### `BASE (RU)`
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Й</td><td>Ц</td><td>У</td><td>К</td><td>Е</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>Н</td><td>Г</td><td>Ш</td><td>Щ</td><td>З</td></tr>
    <tr><td>Ф/⇧</td><td>Ы/⌥</td><td>В/⌃</td><td>А/⌘</td><td>П</td><td>Р</td><td>О/⌘</td><td>Л/⌃</td><td>Д/⌥</td><td>Ж/⇧</td></tr>
    <tr><td>Я</td><td>Ч</td><td>С</td><td>М</td><td>И</td><td>&nbsp;</td><td>&nbsp;</td><td>Т</td><td>Ь/Ъ</td><td>Б</td><td>Ю</td><td>Э</td></tr>
    <tr>
      <td colspan="2" style="white-space:nowrap;"><code>⌦/MOUSE</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Space/NUM</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Rep/NAV</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>⏎/SYM</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Tab/MAC</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>⌫/Esc</code></td>
    </tr>
  </tbody>
</table>

Combos:

`Щ`+`З`=`Х`

### `NAV`
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>⌘↑</td><td>⌥←</td><td>↑</td><td>⌥→</td><td>PgUp</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>Help</td><td>Tab←</td><td>MC↑</td><td>Tab→</td><td>&nbsp;</td></tr>
    <tr><td>⌘↓</td><td>←</td><td>↓</td><td>→</td><td>PgDn</td><td>Menu</td><td>Win←</td><td>MC↓</td><td>Win→</td><td>WinFcs</td></tr>
    <tr><td>Zm-</td><td>⌘←</td><td>Zm0</td><td>⌘→</td><td>Zm+</td><td>&nbsp;</td><td>&nbsp;</td><td>TL←</td><td>Sp←</td><td>TileFill*</td><td>Sp→</td><td>TR→</td></tr>
  </tbody>
</table>

**TL←** / **TileFill** / **TR→** are macOS Sequoia window tiling shortcuts. **TileFill\*** is a tap-dance: single tap fills the window, double-tap sends the arrange-right shortcut twice to cycle arrangement.

These macros send **Ctrl+Option+Cmd+key** instead of the default Globe+Ctrl+key. ZMK's Globe is a consumer HID usage in a separate USB report that macOS cannot reliably combine with keyboard modifiers ([zmk#947](https://github.com/zmkfirmware/zmk/issues/947)), and Ctrl+Option+Arrow alone conflicts with Option+Arrow word navigation in text fields.

Add matching App Shortcuts in **System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts** (All Applications): `Left` → ⌃⌥⌘←, `Right` → ⌃⌥⌘→, `Fill` → ⌃⌥⌘F, `Return to Previous Size` → ⌃⌥⌘R.

### `SYM`
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>_</td><td>?</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>\</td><td>–/—</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
    <tr><td>(</td><td>[</td><td>{</td><td>;</td><td>'</td><td>&quot;</td><td>:</td><td>}</td><td>]</td><td>)</td></tr>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&laquo;</td><td>&#96;</td><td>&nbsp;</td><td>&nbsp;</td><td>&lsquo;</td><td>&raquo;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
  </tbody>
</table>

### `NUM`
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>!</td><td>@</td><td>#</td><td>$/€</td><td>%</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>*</td><td>7</td><td>8</td><td>9</td><td>+</td></tr>
    <tr><td>&sum;</td><td>∞</td><td>≈</td><td>=</td><td>≠</td><td>/</td><td>4</td><td>5</td><td>6</td><td>-</td></tr>
    <tr><td>^</td><td>˚</td><td>&lt;</td><td>&gt;</td><td>&amp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&#124;</td><td>1</td><td>2</td><td>3</td><td>~</td></tr>
    <tr>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>,</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>.</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>0</code></td>
    </tr>
  </tbody>
</table>

### `MAC`
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Sp1</td><td>Sp2</td><td>Sp3</td><td>Sp4</td><td>Sp5</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>Sp6</td><td>Sp7</td><td>Sp8</td><td>Sp9</td><td>Sp10</td></tr>
    <tr><td>⌘1</td><td>⌘2</td><td>⌘3</td><td>⌘4</td><td>⌘5</td><td>⌘6</td><td>⌘7</td><td>⌘8</td><td>⌘9</td><td>⌘0</td></tr>
    <tr><td>Emoji/Lock</td><td>ScrRfrsh</td><td>Dock</td><td>Spot</td><td>SS4/Clip</td><td>&nbsp;</td><td>&nbsp;</td><td>SS5/Clip</td><td>GoFolder</td><td>HidFiles</td><td>CpPath</td><td>PstMatch</td></tr>
  </tbody>
</table>

**Sp1–Sp10** send Ctrl+1 through Ctrl+0 to jump directly to a specific Space. These shortcuts are disabled by default in macOS. Enable them in **System Settings > Keyboard > Keyboard Shortcuts > Mission Control** — check "Switch to Desktop N" for each Space you use.

### `MOUSE`

<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>Scr↑</td><td>Scr←</td><td>↑</td><td>Scr→</td><td>&nbsp;</td></tr>
    <tr><td>A</td><td>S</td><td>D</td><td>F</td><td>&nbsp;</td><td>Scr↓</td><td>←</td><td>↓</td><td>→</td><td>&nbsp;</td></tr>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>MB4</td><td>MB5</td></tr>
    <tr>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>LCLK</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>MCLK</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>RCLK</code></td>
    </tr>
  </tbody>
</table>

Hold `⌦/MOUSE` to activate this momentary layer. The left home-row modifier keys (`A`, `S`, `D`, `F`) are explicit plain key presses, so they bypass the base layer's modifiers for games. `W` and `G` remain transparent because they are already plain keys on `BASE`; other transparent keys also fall through to the base layer.

Mouse emulation is enabled (`CONFIG_ZMK_POINTING=y`). If mouse does not work over BLE, you may need to refresh the HID descriptor (re-pair).

### `GAME`

Press **P + the far-right thumb within 50 ms of each other**, then keep both held for **one second**, to enter GAME. Repeat the same physical gesture to return to BASE. This thumb is `Backspace/Esc` on BASE and plain `Esc` on GAME. Release both keys before switching again. The mode stays active after release.

Releasing either key before the hold completes cancels the switch. Other key presses do not shorten the hold. The combo works only on BASE and GAME. A recognized chord consumes both keys, even when released early; their individual actions still work. P can wait up to 80 ms on BASE because it also belongs to the existing O + P Russian helper combo, or 50 ms on GAME. The far-right thumb can wait up to 50 ms for combo detection. The left-hand GAME controls have no switch-combo delay. The hold is measured from the first key press, as in ZMK v0.3's combo implementation.

<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Tab</td><td>Q</td><td>W</td><td>E</td><td>R</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>5</td><td>6</td><td>7</td><td>8</td><td>P</td></tr>
    <tr><td>Shift</td><td>A</td><td>S</td><td>D</td><td>F</td><td>B</td><td>X</td><td>C</td><td>L</td><td>M</td></tr>
    <tr><td>1</td><td>2</td><td>3</td><td>4</td><td>V</td><td>&nbsp;</td><td>&nbsp;</td><td>9</td><td>0</td><td>G</td><td>I</td><td>Z</td></tr>
    <tr>
      <td colspan="2" style="white-space:nowrap;"><code>Ctrl</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Space</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>T</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Enter</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Backspace</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>Esc</code></td>
    </tr>
  </tbody>
</table>

This is a shared starting layout for PEAK, RV There Yet?, and How to Fish. W/A/S/D occupy the same physical positions as NAV's up/left/down/right arrows. Q/E/R/F/T, slots 1–4, and V stay on the left with Ctrl/Space/Shift. The right half provides 5–0 and B/X/C/L/M/G/I/Z for extra actions. Esc is only on the far-right thumb, away from the left-hand movement controls.

Shift is a plain modifier in the left pinky position, leaving the thumb free for Space when sprinting and jumping. T uses the former Shift thumb. V stays on the bottom row so hold-to-talk does not compete with Space for the thumb.

PEAK uses 1–3 for items, 4 for its backpack, and V for push to talk. RV There Yet? also uses V for voice, with X for emotes and R/P/L for engine/parking/lights. These informed the placement; check the controls shown by your installed game before relying on a default. References checked October 5, 2026: [PEAK control report](https://www.destructoid.com/all-peak-key-bindings-how-to-change-controls/) and [RV There Yet? gameplay guide](https://progameguides.com/rv-there-yet/rv-there-yet-beginners-guide-tips/). The supplied How to Fish 1.1.3 controls screen confirms R for reload, F for inspect, V for push to talk, Tab for think, B for bait, X for unequip, and Z/C for weapon skins.

All GAME bindings are plain key presses. Holding movement keys sends letters; holding Space keeps Space pressed. Entering GAME clears active Caps Word so it cannot add Shift to movement keys; returning to BASE leaves Caps Word off until activated again. Typing combos and thumb layer-taps are inactive. GAME does not contain H/J/K/N/O/U/Y or punctuation. Return to BASE for text chat, the normal typing layers, and Russian helpers. Select an English input source when the game expects US QWERTY controls.

Timing follows the [ZMK v0.3 combo behavior](https://github.com/zmkfirmware/zmk/blob/v0.3/app/src/combo.c) and [hold-tap configuration](https://github.com/zmkfirmware/zmk/blob/v0.3/docs/docs/keymaps/behaviors/hold-tap.mdx), verified October 2, 2026.

### `UTIL` (tri-layer: `NAV` + `SYM`)
<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>BT0</td><td>BT1</td><td>BT2</td><td>BT3</td><td>BT4</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>-/BT Clr*</td><td>F1</td><td>F2</td><td>F3</td><td>F4</td></tr>
    <tr><td>Hue-</td><td>Hue+</td><td>UG-</td><td>UG+</td><td>UG Tog</td><td>-/USB*</td><td>F5</td><td>F6</td><td>F7</td><td>F8</td></tr>
    <tr><td>Br-</td><td>Br+</td><td>Vol-</td><td>Vol+</td><td>Mute</td><td>&nbsp;</td><td>&nbsp;</td><td>-/BLE*</td><td>F9</td><td>F10</td><td>F11</td><td>F12</td></tr>
  </tbody>
</table>

`BT Clr*`, `USB*`, and `BLE*` require a long press (~800ms). Tap does nothing.

## Prerequisites

To build locally you need:

- **Docker** (the Makefile runs the ZMK build inside a container)
- **keymap-drawer** (`pip install keymap-drawer`) — for generating layer diagrams
- **rsvg-convert** (`brew install librsvg`) — for converting SVG diagrams to PDF

## Build locally (Docker)

```sh
make firmware
```

Build output UF2 files are written to `dist/`:

- `dist/left-niceview.uf2`
- `dist/right-niceview.uf2`
- `dist/left-reset.uf2`
- `dist/right-reset.uf2`

Build just one target:

```sh
make firmware-left-niceview
```

## Keymap PDF

This creates a nice-looking PDF of your layers.

```sh
make pdf
```

Output files are written to `artifacts/layouts/`.

If some labels look too big, edit `keymap_drawer.config.yaml` (it controls how keys are rendered).

## Flash

1. Build the desired target (left/right + shield).
2. Put the corresponding half into bootloader mode.
3. Copy the matching UF2 from `dist/` to the mounted UF2 drive.

If you want a one-liner, you can flash with `make` (set `MOUNT` to your UF2 drive):

```sh
make flash-left
make flash-right
```

For a full reset, flash the `settings_reset` UF2 to each half once, then flash the normal `nice_view` UF2 again.

## License

[MIT](LICENSE)
