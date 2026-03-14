# Corne Choc — 36-key ZMK keymap

Personal [ZMK](https://zmk.dev) firmware configuration for a **Corne Choc** (36-key split keyboard) with **nice!view** displays.

This is a macOS-focused layout with full English and Russian language support.

## Features

- **Home row mods** (Shift / Alt / Ctrl / Cmd) with opposite-hand triggering to avoid misfires
- **Key repeat** on a thumb key (tap = repeat last key, hold = NAV layer)
- **Mouse emulation** layer with pointer movement, scrolling, and click buttons
- **Conditional layers** — holding NAV + SYM together activates the UTIL layer
- **macOS shortcuts** layer — virtual desktops, window/tab switching, screenshots, Finder actions
- **Unicode symbols** via macOS Option combos (en/em dash, guillemets, math symbols)
- **Russian Universal** custom keyboard layout that keeps symbol positions identical to US English
- **Guarded utility actions** — Bluetooth bond clear and output switching require ~800ms hold

## Russian Universal layout

The `os-keymap/` directory contains a custom macOS keyboard layout (`Russian Universal.bundle`). It maps Cyrillic letters to the standard ЙЦУКЕН positions while keeping punctuation and symbol keys identical to the US layout. This means the SYM and NUM layers produce the same characters regardless of whether English or Russian input is active.

To install: copy `Russian Universal.bundle` to `~/Library/Keyboard Layouts/` and add it in System Settings > Keyboard > Input Sources.

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
    <tr><td>Zm-</td><td>⌘←</td><td>Zm0</td><td>⌘→</td><td>Zm+</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>Sp←</td><td>&nbsp;</td><td>Sp→</td><td>&nbsp;</td></tr>
  </tbody>
</table>

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

### `MOUSE`

<table style="text-align:center;">
  <thead>
    <tr>
      <th>L1</th><th>L2</th><th>L3</th><th>L4</th><th>L5</th><th>&nbsp;</th><th>&nbsp;</th><th>R1</th><th>R2</th><th>R3</th><th>R4</th><th>R5</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td rowspan="2">&nbsp;</td><td rowspan="2">&nbsp;</td><td>Scr↑</td><td>Scr←</td><td>↑</td><td>Scr→</td><td>&nbsp;</td></tr>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>MB4</td><td>MB5</td><td>&nbsp;</td><td>Scr↓</td><td>←</td><td>↓</td><td>→</td><td>&nbsp;</td></tr>
    <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
    <tr>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>&nbsp;</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>MCLK</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>LCLK</code></td>
      <td colspan="2" style="white-space:nowrap;"><code>RCLK</code></td>
    </tr>
  </tbody>
</table>

Mouse emulation is enabled (`CONFIG_ZMK_POINTING=y`). If mouse does not work over BLE, you may need to refresh the HID descriptor (re-pair).

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
