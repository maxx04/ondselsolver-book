#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACRO_PATH="${1:-}"
FREECAD_APP="${FREECAD_APP:-$HOME/freecad/App_weekly/freecad.App}"

if [[ -z "$MACRO_PATH" || ! -f "$MACRO_PATH" ]]; then
  echo "Aufruf: $0 /pfad/zum/Beispiel.FCMacro" >&2
  exit 2
fi

if [[ ! -x "$FREECAD_APP" ]]; then
  echo "FreeCAD AppImage nicht gefunden oder nicht ausführbar: $FREECAD_APP" >&2
  echo "Passe FREECAD_APP an oder installiere App_weekly gemäß Kapitel 08." >&2
  exit 1
fi

exec "$FREECAD_APP" "$MACRO_PATH"