#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
FIXTURE_NAME="${1:-__cubes.asmt}"

cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" --target solve_asmt

ASMT_FILE="$BUILD_DIR/fixtures/$FIXTURE_NAME"
if [[ ! -f "$ASMT_FILE" ]]; then
  echo "Unbekannte ASMT-Datei: $FIXTURE_NAME" >&2
  echo "Verfügbar: __cubes.asmt, fourbar.asmt, piston.asmt" >&2
  exit 2
fi

"$BUILD_DIR/solve_asmt" "$ASMT_FILE" "$BUILD_DIR/${FIXTURE_NAME%.asmt}-solved.asmt"