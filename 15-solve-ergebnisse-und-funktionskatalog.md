# 15. Solve, Ergebnisse und Funktionskatalog

## 15.1 Einmaliges Lösen und Analysearten

`ASMTAssembly::solve()` ist laut Header ein One-shot-Solve der Assembly. Im aktuellen Quellstand setzt die Methode allerdings zuerst die Simulationsparameter fest auf `tstart = tend = 0`, `hmin = 1e-9`, `hmax = 1`, `hout = 0.04` und `errorTol = 1e-6` und ruft dann `runKINEMATIC()` auf. Das ist eine Lösung der Anfangskonfiguration, keine konfigurierbare Zeitintegration. Eigene zuvor gesetzte Simulationsparameter werden dadurch überschrieben. Der praktische Aufruf bleibt daher einfach:

```cpp
auto assembly = MbD::ASMTAssembly::assemblyFromFile(inputPath);
assembly->solve();
assembly->outputFile(outputPath);
```

Die Assembly stellt außerdem `runKINEMATIC()`, `runPreDrag()`, `runDragStep(parts)` und `runPostDrag()` bereit. `runKINEMATIC()` verwendet die aktuell gesetzten Parameter, fängt aber `SimulationStoppingError` intern ab und gibt keinen Erfolgsstatus zurück. Das ist eine Einschränkung der Fehlerbeobachtbarkeit. Dragging-Aufrufe und `run*Test()`-Funktionen sind spezialisierte Interaktions-/Testpfade, nicht der normale Batch-Solve-Vertrag. `outputFor(type)`, `compareResults(type)` und `outputResults(type)` sind Analyse-/Diagnosepfade.

## 15.2 Ergebnisse abfragen

Ergebnisserien liegen abhängig vom Typ in `times`, `partSeries`, `jointSeries` oder `motionSeries`. `numberOfFrames()` liefert die Anzahl vorhandener Frames; `updateForFrame(index)` aktualisiert räumliche Objekte auf einen Frame. Räumliche Getter wie `getPosition3D(i)`, `getRotationMatrix(i)`, `getVelocity3D(i)` und `getAcceleration3D(i)` lesen die entsprechenden Frame-Daten.

Der ASMT-Schreibpfad `outputFile()` ist der einfachste persistente Ergebniszugriff. Diese Ausgabe ist kein automatischer Export in ein FreeCAD-Dokument und ersetzt keine CAD-Geometrie. Das Buchbeispiel überprüft den End-to-End-Pfad, indem es die gelöste Datei erneut als ASMT-Artefakt schreibt.

Das erneute Einlesen dieser Ausgabe ist im aktuellen GCC-Build nicht verlässlich: `ASMTJoint::storeOnLevel()` erzeugt aus dem RTTI-Namen teilweise ungültige Typzeilen. Beispiel 08 prüft daher die ASMT-Anwendungsfunktionen im Speicher und behauptet keinen erfolgreichen Serializer-Roundtrip.

## 15.3 Fehlerbehandlung und Diagnose

Das Clientprogramm sollte Parser-, Datei- und Solverfehler abfangen. Die vorhandenen Exceptions umfassen beispielsweise `SimulationStoppingError`, `NewtonRaphsonError`, `MaximumIterationError`, `SingularMatrixError`, `TooSmallStepSizeError`, `TooManyTriesError`, `DiscontinuityError` und `NotKinematicError`. Viele leiten sich von Standard-Exceptions ab; `catch (const std::exception&)` bildet daher eine brauchbare äußere Fehlergrenze.

Bei einem Solve-Fehler zuerst prüfen:

- Ist die ASMT-Einrückung und Blockreihenfolge gültig?
- Existieren alle Markerpfade und zeigen sie auf sinnvolle Koordinatensysteme?
- Ist die Zahl und Kombination der Constraints konsistent?
- Liegt die Anfangslage nahe einer lösbaren Konfiguration?
- Sind Zeitintervall, Schrittweiten und Einheitenskalen plausibel?

`setDebug(true)` und die vorhandenen Ergebnis-/Vergleichsfunktionen können bei der Diagnose helfen, sind aber keine Garantie für eine vollständige Solverdiagnose.

## 15.4 Öffentliche ASMT-Funktionen nach Klassenfamilie

Dieser Katalog beschreibt die fachlich relevanten Methoden des Anwendungszugangs; alle vererbten Parser-/Serializer-Helfer werden nicht pro Unterklasse wiederholt.

| Familie | Funktionen und Zweck |
|---|---|
| Assembly | `With`, `assemblyFromFile`, `solve`, `outputFile`; `addPart`, `addJoint`, `addMotion`, `addLimit`; `setConstantGravity`, `setSimulationParameters`; Namens-/Pfadsuche `partNamed`, `partPartialNamed` (nur mit garantiertem Treffer), `partAt`, `markerAt`, `jointAt`, `motionAt`, `forceTorqueAt`; Framezugriff `numberOfFrames`, `updateForFrame` |
| Gemeinsames Objekt (`ASMTItem`) | `setName`, `classname`, `root`, `partOrAssembly`, `part`, `fullName`, `initialize`; Zustands-/MbD-Übergang `createMbD`, `deleteMbD`, `updateFromInputState`, `updateFromInitiallyAssembledState`, `updateFromMbD`, `updateForFrame`; Ausgabe `compareResults`, `outputResults` |
| Lage (`ASMTSpatialItem`) | `setPosition3D`, `getPosition3D`, `setRotationMatrix`, `getRotationMatrix`, `setQuarternions`, `getQuarternions`, `restorePosRot` |
| Räumlicher Container | `setPrincipalMassMarker`, `addRefPoint`, `addMarker`, `markerList`, `generateUniqueMarkerName`; `setVelocity3D`, `setOmega3D`, `getVelocity3D`, `getOmega3D`, `getAcceleration3D`, `getAlpha3D`; `rOcmO`, `qEp` |
| Verbindungen (`ASMTItemIJ`/`ASMTJoint`) | `setMarkerI`, `setMarkerJ`; geerbte Solve-/Resultmethoden; `readJointSeries` und `storeOnTimeSeries` für Ergebnisdaten |
| Motion | `initMarkers`, `readMotionSeries`, `storeOnTimeSeries`; konkrete Bewegungsgesetze in den Unterklassen |
| Limits | `setmotionJoint`; Typ und Grenzparameter in `ASMTRotationLimit`/`ASMTTranslationLimit` |
| Simulation | `settstart`, `settend`, `sethmin`, `sethmax`, `sethout`, `seterrorTol`, `setmaxIter`; weitere toleranz-/integratorbezogene Felder in `ASMTSimulationParameters` |
| Datei und Text | `parseASMT`, `read*`, `storeOnLevel*`, `storeOnTimeSeries`, `logString`; Parser-/Serialisierungsmechanik, kein typischer Clientcode |

