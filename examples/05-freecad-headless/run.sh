#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/../run-with-freecad-app.sh" "$SCRIPT_DIR/FreeCADAppSmokeTest.FCMacro"
