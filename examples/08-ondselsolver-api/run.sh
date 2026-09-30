#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
MODE="${1:-inspect}"
INPUT_PATH="${2:-$BUILD_DIR/fixtures/__cubes.asmt}"

cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" --target ondselsolver_api
"$BUILD_DIR/ondselsolver_api" "$MODE" "$INPUT_PATH"
