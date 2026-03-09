#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Create a nice-looking PDF from a ZMK *.keymap using keymap-drawer.

Usage:
  ./scripts/make-layout-pdf.sh [options]

Options:
  --keymap <path>     Path to ZMK *.keymap (default: if exactly one matches config/*.keymap, use it)
  --outdir <dir>      Output directory (default: artifacts/layouts)
  --columns <num>     Columns used during parse (default: 10)
  --pages <num>       How many PDF pages to split layers across (default: 2)
  --config <path>     keymap-drawer config YAML (default: keymap_drawer.config.yaml if present)
  --layout <yaml>     Ortho layout YAML string for drawing
                      (default: {split: true, rows: 3, columns: 5, thumbs: 3})
  --with-combos       Draw combos too (default: combos are skipped)
  --layers <names..>  Only draw these layers (space-separated list)
  -h, --help          Show help

Examples:
  ./scripts/make-layout-pdf.sh
  ./scripts/make-layout-pdf.sh --keymap config/corne_choc.keymap
  ./scripts/make-layout-pdf.sh --with-combos
  ./scripts/make-layout-pdf.sh --layers BASE NAV SYM
  ./scripts/make-layout-pdf.sh --pages 1
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

need_cmd() {
  local name="$1"
  command -v "${name}" >/dev/null 2>&1 || die "Missing '${name}'. See scripts/README.md for install steps."
}

extract_display_layers() {
  local keymap_file="$1"
  # Prefer ZMK's `display-name = "..."` labels. This keeps layer ordering stable.
  # This is intentionally simple (no full DTS parsing).
  local -a extracted=()
  while IFS= read -r layer; do
    [[ -n "${layer}" ]] || continue
    extracted+=("${layer}")
  done < <(sed -nE 's/.*display-name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "${keymap_file}" | uniq)

  if [[ ${#extracted[@]} -eq 0 ]]; then
    die "Could not detect layer names (missing display-name?). Use --layers to specify them."
  fi

  printf '%s\0' "${extracted[@]}"
}

convert_svg_to_pdf() {
  local in_svg="$1"
  local out_pdf="$2"
  if [[ "${SVG_TO_PDF_TOOL}" == "rsvg-convert" ]]; then
    rsvg-convert -f pdf -o "${out_pdf}" "${in_svg}"
  else
    inkscape "${in_svg}" --export-type=pdf --export-filename="${out_pdf}" >/dev/null
  fi
}

join_pdfs() {
  local out_pdf="$1"; shift
  local -a in_pdfs=("$@")

  if command -v pdfunite >/dev/null 2>&1; then
    pdfunite "${in_pdfs[@]}" "${out_pdf}"
    return 0
  fi

  if command -v gs >/dev/null 2>&1; then
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="${out_pdf}" "${in_pdfs[@]}"
    return 0
  fi

  die "Missing a PDF join tool (need 'pdfunite' from poppler, or 'gs')."
}

build_target_layer_held_map_json() {
  local svg_path="$1"
  local keymap_file="$2"
  python3 - "${svg_path}" "${keymap_file}" <<'PY'
import json
import re
import sys
import xml.etree.ElementTree as ET

svg_path = sys.argv[1]
keymap_path = sys.argv[2]

ns = {"svg": "http://www.w3.org/2000/svg"}
tree = ET.parse(svg_path)
root = tree.getroot()

def cls_list(el):
    return (el.get("class") or "").split()

def norm(s: str) -> str:
    return re.sub(r"\s+", " ", s.strip()).casefold()

# Discover which layers exist in this SVG.
layer_names = set()
for t in root.findall(".//svg:text", ns):
    if "label" not in cls_list(t):
        continue
    lid = t.get("id")
    if lid:
        layer_names.add(lid)
layer_norm = {norm(n): n for n in layer_names}

def find_layer_group(layer_name: str):
    want = f"layer-{layer_name}"
    for g in root.findall(".//svg:g", ns):
        if want in cls_list(g):
            return g
    return None

base = find_layer_group("BASE")
activators: dict[str, set[int]] = {}

# From BASE layer, find keys whose HOLD legend matches a layer name (case-insensitive).
if base is not None:
    for key_g in base.findall(".//svg:g", ns):
        classes = cls_list(key_g)
        if "key" not in classes:
            continue
        keypos = None
        for c in classes:
            if c.startswith("keypos-"):
                try:
                    keypos = int(c.split("-", 1)[1])
                except ValueError:
                    keypos = None
                break
        if keypos is None:
            continue

        hold_texts = []
        for t in key_g.findall(".//svg:text", ns):
            t_classes = cls_list(t)
            if "hold" not in t_classes:
                continue
            if not t.text or not t.text.strip():
                continue
            hold_texts.append(t.text.strip())

        for hold in hold_texts:
            hold_n = norm(hold)
            if hold_n in layer_norm:
                layer_name = layer_norm[hold_n]
                activators.setdefault(layer_name, set()).add(keypos)

# Conditional layers: parse `if-layers = <A B>; then-layer = <C>;`
try:
    src = open(keymap_path, "r", encoding="utf-8").read()
except OSError:
    src = ""

cond_re = re.compile(
    r"if-layers\s*=\s*<([^>]+)>\s*;(?:(?!if-layers).)*?then-layer\s*=\s*<([^>]+)>\s*;",
    re.DOTALL,
)

for m in cond_re.finditer(src):
    if_layers_raw = m.group(1)
    then_layer_raw = m.group(2)
    if_layers = [x for x in re.split(r"\s+", if_layers_raw.strip()) if x]
    then_layers = [x for x in re.split(r"\s+", then_layer_raw.strip()) if x]
    if not if_layers or not then_layers:
        continue

    for then_l in then_layers:
        # Only apply if the layer actually exists in the SVG.
        then_norm = norm(then_l)
        if then_norm not in layer_norm:
            continue
        then_name = layer_norm[then_norm]
        for if_l in if_layers:
            if_norm = norm(if_l)
            if if_norm not in layer_norm:
                continue
            if_name = layer_norm[if_norm]
            for kp in activators.get(if_name, set()):
                activators.setdefault(then_name, set()).add(kp)

out_json = {k: sorted(v) for k, v in activators.items()}
print(json.dumps(out_json))
PY
}

mark_layer_activators_on_target_layers_as_held() {
  local svg_path="$1"
  local map_json_path="$2"
  python3 - "${svg_path}" "${map_json_path}" <<'PY'
import json
import sys
import xml.etree.ElementTree as ET

svg_path = sys.argv[1]
map_path = sys.argv[2]

ns = {"svg": "http://www.w3.org/2000/svg"}

tree = ET.parse(svg_path)
root = tree.getroot()

def cls_list(el):
    return (el.get("class") or "").split()

def find_layer_group(layer_name: str):
    want = f"layer-{layer_name}"
    for g in root.findall(".//svg:g", ns):
        if want in cls_list(g):
            return g
    return None

with open(map_path, "r", encoding="utf-8") as f:
    mapping = json.load(f)

changed = 0
for layer_name, keyposes in mapping.items():
    if not isinstance(keyposes, list) or not keyposes:
        continue
    layer_g = find_layer_group(layer_name)
    if layer_g is None:
        continue
    for keypos in keyposes:
        want_keypos = f"keypos-{keypos}"
        for key_g in layer_g.findall(".//svg:g", ns):
            classes = cls_list(key_g)
            if "key" not in classes or want_keypos not in classes:
                continue
            # Add held class to the rect in the TARGET layer diagram.
            for r in key_g.findall("./svg:rect", ns):
                r_classes = cls_list(r)
                if "key" not in r_classes:
                    continue
                if "held" in r_classes:
                    break
                r_classes.append("held")
                r.set("class", " ".join(r_classes))
                changed += 1
                break

tree.write(svg_path, encoding="utf-8", xml_declaration=False)
print(changed)
PY
}

KEYMAP_FILE=""
OUTDIR="artifacts/layouts"
COLUMNS="10"
PAGES="2"
ORTHO_LAYOUT="{split: true, rows: 3, columns: 5, thumbs: 3}"
WITH_COMBOS="0"
CONFIG_FILE=""
LAYERS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keymap)
      [[ $# -ge 2 ]] || die "--keymap needs a value"
      KEYMAP_FILE="$2"
      shift 2
      ;;
    --outdir)
      [[ $# -ge 2 ]] || die "--outdir needs a value"
      OUTDIR="$2"
      shift 2
      ;;
    --columns)
      [[ $# -ge 2 ]] || die "--columns needs a value"
      COLUMNS="$2"
      shift 2
      ;;
    --pages)
      [[ $# -ge 2 ]] || die "--pages needs a value"
      PAGES="$2"
      shift 2
      ;;
    --config)
      [[ $# -ge 2 ]] || die "--config needs a value"
      CONFIG_FILE="$2"
      shift 2
      ;;
    --layout)
      [[ $# -ge 2 ]] || die "--layout needs a value"
      ORTHO_LAYOUT="$2"
      shift 2
      ;;
    --with-combos)
      WITH_COMBOS="1"
      shift
      ;;
    --layers)
      shift
      while [[ $# -gt 0 && "${1:-}" != --* ]]; do
        LAYERS+=("$1")
        shift
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1 (use --help)"
      ;;
  esac
done

if [[ -z "${KEYMAP_FILE}" ]]; then
  shopt -s nullglob
  candidates=(config/*.keymap)
  shopt -u nullglob
  if [[ ${#candidates[@]} -eq 1 ]]; then
    KEYMAP_FILE="${candidates[0]}"
  elif [[ ${#candidates[@]} -eq 0 ]]; then
    die "No keymaps found at config/*.keymap. Use --keymap <path>."
  else
    die "Multiple keymaps found at config/*.keymap. Use --keymap <path> to choose one."
  fi
fi

[[ -f "${KEYMAP_FILE}" ]] || die "Keymap file not found: ${KEYMAP_FILE}"

need_cmd keymap

if [[ -z "${CONFIG_FILE}" && -f "keymap_drawer.config.yaml" ]]; then
  CONFIG_FILE="keymap_drawer.config.yaml"
fi

keymap_cmd=(keymap)
if [[ -n "${CONFIG_FILE}" ]]; then
  [[ -f "${CONFIG_FILE}" ]] || die "Config file not found: ${CONFIG_FILE}"
  keymap_cmd=(keymap -c "${CONFIG_FILE}")
fi

if command -v rsvg-convert >/dev/null 2>&1; then
  SVG_TO_PDF_TOOL="rsvg-convert"
elif command -v inkscape >/dev/null 2>&1; then
  SVG_TO_PDF_TOOL="inkscape"
else
  die "Missing 'rsvg-convert' or 'inkscape' for SVG -> PDF conversion. See scripts/README.md."
fi

mkdir -p "${OUTDIR}"

name="$(basename "${KEYMAP_FILE}" .keymap)"
yaml="${OUTDIR}/${name}.yaml"
pdf="${OUTDIR}/${name}.pdf"

echo "Parsing ${KEYMAP_FILE} -> ${yaml}"
"${keymap_cmd[@]}" parse -z "${KEYMAP_FILE}" -c "${COLUMNS}" -o "${yaml}"

base_draw_args=(--ortho-layout "${ORTHO_LAYOUT}")
if [[ "${WITH_COMBOS}" != "1" ]]; then
  base_draw_args+=(--keys-only)
fi

if ! [[ "${PAGES}" =~ ^[0-9]+$ ]] || [[ "${PAGES}" -lt 1 ]]; then
  die "--pages must be a positive integer"
fi

layers_to_draw=()
if [[ ${#LAYERS[@]} -gt 0 ]]; then
  layers_to_draw=("${LAYERS[@]}")
else
  while IFS= read -r -d '' layer; do
    layers_to_draw+=("${layer}")
  done < <(extract_display_layers "${KEYMAP_FILE}")
fi

if [[ "${PAGES}" -eq 1 ]] || [[ ${#layers_to_draw[@]} -le 1 ]]; then
  svg="${OUTDIR}/${name}.svg"
  draw_args=("${base_draw_args[@]}")
  if [[ ${#LAYERS[@]} -gt 0 ]]; then
    draw_args+=(-s "${LAYERS[@]}")
  fi

  echo "Drawing ${yaml} -> ${svg}"
  "${keymap_cmd[@]}" draw "${draw_args[@]}" -o "${svg}" "${yaml}"
  tmp_map="$(mktemp)"
  build_target_layer_held_map_json "${svg}" "${KEYMAP_FILE}" >"${tmp_map}" || true
  mark_layer_activators_on_target_layers_as_held "${svg}" "${tmp_map}" >/dev/null || true
  rm -f "${tmp_map}" || true

  echo "Converting ${svg} -> ${pdf}"
  convert_svg_to_pdf "${svg}" "${pdf}"
  echo "Done: ${pdf}"
  exit 0
fi

pages="${PAGES}"
if [[ ${#layers_to_draw[@]} -lt "${pages}" ]]; then
  pages="${#layers_to_draw[@]}"
fi

echo "Rendering ${#layers_to_draw[@]} layers across ${pages} pages"

svg_all="${OUTDIR}/${name}.svg"
echo "Drawing all layers -> ${svg_all}"
"${keymap_cmd[@]}" draw "${base_draw_args[@]}" -s "${layers_to_draw[@]}" -o "${svg_all}" "${yaml}"
tmp_map="$(mktemp)"
build_target_layer_held_map_json "${svg_all}" "${KEYMAP_FILE}" >"${tmp_map}" || true
mark_layer_activators_on_target_layers_as_held "${svg_all}" "${tmp_map}" >/dev/null || true

n="${#layers_to_draw[@]}"
base_count=$(( n / pages ))
rem=$(( n % pages ))
idx=0

page_pdfs=()
for ((p=1; p<=pages; p++)); do
  count="${base_count}"
  if [[ "${p}" -le "${rem}" ]]; then
    count=$((count + 1))
  fi

  page_layers=("${layers_to_draw[@]:idx:count}")
  idx=$((idx + count))

  page_svg="${OUTDIR}/${name}.p${p}.svg"
  page_pdf="${OUTDIR}/${name}.p${p}.pdf"

  echo "Drawing page ${p}/${pages} (${page_layers[*]}) -> ${page_svg}"
  "${keymap_cmd[@]}" draw "${base_draw_args[@]}" -s "${page_layers[@]}" -o "${page_svg}" "${yaml}"
  mark_layer_activators_on_target_layers_as_held "${page_svg}" "${tmp_map}" >/dev/null || true

  echo "Converting ${page_svg} -> ${page_pdf}"
  convert_svg_to_pdf "${page_svg}" "${page_pdf}"

  page_pdfs+=("${page_pdf}")
done
rm -f "${tmp_map}" || true

echo "Joining pages -> ${pdf}"
join_pdfs "${pdf}" "${page_pdfs[@]}"

echo "Done: ${pdf}"