Die API ist vererbungsbasiert: Eine konkrete Unterklasse erhält zahlreiche Funktionen aus `ASMTItem`, `ASMTSpatialItem` oder `ASMTConstraintSet`. Der Tabellenkatalog fasst diese einmal pro Familie zusammen, damit dieselbe Funktion nicht dutzendfach als scheinbar eigene Methode wiederholt wird.

## 15.5 Interner numerischer Kern: Klassifikation

Der Solverkern bietet wesentlich mehr Methoden als für eine gewöhnliche ASMT-Anwendung benötigt werden. Für Orientierung lassen sie sich so einteilen:

| Funktionsbereich | Beispiele für Klassen | Verantwortung |
|---|---|---|
| System und Zustandsmodell | `System`, `StateData`, `Part`, `MarkerFrame`, `CartesianFrame` | globale Mechanik, Zustandsvariablen und Bezugssysteme verwalten |
| Constraints und Joints | `Constraint`, `ConstraintSet`, `ConstraintIJ`, `RevoluteJoint`, `FixedJoint`, Spezial-Constraints | Gleichungen und kinematische Bindungen aufstellen |
| Position-/Geschwindigkeits-/Beschleunigungslöser | `PosNewtonRaphson`, `VelSolver`, `AccNewtonRaphson` und Kinematikvarianten | algebraische Gleichungen auf verschiedenen Ableitungsstufen lösen |
| Zeitintegration | `Integrator`, `KineIntegrator`, `BasicIntegrator`, `LinearMultiStepMethod`, `StableBackwardDifference` | Zustände über die Zeit integrieren |
| Lineare Algebra | `FullMatrix`, `SparseMatrix`, `FullVector`, `SparseVector`, `MatrixSolver`, `GE*`, `LDU*` | Gleichungssysteme und Zerlegungen berechnen |
| Symbolische Ausdrücke/Funktionen | `Function`, `ExpressionX`, `Polynomial`, `Sine`, `Cosine`, `GeneralSpline`, `PiecewiseFunction` | zeitabhängige Gesetze und Ableitungen repräsentieren |
| Einheiten und Numerik | `Units`, `MbDMath`, `Numeric`, `EulerParameters`, `Orientation` | Skalen, numerische Hilfen und Rotationsdarstellungen |
| Fehlerzustände | `NewtonRaphsonError`, `SingularMatrixError`, `MaximumIterationError` usw. | Konvergenz- und Simulationsfehler melden |

Diese Klassen sind keine austauschbaren „Utilities“. Viele Solvertypen werden intern anhand des Modells ausgewählt und setzen Kenntnisse über Gleichungsaufbau, Freiheitsgrade und Zustandsverwaltung voraus. Für die Anwendungsintegration zuerst ASMT nutzen; direktes Arbeiten mit dem MbD-Kern ist eine bewusste Erweiterung.

## 15.6 Reproduzierbare Validierung

Das Projekt enthält drei reale Fixtures und den End-to-End-Aufruf unter [`examples/07-ondselsolver-real-asmt`](./examples/07-ondselsolver-real-asmt/README.md). Die drei Prüfpfade decken unterschiedliche Modelltypen ab:

- `__cubes.asmt`: zwei Körper mit Fixierung und Winkelbedingung
- `fourbar.asmt`: Viergelenkmechanismus
- `piston.asmt`: Kurbel-Schieber

Ausführen:

```bash
cd examples/07-ondselsolver-real-asmt
./run.sh
./run.sh fourbar.asmt
./run.sh piston.asmt
```

Damit wird der echte lokale OndselSolver gebaut/verwendet, die Datei eingelesen, `solve()` ausgeführt und ein Ergebnisfile geschrieben. Wenn der API-Code geändert oder neue ASMT-Typen aufgenommen werden, sollten Parser-, Solve- und Ausgabeweg jeweils mit einem gezielten Fixture erneut getestet werden.

## 15.7 Quellenhinweis

Die methodennahen Aussagen in diesen Kapiteln folgen den Headern und Implementierungen `ASMTAssembly.*`, `ASMTItem.*`, `ASMTSpatialItem.*`, `ASMTSpatialContainer.*`, `ASMTPart.*`, `ASMTJoint.*`, `ASMTMotion.*`, `ASMTLimit.*` und den jeweiligen Unterklassen im eingebundenen Submodul. Besonders wichtig sind `ASMTAssembly::readJoints()`, `readMotions()` und `readLimits()`: Sie definieren die im konkreten Parserstand erkannten ASMT-Typen.