# 08. FreeCAD AppImage unter Ubuntu und Dash-Icon

## 1. Welche Installation wird verwendet?

Auf diesem Rechner existieren drei getrennte FreeCAD-Installationen:

| Installation | Pfad | Zweck |
|---|---|---|
| FreeCAD App / Weekly | `~/freecad/App_weekly/freecad.App` | AppImage für die GUI-Beispiele in diesem Buch |
| Vanilla | `~/freecad/install/bin/FreeCAD` | separat gebautes FreeCAD |
| Sandbox | `~/freecad-sandbox/install/bin/FreeCAD` | Tests der Änderungen aus der Sandbox |

Die GUI-Makro-Runner verwenden standardmäßig die FreeCAD App aus `App_weekly`. Sie starten nicht automatisch Vanilla oder Sandbox. Ein abweichender AppImage-Pfad lässt sich über `FREECAD_APP` angeben.

## 2. AppImage unter Ubuntu einrichten

Ein AppImage wird nicht mit `apt` installiert. Es ist eine ausführbare, portable Datei. Lege die offizielle FreeCAD-Linux-x86_64-AppImage in einem dauerhaften Ordner ab, zum Beispiel als `~/freecad/App_weekly/freecad.App`. Mache sie ausführbar und starte sie:

```bash
mkdir -p "$HOME/freecad/App_weekly"
chmod +x "$HOME/freecad/App_weekly/freecad.App"
"$HOME/freecad/App_weekly/freecad.App"
```

Für die wöchentlich aktualisierte AppImage auf diesem Rechner kann `~/freecad/App_weekly/update-weekly-appimage.sh` verwendet werden. Das Skript benötigt die GitHub-CLI `gh` und lädt das offizielle Weekly-AppImage samt SHA256-Prüfung.

Falls Ubuntu meldet, dass `libfuse.so.2` fehlt, installiere das passende FUSE-2-Kompatibilitätspaket:

```bash
# Ubuntu 24.04 und neuer
sudo apt install libfuse2t64

# Ältere Ubuntu-Versionen, falls libfuse2t64 nicht verfügbar ist
sudo apt install libfuse2
```

## 3. Dash-Eintrag und Icon erstellen

Zuerst wird das FreeCAD-Icon aus dem AppImage in das Benutzerprofil kopiert:

```bash
APPIMAGE="$HOME/freecad/App_weekly/freecad.App"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
TMP_DIR="$(mktemp -d)"

mkdir -p "$ICON_DIR" "$DESKTOP_DIR"
(
  cd "$TMP_DIR"
  "$APPIMAGE" --appimage-extract
)
install -m 644 "$TMP_DIR/squashfs-root/.DirIcon" "$ICON_DIR/freecad-weekly.svg"
rm -rf "$TMP_DIR"
```

Danach den Desktop-Eintrag erstellen:

```bash
cat > "$DESKTOP_DIR/freecad-weekly.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=FreeCAD Weekly (App)
Comment=FreeCAD Weekly AppImage
Exec=$HOME/freecad/App_weekly/freecad.App %F
Icon=$ICON_DIR/freecad-weekly.svg
Terminal=false
Categories=Graphics;Engineering;Science;
MimeType=application/x-extension-fcstd;
EOF

chmod +x "$DESKTOP_DIR/freecad-weekly.desktop"
```

Drücke die Super-Taste und suche nach „FreeCAD Weekly (App)“. Über das Kontextmenü kann der Eintrag zu den Favoriten hinzugefügt werden. Falls die Suche den neuen Eintrag nicht sofort zeigt, melde dich einmal ab und wieder an.

## 4. Beispiele starten

Die GUI-Beispiele verwenden `~/freecad/App_weekly/freecad.App`:

```bash
cd examples/04-freecad-pipeline
./run-app.sh

cd ../05-freecad-headless
./run.sh
```

Die Beispiele `01` bis `03` und `06` sind bewusst eigenständige C++-Konsolenprogramme. Sie demonstrieren Rechenideen und ASMT-ähnliche Datenstrukturen und benötigen kein FreeCAD-AppImage. Das Verzeichnis `05-freecad-headless` bietet mit `run.sh` einen GUI-Smoke-Test und mit `run-headless.sh` weiterhin einen optionalen automatisierten Lauf ohne GUI; Headless benötigt `FreeCADCmd` und ist technisch nicht dasselbe wie die AppImage-GUI.

Für ein AppImage an einem anderen Ort kann der Pfad beim Start überschrieben werden:

```bash
FREECAD_APP="$HOME/Downloads/FreeCAD.AppImage" ./run-app.sh
```