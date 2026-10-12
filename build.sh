#!/usr/bin/env bash
# Erzeugt buch.html und buch.pdf aus buch.md.
# Kapitel, Abschnitte, Abbildungen und Querverweise nummeriert tools/nummerierung.lua.
#
#   ./build.sh          HTML und PDF
#   ./build.sh html     nur HTML
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

pandoc buch.md \
  --from markdown+lists_without_preceding_blankline \
  --to html5 --standalone \
  --toc --toc-depth=2 --mathml \
  --lua-filter tools/nummerierung.lua \
  --include-in-header tools/buch-kopf.html \
  --output buch.html
echo "Fertig: buch.html"

[[ "${1:-}" == "html" ]] && exit 0

CHROME=""
for candidate in "${CHROME_BIN:-}" chromium chromium-browser google-chrome google-chrome-stable; do
  if [[ -n "$candidate" ]] && command -v "$candidate" >/dev/null; then
    CHROME="$candidate"
    break
  fi
done
if [[ -z "$CHROME" ]]; then
  echo "Kein Chromium/Chrome gefunden – PDF übersprungen (CHROME_BIN setzen)." >&2
  exit 1
fi

# Die Wartezeit gibt den Mermaid-Diagrammen Zeit zum Zeichnen.
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=15000 \
  --print-to-pdf="$ROOT/buch.pdf" "file://$ROOT/buch.html" 2>/dev/null
echo "Fertig: buch.pdf"
