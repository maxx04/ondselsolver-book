# Beispiele zum Buch

Diese Beispiele sind als kompilierbare Mini-Projekte im Buchprojekt organisiert. Jeder Ordner enthält ein kleines C++-Programm und eine eigene `CMakeLists.txt`, damit er separat oder über das Stammprojekt gebaut werden kann.

## Build

```bash
cmake -S examples -B examples/build
cmake --build examples/build
```

## Verfügbare Beispiele

- `01-distance-constraint` – Abstand zwischen zwei Teilen und Residuum
- `02-iterative-solver` – Einfaches iteratives Korrigieren eines Fehls
- `03-solver-data-model` – Strukturierung von Teil- und Joint-Daten
- `04-freecad-pipeline` – C++-Pipeline-Demo plus echtes FreeCAD-GUI-Makro (`./run-app.sh`)
- `05-freecad-headless` – FreeCAD-App-GUI-Smoke-Test (`./run.sh`) und optionaler Headless-Test (`./run-headless.sh`)
- `06-asmt-structure` – ASMT-ähnliche Datenstruktur mit Teilen und Gelenken als Brücke zum Solver
- `07-ondselsolver-real-asmt` – echte `.asmt`-Fixtures werden mit OndselSolver geladen, gelöst und zurückgeschrieben

Die GUI-Makros verwenden standardmäßig `~/freecad/App_weekly/freecad.App`; ein anderer AppImage-Pfad lässt sich über `FREECAD_APP` setzen. Die Beispiele `01` bis `03` und `06` sind eigenständige C++-Konsolenprogramme und benötigen kein FreeCAD-AppImage.

Beispiel `07` baut OndselSolver aus dem Submodul `vendor/OndselSolver` und ist deshalb nicht Teil des schnellen Umbrella-Builds. Die einzelnen Eingaben und Befehle stehen in [`07-ondselsolver-real-asmt/README.md`](./07-ondselsolver-real-asmt/README.md).

## Praxisbezug

Der Aufbau der Beispiele folgt der realen Logik des Buchs: ein CAD-Modell wird in ein solverfähiges, strukturiertes Format überführt, dort berechnet und anschließend wieder in den CAD-Kontext zurückgebracht.
