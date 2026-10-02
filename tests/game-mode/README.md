# Gaming mode behavior tests

These native ZMK v0.3 tests include the production keymap. The mock scanner maps
columns 0–35 directly to the physical key positions.

- `guard`: individual Q/P holds, the existing P + O helper, presses outside the chord window, release just
  before the hold deadline, release of either chord key, and interrupting keys.
- `round-trip`: one switch per long hold, persistent GAME activation, held
  A/S/D/F/Space, inactive typing combos, dedicated Ctrl/Shift thumbs, canceled
  short exit, reverse-order exit, and restored BASE home row mods.
- `caps-word-entry`: active Caps Word survives normal typing layers, clears on
  GAME entry, stays cleared on exit, and can be reactivated on BASE.

From `zmk/app` in a configured Linux ZMK build environment, run:

```sh
ZMK_EXTRA_MODULES=/absolute/path/to/corne-mini-zmk-config \
ZMK_BUILD_DIR=/absolute/path/to/isolated-build J=1 \
./run-test.sh /absolute/path/to/corne-mini-zmk-config/tests/game-mode
```

Use a build directory owned by this run. The runner compares HID events and layer
transitions against the committed snapshots. It does not require a keyboard.
