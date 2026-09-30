# Echtes ASMT mit OndselSolver lösen

Dieses Beispiel baut OndselSolver aus dem Git-Submodul `vendor/OndselSolver`, lädt eine der drei lokal bereitgestellten ASMT-Dateien (Original-Fixtures aus `testapp`), ruft die echte `MbD::ASMTAssembly::solve()`-Implementierung auf und schreibt anschließend die gelöste Assembly wieder als ASMT-Datei. Es greift nicht auf eine eventuell abweichende Systeminstallation zurück.

Die CMake-Konfiguration kopiert drei vorhandene Solver-Fixtures in den Build-Ordner:

- `__cubes.asmt` – zwei Körper mit Fixed- und Angle-Joint; Standardfall
- `fourbar.asmt` – Viergelenk-Mechanismus
- `piston.asmt` – Kurbel-Schieber-Mechanismus

## Ausführen

```bash
./run.sh
./run.sh fourbar.asmt
./run.sh piston.asmt
```

Der erste Lauf baut die Solver-Bibliothek mit; Folgeaufrufe verwenden den Build-Ordner wieder. Nach jedem Lauf liegt die serialisierte Solver-Ausgabe dort, zum Beispiel `build/__cubes-solved.asmt`.

Im Unterschied zu den vorigen didaktischen Datenmodellen ist dies kein nachgebauter Solver: Das Programm linkt gegen `libOndselSolver` und nutzt den echten ASMT-Parser und Solve-Pfad.