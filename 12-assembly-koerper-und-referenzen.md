# 12. Assembly, Körper und räumliche Referenzen

## 12.1 `ASMTAssembly`: die Modellwurzel

`ASMTAssembly` erbt von `ASMTSpatialContainer`. Sie ist daher gleichzeitig Root-Assembly, räumliches Objekt und Container für Unterobjekte. Die wichtigsten aufrufbaren Methoden sind:

| Funktion | Verwendung |
|---|---|
| `With()` | leere Assembly erzeugen |
| `assemblyFromFile(filename)` | ASMT-Datei parsen und Assembly zurückgeben |
| `solve()` | Assembly einmal lösen; Details in Kapitel 15 |
| `outputFile(filename)` | Assembly samt verfügbarem Ergebnis serialisieren |
| `addPart(part)`, `addJoint(joint)`, `addMotion(motion)`, `addLimit(limit)` | Objekte zum Modell hinzufügen |
| `setConstantGravity(gravity)`, `setSimulationParameters(parameters)` | globale Analysevorgaben setzen |
| `partNamed(name)`, `partPartialNamed(name)` | Part nach vollständigem oder partiellem Namen suchen |
| `partAt(path)`, `markerAt(path)`, `jointAt(path)`, `motionAt(path)`, `forceTorqueAt(path)` | Objekt anhand eines ASMT-Pfads auflösen |
| `markerMap()`, `connectorList()` | Marker- beziehungsweise Connector-Übersichten abrufen |
| `numberOfFrames()`, `updateForFrame(index)` | verfügbare Ergebnisframes abfragen und einen Frame aktivieren |
| `setNotes(text)`, `setFilename(text)`, `setDebug(bool)` | Metadaten und Diagnoseeinstellung setzen |

`parts`, `joints`, `motions`, `limits` und `forcesTorques` sind im Header als `shared_ptr` auf Container sichtbar. Das ist eine konkrete Implementierungseigenschaft. Für neue Programme sind die Methoden `addPart()` und ihre Gegenstücke vorzuziehen, weil sie die Owner-Verknüpfung pflegen.

### Beispiel: vorhandene Assembly inspizieren

```cpp
auto assembly = MbD::ASMTAssembly::assemblyFromFile("fourbar.asmt");
std::cout << "Parts: " << assembly->parts->size() << '\n';
for (const auto& part : *assembly->parts) {
    std::cout << "Part: " << part->name << '\n';
}
```

Die Namen sind fixtureabhängig. Achtung: `partNamed()` und `partPartialNamed()` behandeln einen nicht gefundenen Namen im aktuellen Implementierungsstand nicht sicher, sondern dereferenzieren den Suchiterator. Verwende diese Methoden nur mit verifizierten Namen. `partAt(path)` liefert dagegen bei Nichttreffer `nullptr`.

Ausführbar mit `./run.sh inspect` im Ordner [`examples/08-ondselsolver-api`](./examples/08-ondselsolver-api/README.md).

## 12.2 Basisklasse `ASMTItem`

Die ASMT-Objekte teilen sich eine Basisklasse. Fachlich relevante gemeinsame Funktionen:

- `setName()` und `classname()` verwalten beziehungsweise liefern Identität/Typ.
- `root()`, `partOrAssembly()` und `part()` navigieren in der Objektstruktur.
- `fullName(partialName)` bildet einen vollständigen Namen/Pfad.
- `initialize()` richtet ein Objekt ein.
- `createMbD(system, units)` und `deleteMbD()` erzeugen beziehungsweise entfernen die interne MbD-Repräsentation.
- `updateFromMbD()`, `updateFromInputState()`, `updateFromInitiallyAssembledState()` und `updateForFrame(index)` übertragen Zustände zwischen Eingabe, Solver und Ergebnisframe.
- `compareResults(type)` und `outputResults(type)` vergleichen oder schreiben Analyseergebnisse.

Die `read*`- und `storeOnLevel*`-Familien sind Parser-/Serializer-Hilfen. Dazu zählen etwa `readDouble`, `readBool`, `readColumnOfDoubles` sowie das Schreiben von Namen, Zahlen, Arrays und Tabs. Sie sind für neue Anwendungslogik normalerweise nicht erforderlich.

## 12.3 Position und Orientierung: `ASMTSpatialItem`

