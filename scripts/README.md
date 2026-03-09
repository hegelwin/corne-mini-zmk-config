# Scripts

This folder has helper scripts for this ZMK config repo.

## Create a PDF of your layout

Use `make-layout-pdf.sh` to:
- parse your ZMK `*.keymap` into a `keymap-drawer` YAML
- draw one or more SVGs
- convert them to a multi-page PDF

If you prefer `make`, run:

```sh
make pdf
```

### Install (macOS)

You need:
- `keymap` (from `keymap-drawer`)
- a SVG to PDF tool: `rsvg-convert` (recommended) or `inkscape`
- a PDF join tool (for multi-page PDFs): `pdfunite` (from `poppler`) or `gs` (ghostscript)

Install with Homebrew + pipx:

```sh
brew install pipx librsvg poppler ghostscript
pipx ensurepath
pipx install keymap-drawer
```

Optional fallback converter:

```sh
brew install inkscape
```

### Run

If you have exactly one keymap at `config/*.keymap`, you can just run:

```sh
./scripts/make-layout-pdf.sh
```

Output files go to `artifacts/layouts/`:
- `*.yaml` (parsed keymap)
- `*.svg` (all layers in one SVG, for quick viewing)
- `*.p1.svg`, `*.p2.svg`, ... (per-page diagrams)
- `*.p1.pdf`, `*.p2.pdf`, ... (per-page PDFs)
- `*.pdf` (final merged PDF)

## Join existing SVGs into a multi-page PDF

If you already have SVG pages (from anywhere), you can join them into one PDF:

```sh
./scripts/svgs-to-pdf.sh --out artifacts/layouts/two-pages.pdf a.svg b.svg
```

### Useful flags

- **Skip combos (default)**:
  The script uses `keymap draw --keys-only` by default, so combos are not drawn.
- **Include combos**:

```sh
./scripts/make-layout-pdf.sh --with-combos
```

- **Only draw specific layers**:

```sh
./scripts/make-layout-pdf.sh --layers BASE NAV SYM
```

- **One page (old behavior)**:

```sh
./scripts/make-layout-pdf.sh --pages 1
```

- **Custom physical layout** (advanced):
  The default is for a 36-key Corne style layout (split 3x5 + 3 thumbs per side).
  You can override it:

```sh
./scripts/make-layout-pdf.sh --layout '{split: true, rows: 3, columns: 5, thumbs: 3}'
```

