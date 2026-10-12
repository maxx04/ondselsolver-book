#!/usr/bin/env bash
# Erzeugt buch.pdf aus buch.tex.
# Mehrere LaTeX-Läufe aktualisieren Inhaltsverzeichnis und Querverweise.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

LATEX=""
for candidate in lualatex xelatex pdflatex; do
  if [[ -n "$candidate" ]] && command -v "$candidate" >/dev/null; then
    LATEX="$candidate"
    break
  fi
done
if [[ -z "$LATEX" ]]; then
  echo "Keine LaTeX-Engine gefunden (lualatex, xelatex oder pdflatex erforderlich)." >&2
  exit 1
fi

BUILD_DIR="$ROOT/build/latex"
mkdir -p "$BUILD_DIR"
for pass in 1 2 3; do
  "$LATEX" \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -output-directory="$BUILD_DIR" \
    "$ROOT/buch.tex"
done
cp "$BUILD_DIR/buch.pdf" "$ROOT/buch.pdf"
echo "Fertig: buch.pdf"