`ASMTSpatialItem` fügt Lage und Orientierung hinzu. Es wird von Assembly, Part, Marker und Referenzobjekten verwendet.

- `setPosition3D(x, y, z)` und `setPosition3D(vector)` setzen Translation.
- `getPosition3D(x, y, z)` liest die Lage in skalare Referenzen; `getPosition3D(frameIndex)` liefert den Zustand eines Ergebnisframes.
- `setRotationMatrix(9 Werte)` beziehungsweise die Matrix-Überladung setzen Orientierung.
- `getRotationMatrix(frameIndex)` fragt die Matrix eines Ergebnisframes ab.
- `setQuarternions(q0, q1, q2, q3)` setzt eine Quaternion. Der im Header vorhandene Schreibfehler `Quarternions` gehört tatsächlich zum Methodennamen.
- `getQuarternions(...)` liest sie aus.
- `restorePosRot()` stellt gespeicherte alte Position und Rotation wieder her.

Positionen und Maße müssen zu den Einheitenskalen des Modells passen. Rotationsmatrizen sind mathematisch als gültige orthonormale Matrizen zu verstehen; der Parser validiert nicht jede Eingabe robust.

## 12.4 `ASMTSpatialContainer` und `ASMTPart`

Ein räumlicher Container besitzt Marker und Referenzen:

- `addMarker(marker)`, `markerList()` und `generateUniqueMarkerName()` verwalten Marker.
- `addRefPoint(point)` ergänzt einen Referenzpunkt.
- `setPrincipalMassMarker(marker)` verknüpft das Masse-/Trägheitsbezugssystem.
- `setVelocity3D(...)` und `setOmega3D(...)` setzen lineare beziehungsweise Winkelgeschwindigkeit.
- `getVelocity3D(i)`, `getOmega3D(i)`, `getAcceleration3D(i)` und `getAlpha3D(i)` lesen Zeitreihenwerte für einen Frame.
- `rOcmO()` und `qEp()` liefern abgeleitete Orts-/Orientierungsdaten für die Solverabbildung.

`ASMTPart::With()` erzeugt einen Körper. `ASMTPart` ergänzt die Containerfunktion um Part-Zeitreihen, `isFixed`, Parser für `FeatureOrder`/`PrincipalMassMarker` und die MbD-Erzeugung. Die Masseparameter gehören zum `ASMTPrincipalMassMarker`; dessen Setter und Einheiten müssen passend gewählt werden. ASMT-Partgeometrie ist nicht automatisch eine FreeCAD-B-Rep.

## 12.5 Marker und Referenzobjekte

`ASMTMarker::With()` erzeugt einen Marker, der von `ASMTSpatialItem` erbt und damit eine lokale Position plus Orientierung besitzt. Marker liegen typischerweise im Koordinatensystem einer Assembly oder eines Parts. Gelenke verbinden die Marker über die geerbten `ASMTItemIJ`-Funktionen `setMarkerI(path)` und `setMarkerJ(path)`.

`ASMTRefPoint`, `ASMTRefCurve` und `ASMTRefSurface` bilden geometrische Referenzen; `ASMTRefItem::addMarker()` hängt Marker an ein Referenzobjekt. Wichtig für ASMT-Dateien: Im geprüften Parserstand werden Referenzpunkte eingelesen, aber die Elementparser für Referenzkurven und -flächen sind noch nicht implementiert. Ein C++-Typ im Header bedeutet also nicht, dass der Dateipfad fertig ist.

### Beispiel: räumliche Daten setzen

```cpp
auto part = MbD::ASMTPart::With();
part->setName("Rotor");
part->setPosition3D(0.0, 0.0, 0.25);
part->setRotationMatrix(
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0);
```

Das erzeugt nur ein Partobjekt mit Lage; es erzeugt noch keine vollständige Assembly. Für einen lösbaren Mechanismus müssen zusätzlich Massemarker, Joint-Marker, Constraints und korrekte Owner-Beziehungen angelegt werden. Zum Einstieg ist deshalb das Laden eines bekannten ASMT-Fixtures verlässlicher.

Der Part-Aufbau samt `addPart()` und Owner-Prüfung ist als `./run.sh part-api` im Ordner [`examples/08-ondselsolver-api`](./examples/08-ondselsolver-api/README.md) ausführbar.