# 09. Konkrete OndselSolver-Beispiele mit ASMT-Dateien

## 1. Vom Datenmodell zum echten Solve

Die vorigen C++-Demos erklären einzelne Ideen. Dieses Beispiel verarbeitet dagegen echte Dateien aus OndselSolvers `testapp`-Sammlung. Es ruft den Originalcode `MbD::ASMTAssembly::assemblyFromFile()`, `solve()` und `outputFile()` auf.

Das Beispiel liegt unter [`examples/07-ondselsolver-real-asmt`](./examples/07-ondselsolver-real-asmt/README.md). CMake baut OndselSolver aus dem auf einen bekannten Stand fixierten Submodul `vendor/OndselSolver`.

## 2. Die drei konkreten Mechanismen

Die drei verwendeten Fixture-Dateien liegen direkt im Beispielordner und werden beim CMake-Konfigurieren in den Beispiel-Build kopiert:

| Datei | Mechanismus | Relevante Beziehungen |
|---|---|---|
| `__cubes.asmt` | zwei Körper | Fixed Joint und Angle Joint |
| `fourbar.asmt` | Viergelenk | mehrere Gelenke zwischen drei beweglichen Teilen und der Assembly |
| `piston.asmt` | Kurbel-Schieber | Gelenke einschließlich eines zylindrischen Gelenks |

Die Dateien sind echte Solver-Eingaben und keine nachträglich vereinfachten Pseudodateien. Sie enthalten unter anderem Assembly- und Part-Positionen, Rotationsmatrizen, RefPoints, Marker, Masseneigenschaften, Joint-Referenzen und Simulationsparameter.

## 3. Eine ASMT-Datei lesen

Eine ASMT-Datei beginnt mit dem Formatkopf und der Root-Assembly. Danach folgen eingerückte Abschnitte. Beispielhaft sieht man in `__cubes.asmt`:

```text
OndselSolver
Assembly
	Notes
	Name
		OndselAssembly
	Position3D
		0 0 0
	RotationMatrix
		1 0 0
		0 1 0
		0 0 1
```

Weiter unten referenzieren Joints die Marker ihrer beiden Seiten. Ein Fixed Joint fixiert den ersten Körper an der Assembly; das Angle Joint beschreibt die Winkelbeziehung zum zweiten Körper. Die Marker sind lokale Bezugssysteme, keine sichtbaren CAD-Körper.

Die Geometrie ist in diesen Solver-Fixtures nicht als vollständiger CAD-B-Rep enthalten. Das Beispiel demonstriert daher den echten Kinematik- und Constraint-Solve mit konkreten Körpern, Markern und Gelenken, nicht die Darstellung von Volumenkörpern.

## 4. Bauen, lösen und Ergebnis schreiben

Im Repository-Root:

```bash
./examples/07-ondselsolver-real-asmt/run.sh
./examples/07-ondselsolver-real-asmt/run.sh fourbar.asmt
./examples/07-ondselsolver-real-asmt/run.sh piston.asmt
```

Der erste Aufruf baut die Solver-Bibliothek und den kleinen Runner. Danach wird die ausgewählte `.asmt`-Datei geladen, `ASMTAssembly::solve()` führt den Solve der Anfangslage aus und `outputFile()` serialisiert das Ergebnis erneut.

Die Ergebnisse liegen im jeweiligen Build-Verzeichnis:

- `build/__cubes-solved.asmt`
- `build/fourbar-solved.asmt`
- `build/piston-solved.asmt`

Im Log erscheinen die Solver-Konvergenzwerte. Bei `__cubes.asmt` meldet der Solver außerdem eine entfernte redundante Winkelbedingung; bei `fourbar` und `piston` sind mehrere Iterationswerte sichtbar, die gegen die Solve-Toleranz konvergieren.

## 5. Installierte Bibliothek und reproduzierbarer Build

In der aktuellen Sandbox-Installation stürzte ein separater Runner gegen `~/freecad-sandbox/install/lib/libOndselSolver.so` beim ASMT-Marker-Parsing mit einem Heap-Fehler ab. Derselbe Fixture-Lauf war erfolgreich, sobald OndselSolver frisch aus der Workspace-Source gebaut wurde. Deshalb baut dieses Beispiel die Source-Version mit und linkt direkt dagegen.

Das ist für Lernende auch ein wichtiger Integrationspunkt: Bei C++-Bibliotheken müssen Header, Shared Library und ABI aus zueinander passenden Builds stammen. Ein erfolgreicher Link allein beweist noch nicht, dass ein installierter Solver-Build korrekt zum aktuellen Source-Stand passt.