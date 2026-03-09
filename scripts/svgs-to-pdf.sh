#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Join 2+ SVG files into a single multi-page PDF.

Usage:
  ./scripts/svgs-to-pdf.sh [--out <file.pdf>] <a.svg> <b.svg> [more.svg...]

Options:
  --out <path>   Output PDF path (required)
  -h, --help     Show help

Notes:
  - Each SVG becomes one PDF page (after SVG -> PDF conversion).
  - Requires an SVG->PDF converter: rsvg-convert (recommended) or inkscape.
  - Requires a PDF join tool: pdfunite (poppler) or gs (ghostscript).

Example:
  ./scripts/svgs-to-pdf.sh --out artifacts/layouts/two-pages.pdf \
    artifacts/layouts/corne_choc.p1.svg \
    artifacts/layouts/corne_choc.p2.svg
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

OUT_PDF=""
SVGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      [[ $# -ge 2 ]] || die "--out needs a value"
      OUT_PDF="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      die "Unknown argument: $1 (use --help)"
      ;;
    *)
      SVGS+=("$1")
      shift
      ;;
  esac
done

[[ -n "${OUT_PDF}" ]] || die "Missing --out <path>"
[[ ${#SVGS[@]} -ge 2 ]] || die "Need at least 2 SVG inputs"

SVG_TO_PDF_TOOL=""
if command -v rsvg-convert >/dev/null 2>&1; then
  SVG_TO_PDF_TOOL="rsvg-convert"
elif command -v inkscape >/dev/null 2>&1; then
  SVG_TO_PDF_TOOL="inkscape"
else
  die "Missing 'rsvg-convert' or 'inkscape' for SVG -> PDF conversion."
fi

PDF_JOIN_TOOL=""
if command -v pdfunite >/dev/null 2>&1; then
  PDF_JOIN_TOOL="pdfunite"
elif command -v gs >/dev/null 2>&1; then
  PDF_JOIN_TOOL="gs"
else
  die "Missing a PDF join tool (need 'pdfunite' from poppler, or 'gs')."
fi

tmp="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp}"
}
trap cleanup EXIT

page_pdfs=()
i=1
for svg in "${SVGS[@]}"; do
  [[ -f "${svg}" ]] || die "SVG not found: ${svg}"
  page_pdf="${tmp}/page-${i}.pdf"

  echo "Converting ${svg} -> ${page_pdf}"
  if [[ "${SVG_TO_PDF_TOOL}" == "rsvg-convert" ]]; then
    rsvg-convert -f pdf -o "${page_pdf}" "${svg}"
  else
    inkscape "${svg}" --export-type=pdf --export-filename="${page_pdf}" >/dev/null
  fi

  page_pdfs+=("${page_pdf}")
  i=$((i + 1))
done

mkdir -p "$(dirname "${OUT_PDF}")"

echo "Joining ${#page_pdfs[@]} pages -> ${OUT_PDF}"
if [[ "${PDF_JOIN_TOOL}" == "pdfunite" ]]; then
  pdfunite "${page_pdfs[@]}" "${OUT_PDF}"
else
  gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="${OUT_PDF}" "${page_pdfs[@]}"
fi

echo "Done: ${OUT_PDF}"

