# 13. Joints und kinematische Bindungen

## 13.1 Verbindungsmodell

Joints drücken Beziehungen zwischen zwei Körpern beziehungsweise zwei Markern aus. Der ASMT-Basistyp `ASMTItemIJ` bietet `setMarkerI(path)` und `setMarkerJ(path)`. Ein Joint besteht damit mindestens aus Typ, Name, zwei Markerreferenzen und gegebenenfalls typabhängigen Parametern.

Die Solverbindung entsteht nicht allein durch das Erzeugen der C++-Instanz. Die Referenzpfade müssen in der Assembly auf vorhandene Marker zeigen, und der Joint muss in die Assembly aufgenommen werden, zum Beispiel durch `assembly->addJoint(joint)`.

## 13.2 Im ASMT-Parser erkannte Jointtypen

Der folgende Katalog entspricht den Typzweigen in `ASMTAssembly::readJoints()` des hier eingebundenen Solverstands. Er bezeichnet Parsererkennung, nicht eine Garantie, dass jede denkbare Parameterkombination numerisch sinnvoll oder in FreeCAD exportierbar ist.

| Gruppe | ASMT-Typen | Bedeutung auf hoher Ebene |
|---|---|---|
| Fixe/rotatorische Punktverbindungen | `FixedJoint`, `RevoluteJoint`, `SphericalJoint`, `UniversalJoint`, `ConstantVelocityJoint` | Punkte zusammenhalten und rotationsabhängige Freiheitsgrade beschränken |
| Axiale und planare Verbindungen | `CylindricalJoint`, `TranslationalJoint`, `PointInLineJoint`, `PlanarJoint`, `PointInPlaneJoint`, `LineInPlaneJoint` | Linie/Achse oder Ebene als Bezug für erlaubte Bewegung nutzen |
| Orientierungsvorgaben | `NoRotationJoint`, `ParallelAxesJoint`, `PerpendicularJoint`, `AngleJoint` | relative Orientierung bzw. Winkelbeziehung festlegen |
| Übersetzungsbeziehungen | `GearJoint`, `RackPinionJoint`, `ScrewJoint` | gekoppelte Rotation/Translation über Verhältnis, Radius oder Steigung vorgeben |
| Zusammengesetzte Gelenke | `SphSphJoint`, `CylSphJoint`, `RevCylJoint`, `RevRevJoint` | Kombinationen elementarer Verbindungstypen modellieren |

Die interne Verteilung auf Basisklassen folgt der Mechanik: `ASMTAtPointJoint`, `ASMTInLineJoint`, `ASMTInPlaneJoint` und `ASMTCompoundJoint` bündeln gemeinsame Erzeugungslogik. Konkrete Klassen wie `ASMTRevoluteJoint` oder `ASMTGearJoint` ergänzen ihre Parameter über eigene Felder und `createMbD()`-Implementierungen.

## 13.3 Das Muster für den C++-Aufbau

```cpp
auto joint = MbD::ASMTRevoluteJoint::With();
joint->setName("Hinge");
joint->setMarkerI("/Assembly/Base/HingeMarker");
joint->setMarkerJ("/Assembly/Link/HingeMarker");
assembly->addJoint(joint);
```

Das Beispiel zeigt die gemeinsame API, nicht ein vollständiges lauffähiges Mechanikmodell. Namen und Pfade müssen den tatsächlichen Container- und Marker-Namen entsprechen. Zusätzlich müssen beide Marker existieren und auf den richtigen lokalen Koordinatensystemen liegen. Für Sondertypen wie `AngleJoint`, `GearJoint` und `ScrewJoint` kommen typspezifische Parameter hinzu; ihre Feldnamen sind in den konkreten Headern (`ASMTAngleJoint.h` usw.) definiert und dürfen nicht aus dem Jointnamen erraten werden.

Der ausführbare Modus `./run.sh joint-api` in [`examples/08-ondselsolver-api`](./examples/08-ondselsolver-api/README.md) prüft Fabrik, Marker-Setter, `addJoint()` und Owner. Er löst den absichtlich zusätzlich angelegten Joint nicht.

## 13.4 Gemeinsame Ergebnisfunktionen

Joints erben die Auswertungsfunktionen von `ASMTConstraintSet` und `ASMTItem`:

- `updateFromMbD()` übernimmt den berechneten Solverzustand.
- `compareResults(type)` vergleicht Objekt-/Solverdaten für eine Analyseart.
- `outputResults(type)` gibt Ergebnisse aus.
- `createMbD(system, units)` erzeugt die interne Jointrepräsentation.
- `storeOnLevel(...)` serialisiert den Joint; `storeOnTimeSeries(...)` schreibt Joint-Zeitreihen.

`ASMTJoint::readJointSeries()` lädt Zeitreihenwerte. Dies ist keine Voraussetzung für die Definition eines Eingabe-Joints.

## 13.5 Kontakte: Klassen vorhanden, Pfad prüfen

Der Quellbaum enthält `ASMTContact`, `ASMTConeConeContact`, `ASMTCylConeContact` und `ASMTCylCylContact`. Diese Klassen sind als Modellfamilie erkennbar, werden aber im gezeigten `readJoints()`-Dispatch nicht als Joint-Abschnitte angelegt. Sie dürfen daher nicht mit den oben bestätigten ASMT-Jointtypen gleichgesetzt werden. Vor Verwendung sind Parser, `createMbD()` und Tests im konkreten Commit zu prüfen.

## 13.6 Freiheitsgrade und Überbestimmung

Ein Joint fügt Gleichungsbedingungen hinzu und reduziert die Beweglichkeit. Wird ein Mechanismus überbestimmt oder geometrisch widersprüchlich, kann die Lösung scheitern. Der richtige Workflow ist:

1. Markerpositionen und lokale Achsen kontrollieren.
2. Joints zunächst schrittweise ergänzen.
3. Nach jeder Änderung mit einem kleinen bekannten Modell lösen.
4. Erst danach Bewegungen und Lasten ergänzen.

Der numerische Solver kann keine inkonsistente Modellabsicht erraten; eine Fehlermeldung ist deshalb häufig ein Hinweis auf Geometrie, redundante Constraints oder ungünstige Anfangswerte.