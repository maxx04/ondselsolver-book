#!/bin/bash
# Laedt die aktuellste FreeCAD-Weekly-AppImage (Linux x86_64) von GitHub
# (github.com/FreeCAD/FreeCAD, Tags "weekly-YYYY.MM.DD"), prueft die mitgelieferte
# SHA256-Pruefsumme und legt das Ergebnis als "freecad.App" in App_weekly/ ab - ueberschreibt
# nur diesen einen, versionslosen Namen, laesst bereits vorhandene, versionsspezifisch benannte
# AppImages (z.B. aus frueheren manuellen Downloads) unangetastet. Braucht die authentifizierte
# gh-CLI (kein GitHub-Token noetig, oeffentliches Repo).
set -euo pipefail

# Zielordner; laesst sich ueber FREECAD_APP_DIR ueberschreiben.
APP_DIR="${FREECAD_APP_DIR:-$HOME/freecad/App_weekly}"
TARGET="${APP_DIR}/freecad.App"
REPO="FreeCAD/FreeCAD"

mkdir -p "${APP_DIR}"

echo "Ermittle neueste Weekly-Release..."
TAG=$(gh release list --repo "${REPO}" --json tagName,isDraft --jq \
    '[.[] | select(.isDraft == false) | select(.tagName | startswith("weekly-"))] | .[0].tagName')
if [ -z "${TAG}" ] || [ "${TAG}" = "null" ]; then
    echo "Keine Weekly-Release gefunden." >&2
    exit 1
fi
echo "Neueste Weekly: ${TAG}"

ASSET="FreeCAD_${TAG}-Linux-x86_64.AppImage"
SHA_ASSET="${ASSET}-SHA256.txt"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "Lade ${ASSET} ..."
gh release download "${TAG}" --repo "${REPO}" --pattern "${ASSET}" --dir "${TMP_DIR}"
gh release download "${TAG}" --repo "${REPO}" --pattern "${SHA_ASSET}" --dir "${TMP_DIR}"

echo "Pruefe SHA256..."
(cd "${TMP_DIR}" && sha256sum -c "${SHA_ASSET}")

chmod +x "${TMP_DIR}/${ASSET}"
mv "${TMP_DIR}/${ASSET}" "${TARGET}"
echo "Fertig: ${TARGET} (${TAG})"
