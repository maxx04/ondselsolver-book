#!/usr/bin/env bash
set -euo pipefail

FREECAD_APP="${FREECAD_APP:-$HOME/freecad/App_weekly/freecad.App}"

if [[ ! -x "$FREECAD_APP" ]]; then
  echo "FreeCAD AppImage nicht gefunden oder nicht ausführbar: $FREECAD_APP" >&2
  echo "Passe FREECAD_APP an oder installiere App_weekly gemäß Kapitel 08." >&2
  exit 1
fi

# Das AppImage startet mit dem Unterbefehl "freecadcmd" FreeCAD ohne GUI.
exec "$FREECAD_APP" freecadcmd -c "import FreeCAD as App; doc = App.newDocument('HeadlessDemo'); print('FreeCAD headless gestartet:', doc.Name); print('FreeCAD-Version:', App.Version())"
