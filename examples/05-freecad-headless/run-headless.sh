#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SANDBOX_INSTALL="${FREECAD_SANDBOX_INSTALL:-$HOME/freecad-sandbox/install}"
NEON_ROOT="${FREECAD_NEON_ROOT:-$HOME/Dokumente/FreeCAD-Development/neon-qt6-pyside6/root/usr}"
VENV_PATH="${FREECAD_VENV:-$HOME/Dokumente/FreeCAD-Development/.venv}"

CANDIDATES=(
  "${FREECAD_CMD:-}"
  "$(command -v freecadcmd || true)"
  "$(command -v FreeCADCmd || true)"
  "$SANDBOX_INSTALL/bin/FreeCADCmd"
)

FREECAD_CMD=""
for candidate in "${CANDIDATES[@]}"; do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    FREECAD_CMD="$(readlink -f "$candidate")"
    break
  fi
done

if [[ -z "$FREECAD_CMD" ]]; then
  echo "Kein FreeCADCmd gefunden. Für die GUI-Demo bitte ./run.sh verwenden."
  exit 1
fi

if [[ "$FREECAD_CMD" == "$SANDBOX_INSTALL"/bin/* ]]; then
  NEON_LIB="$NEON_ROOT/lib/x86_64-linux-gnu"
  if [[ -d "$NEON_LIB" ]]; then
    export LD_LIBRARY_PATH="$SANDBOX_INSTALL/lib:$NEON_LIB${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export QT_PLUGIN_PATH="$NEON_LIB/qt6/plugins"
  fi
  if [[ -d "$VENV_PATH" ]]; then
    export VIRTUAL_ENV="$VENV_PATH"
  fi
fi

"$FREECAD_CMD" -c "import FreeCAD; doc = FreeCAD.newDocument('HeadlessDemo'); print('FreeCAD headless gestartet:', doc.Name); print('FreeCAD-Version:', FreeCAD.Version())"