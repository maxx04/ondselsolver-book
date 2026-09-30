# 14. Bewegungen, Kräfte und Analyseparameter

## 14.1 Motion als vorgeschriebene Bewegung

`ASMTMotion` ist ein kinematischer ConstraintSet-Typ. Die konkreten Klassen werden im Parser unter `ConstraintSets/Motions` erkannt:

- `ASMTRotationalMotion`: vorgeschriebene Rotation
- `ASMTTranslationalMotion`: vorgeschriebene Translation
- `ASMTGeneralMotion`: allgemeinere Motion-Darstellung
- `ASMTAllowRotation`: Rotationsfreiheit beziehungsweise entsprechende Erlaubnisbedingung

Die gemeinsamen Funktionen sind `initMarkers()`, `createMbD(system, units)`, `readMotionSeries()`, `storeOnLevel()` und `storeOnTimeSeries()`. Für eine Motion müssen die Marker beziehungsweise Joint-Bezüge und die Bewegungsgesetze der konkreten Unterklasse konsistent sein. Die konkrete Parameterbenennung ist klassenabhängig; der jeweilige `ASMT*.h`-Header und ein echtes Fixture sind die Referenz.

Ein Kinematikmodell benötigt nicht immer externe Kräfte. Eine vorgeschriebene Bewegung ist eine Randbedingung und unterscheidet sich von einem Drehmoment, das eine dynamische Reaktion auslöst.

## 14.2 Limits

`ASMTLimit` referenziert über `setmotionJoint(path)` die Motion oder das Joint, auf das die Grenze wirkt. Der Parser erkennt:

- `ASMTRotationLimit`
- `ASMTTranslationLimit`

Limits werden über `assembly->addLimit(limit)` eingehängt. Grenzen sind nicht dasselbe wie ein zusätzliches Gelenk: Sie begrenzen eine Koordinate oder Bewegung und können je nach Zustand aktiv/inaktiv werden. Welche Wertebereiche und Verhaltenseigenschaften gelten, stehen in `ASMTRotationLimit.h` beziehungsweise `ASMTTranslationLimit.h` und der MbD-Implementierung.

## 14.3 Kraft, Drehmoment und Schwerkraft

`ASMTForceTorque` beschreibt eine Belastung zwischen I/J-Bezügen. Die Assembly hält solche Objekte im Container `forcesTorques`; anders als `addPart()` oder `addJoint()` ist im sichtbaren `ASMTAssembly`-Header kein `addForceTorque()`-Setter deklariert. Beim direkten C++-Aufbau muss daher der aktuelle Owner-/Container-Aufbau in den Quellen beachtet werden.

`ASMTConstantGravity` repräsentiert eine konstante Beschleunigung. Das Objekt wird mit `ASMTConstantGravity::With()` erzeugt, über `setg(x, y, z)` oder `setg(vector)` konfiguriert und mit `assembly->setConstantGravity(gravity)` der Assembly zugewiesen.

`ASMTForceTorque` und die Klassen `ASMTConeConeContact`, `ASMTCylConeContact`, `ASMTCylCylContact` sind nicht mit den vier bestätigten Motion-Typen oder dem Joint-Dispatch zu verwechseln. Die konkrete Parser- und Löseunterstützung ist für diese Typen getrennt zu prüfen.

## 14.4 Simulationseinstellungen

`ASMTSimulationParameters::With()` erzeugt die Laufzeitvorgaben. Dokumentierte Setter sind:

| Setter | Bedeutung |
|---|---|
| `settstart(t)` / `settend(t)` | Start- und Endzeit |
| `sethmin(h)` / `sethmax(h)` | minimale und maximale Integrationsschrittweite |
| `sethout(h)` | gewünschter Ausgabeabstand |
| `seterrorTol(tol)` | allgemeine Fehlertoleranz |
| `setmaxIter(n)` | Iterationsmaximum |

Weitere Felder im Header steuern unter anderem Positions-/Beschleunigungs-Kinematiktoleranzen, absolute/relative Korrektur- und Integrationstoleranzen, Grenzwerte sowie `iterMaxPosKine`, `iterMaxAccKine`, `iterMaxDyn` und `orderMax`. Nicht jedes Feld besitzt einen eigenen Setter; in diesem Stand sind einige direkt als öffentliche Member vorhanden.

```cpp
auto parameters = MbD::ASMTSimulationParameters::With();
parameters->settstart(0.0);
parameters->settend(1.0);
parameters->sethmin(1.0e-8);
parameters->sethmax(0.02);
parameters->sethout(0.01);
parameters->seterrorTol(1.0e-6);
assembly->setSimulationParameters(parameters);
assembly->runKINEMATIC();
```

Ein `tstart == tend` wird in den eingebauten Beispielroutinen ausdrücklich als Initial-Conditions-only-Fall verwendet. Für eine echte Zeitintegration ist ein Intervall mit `tend > tstart` nötig. Wichtig: `ASMTAssembly::solve()` setzt die Parameter vor dem Lauf selbst wieder auf seine eingebauten Werte mit `tstart == tend == 0`. Wer eigene Zeitgrenzen konfiguriert, darf daher nicht erwarten, dass ein anschließendes `solve()` sie verwendet; der direkte `runKINEMATIC()`-Pfad nutzt die gesetzten Einstellungen, hat im aktuellen Code aber eine eigene Fehlerbehandlungsgrenze (siehe Kapitel 15).

Der Modus `./run.sh settings-api` in [`examples/08-ondselsolver-api`](./examples/08-ondselsolver-api/README.md) prüft die Setter und Owner-Verknüpfungen, ohne danach `solve()` aufzurufen.

## 14.5 Animation, Zeit und Einheiten

`ASMTAnimationParameters` enthält Einstellungen für die Darstellung/Frames und ist von den physikalischen Integrationsparametern zu unterscheiden. `ASMTTime` bindet die Zeitvariable für Funktionen ein. `Units` bündelt Zeit-, Masse-, Längen- und Winkelskalen sowie abgeleitete Faktoren; die Standardfaktoren stehen in `Units.h`.

Alle Komponenten eines Modells müssen dieselbe Einheitenskala benutzen. Insbesondere Winkelwerte in ASMT sind im Solverkontext typischerweise Radiant; die Fixture `__cubes.asmt` zeigt für 10 Grad den Wert `0.17453292519943295`. Eine stillschweigende Umrechnung von Grad nach Radiant sollte man nicht voraussetzen.

## 14.6 Programmatisch unterstützte Klassenfamilien im Überblick

Der ASMT-Parser erkennt die vier Motiontypen und die zwei Limittypen oben. Er lädt außerdem ForceTorque- und ConstantGravity-Abschnitte. `GeneralConstraintSets` und `KinematicIJs` sind im geprüften Parserstand nicht vollständig implementiert. Ein Dateiformatblock, ein Header und ein erfolgreicher Solverpfad sind drei verschiedene Unterstützungsstufen; in Tests sollten alle drei separat bestätigt werden.