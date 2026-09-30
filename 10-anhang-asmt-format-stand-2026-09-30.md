# Anhang A. ASMT-Format: dokumentierter Stand am 30.09.2026

## A.1 Kurzantwort: Wo ist das Format beschrieben?

Eine aktuelle, normative und versionsgebundene ASMT-Spezifikation konnte ich nicht finden. Die beste Beschreibung des derzeitigen Formats ergibt sich aus drei Ebenen:

1. **Historische Primärbeschreibung von Ondsel:** Im [Ondsel-Artikel zur frühen Assembly-Workbench](https://www.ondsel.com/blog/assembly-wb-prerelease/) steht im Abschnitt „ASMT files“, dass ASMT ein einfaches Plain-Text-Format zur Darstellung der Assembly-Struktur und damals vor allem ein internes Debugging-Werkzeug war. Der Artikel sagt ausdrücklich, dass die Funktion später entfernt oder reduziert werden könnte.
2. **Aktuelle Implementierung und Beispiele:** Maßgeblich für den Stand dieses Buches sind der Parser und Serializer im Submodul [ASMTAssembly.cpp](vendor/OndselSolver/OndselSolver/ASMTAssembly.cpp), die Basishilfen in [ASMTItem.cpp](vendor/OndselSolver/OndselSolver/ASMTItem.cpp) sowie die echten Dateien in [`examples/07-ondselsolver-real-asmt`](./examples/07-ondselsolver-real-asmt/README.md). Der historische Upstream-Stand ist zusätzlich im [archivierten OndselSolver-Repository](https://github.com/Ondsel-Development/OndselSolver/tree/09d6175a) einsehbar.
3. **FreeCAD-Integrationshinweis:** FreeCAD registriert `.asmt` als Importtyp. Der Kommentar in [Assembly/Init.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/Init.py) sagt aber ausdrücklich, dass das korrekte Interoperabilitätsformat noch Forschungsgegenstand und ASMT ein Platzhalter ist. Der aktuelle [AssemblyImport.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/AssemblyImport.py) erstellt noch keine Assembly aus der Datei.

Die [DeepWiki-Seite zum ASMT-Format](https://deepwiki.com/FreeCAD/OndselSolver/4.4-asmt-file-format) und die [DeepWiki-Übersicht zu Dateiformaten](https://deepwiki.com/Ondsel-Development/OndselSolver/4-file-formats-and-exchange) sind nützliche, quellenverlinkte Sekundärzusammenfassungen. Sie sind keine Herausgeber-Spezifikation; ihre Aussagen müssen gegen den jeweiligen Solver-Quellstand geprüft werden. Auch das [pyondsel-Projekt](https://github.com/deepsaia/pyondsel) beschreibt die Nutzung des nativen OndselSolver-ASMT, definiert aber keinen unabhängigen Standard.

**Fazit:** ASMT ist ein tatsächlich verwendetes, lesbares Solver-Datenformat, aber nach dem hier geprüften Stand kein abgeschlossener, herstellerneutraler Dateistandard mit veröffentlichter normativer Grammatik.

## A.2 Wozu die Datei dient

ASMT serialisiert eine Solver-Assembly: Körper, ihre Anfangslagen und Bezugssysteme, Marker, Gelenke, Bewegungen, Grenzen, Kräfte sowie Simulationsparameter. Solver-Ausgaben können zusätzlich Zeitreihen und berechnete Zustände enthalten.

Es ist nicht automatisch ein vollständiger CAD-Projektcontainer. Die Fixtures in Beispiel 07 enthalten Solver-Geometrie und Kinematikdaten, aber keine vollständigen FreeCAD-B-Reps. Außerdem registriert FreeCAD zwar den Dateityp, der derzeitige Import-Stub erzeugt daraus noch keine FreeCAD-Objekte.

## A.3 Aufbau im aktuellen Parser

### Dateikopf und Hierarchie

Der Parser akzeptiert zwei Kopfzeilen:

```text
OndselSolver
Assembly
```

oder den älteren Kopf:

```text
freeCAD: 3D CAD with Motion Simulation  by  askoh.com
Assembly
```

Darauf folgt ein hierarchischer Textbaum. Im aktuellen Parser markieren **Tabulatoren** die Verschachtelung. Schlüsselwörter und Werte stehen auf getrennten Zeilen; numerische Vektoren werden als mehrere durch Whitespace getrennte Zahlen gelesen. Leerzeichen anstelle von Tabs sind kein verlässlich unterstützter Ersatz: Der Parser vergleicht an vielen Stellen exakte, eingerückte Schlüsselzeilen.

Ein reales minimales Ausschnittmuster aus `__cubes.asmt`:

```text
OndselSolver
Assembly
	Notes
		(Text string: '' runs: (Core.RunArray runs: #() values: #()))
	Name
		OndselAssembly
	Position3D
		0 0 0
	RotationMatrix
		1 0 0
		0 1 0
		0 0 1
```

Das ist ein gekürzter Leseausschnitt, keine vollständige gültige Datei. Eine vollständige, vom lokalen Solver getestete Eingabe liegt unter [`__cubes.asmt`](./examples/07-ondselsolver-real-asmt/__cubes.asmt).

### Root-Assembly

`ASMTAssembly::parseASMT()` liest die Root-Daten in fester Reihenfolge ein:

| Abschnitt | Bedeutung |
|---|---|
| `Notes`, `Name` | Freitextnotiz und Assembly-Name |
| `Position3D`, `RotationMatrix` | Lage des Assembly-Bezugssystems |
| `Velocity3D`, `Omega3D` | lineare und Winkelgeschwindigkeit |
| `RefPoints`, `RefCurves`, `RefSurfaces` | geometrische Referenzobjekte und Markercontainer |
| `Parts` | enthaltene Körper und deren Eigenschaften |
| `KinematicIJs` | kinematische Datenobjekte |
| `ConstraintSets` | `Joints`, `Motions`, `Limits`, `GeneralConstraintSets` |
| `ForceTorques`, `ConstantGravity` | Belastung und Schwerkraft |
| `SimulationParameters`, `AnimationParameters` | Solve-/Integrations- und Animationssteuerung |
| `TimeSeries` und nachfolgende Serien | optionale berechnete Zeitverläufe |

Die Reihenfolge ist eine Implementierungserwartung, keine frei sortierbare Schlüssel-Wert-Sammlung. Das sieht man unmittelbar an der fest sequenzierten Aufrufkette in `ASMTAssembly::parseASMT()`.

### Körper, Marker und Gelenke

Ein `Part` enthält unter anderem Name, Lage, Rotation, Geschwindigkeiten, `FeatureOrder`, `PrincipalMassMarker` und Referenzpunkte/-kurven/-flächen. Ein `Marker` speichert Name, lokale Position und Orientierung; Gelenke verbinden zwei Marker über Referenzpfade, zum Beispiel `MarkerI` und `MarkerJ`.

Der Parser der räumlichen Daten erwartet für `Position3D` in der Praxis drei Zahlen. `RotationMatrix` wird als drei Zeilen eingelesen, typischerweise mit je drei Zahlen. Die aktuelle Implementierung prüft die Dimensionen jedoch nicht überall robust; beschädigte oder falsch eingerückte Dateien können deshalb Assertions, Exceptions oder im ungünstigen Fall Speicherfehler auslösen.

Der Joint-Parser kennt im aktuellen Quellstand unter anderem `FixedJoint`, `RevoluteJoint`, `SphericalJoint`, `CylindricalJoint`, `TranslationalJoint`, `UniversalJoint`, `PlanarJoint`, `AngleJoint`, `GearJoint`, `ScrewJoint` und mehrere zusammengesetzte Gelenke. Bewegungen umfassen `RotationalMotion`, `TranslationalMotion`, `GeneralMotion` und `AllowRotation`; Grenzen umfassen `RotationLimit` und `TranslationLimit`. Welche Parameter je Typ nötig sind, ergibt sich aus der jeweiligen `ASMT*`-Klasse und ihren Fixtures.

### Einheiten und Zahlen

Die Werte werden als numerische Textwerte eingelesen. In den üblichen Abschnitten steht kein explizites Einheiten-Token neben jeder Zahl. OndselSolver besitzt eine separate `Units`-Struktur für Zeit, Masse, Länge, Winkel und abgeleitete Größen; deren Standardfaktoren sind 1.0. Bei selbst erzeugten oder extern konvertierten Dateien muss daher die verwendete Einheitenskala bekannt und konsistent sein.

### Ausgabe und Solver-Ergebnis

`ASMTAssembly::outputFile()` schreibt im aktuellen Quellstand stets den Kopf `OndselSolver` und serialisiert danach den Objektbaum. Die Serialisierung verwendet Tabs für Ebenen und schreibt Fließkommazahlen mit hoher Genauigkeit (`max_digits10`). Nach einer Simulation können Zeitreihenabschnitte hinzukommen.

## A.4 Parsergrenzen: nicht mit „Format unterstützt“ verwechseln

Die Existenz eines Abschnittsnamens in einer Datei bedeutet nicht, dass jede Variante unterstützt wird. Im untersuchten Quellstand gilt unter anderem:

- Nichtleere `KinematicIJs` enden in `readKinematicIJ()` mit „To be implemented“.
- `RefCurves` und `RefSurfaces` werden als Container erkannt, ihre Einzelelement-Parser werfen aber ebenfalls „To be implemented“.
- Nichtleere `GeneralConstraintSets` sind noch nicht implementiert.
- `ASMTItem::parseASMT()` ist für nicht speziell behandelte Objekttypen ein Fehlerpfad.
- Viele Parserpfade verlassen sich auf Assertions und exakte Zeilenfolge statt auf eine fehlertolerante Validierung.

Damit beschreibt dieser Appendix den gegenwärtigen Parser/Serializer-Umfang, nicht eine Garantie, dass alle denkbaren ASMT-Dateien oder alle historischen Varianten unterstützt werden.

## A.5 Reproduzierbare Referenzdateien

Beispiel 07 enthält drei lokale Eingabedateien, die mit dem echten OndselSolver getestet werden:

- [`__cubes.asmt`](./examples/07-ondselsolver-real-asmt/__cubes.asmt): zwei Körper, Fixed- und Angle-Joint
- [`fourbar.asmt`](./examples/07-ondselsolver-real-asmt/fourbar.asmt): Viergelenk
- [`piston.asmt`](./examples/07-ondselsolver-real-asmt/piston.asmt): Kurbel-Schieber

Diese Dateien sind besonders nützlich als praktische Formatbeispiele, aber nicht als vollständige Schema-Spezifikation. Der Parser selbst und seine Testfixtures bleiben der genaueste Nachweis dafür, was der lokale Solverstand akzeptiert.

## A.6 Wie FreeCAD die ASMT-Struktur erzeugt

Der FreeCAD-Export ist keine generische Dokument-Serialisierung. Der Aufruf aus [`CommandExportASMT.py`](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/CommandExportASMT.py) endet in `AssemblyObject::exportAsASMT()`. Der relevante Ablauf in [`AssemblyObject.cpp`](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/AssemblyObject.cpp) lautet:

1. `makeMbdAssembly()` erzeugt ein `ASMTAssembly`, setzt dessen Solver-Rootnamen auf `OndselAssembly` und verknüpft es mit dem FreeCAD-Assembly-Objekt.
2. `rebuildRigidClusters()` und `fixGroundedParts()` bereiten die Solver-Körper vor. Für Grounding erzeugt FreeCAD einen Marker auf der Assembly an der Zielplatzierung, einen lokalen `FixingMarker` am Part und ein `ASMTFixedJoint` zwischen beiden.
3. `getJoints()` sammelt die Baugruppen-Joints. `jointParts()` ruft für jeden Joint `makeMbdJoint()` auf und fügt das erzeugte Solver-Objekt in die Assembly ein.
4. `getMbDData()` ordnet FreeCAD-Objekte den `ASMTPart`-Objekten zu. Bei Links und verschachtelten Baugruppen werden Identität und Container-Placements aufgelöst; mehrere FreeCAD-Objekte können über `objectPartMap` auf denselben Solver-Körper zeigen.
5. `handleOneSideOfJoint()` nimmt die Referenz und Placement jeder Joint-Seite, berechnet daraus einen part-lokalen Marker und gibt dessen ASMT-Pfad zurück. Der Joint verweist anschließend auf `MarkerI` und `MarkerJ`.
6. `makeMbdJointOfType()` übersetzt FreeCAD-Jointtypen in konkrete ASMT-Klassen, zum Beispiel `Fixed` → `ASMTFixedJoint`, `Revolute` → `ASMTRevoluteJoint`, `Cylindrical` → `ASMTCylindricalJoint`, `Slider` → `ASMTTranslationalJoint` und `Ball` → `ASMTSphericalJoint`. Typabhängige Parameter wie Winkel, Gear-Radien oder Schraubensteigung werden dabei ebenfalls übertragen.
7. `outputFile()` serialisiert die fertige Datenstruktur als Textdatei.

Als Ablaufdiagramm:

```text
FreeCAD AssemblyObject
	-> ASMTAssembly("OndselAssembly")
	-> ASMTPart + MassMarker + Placement/Rotation
	-> Ground-Marker + FixingMarker + FixedJoint
	-> Joint-Marker aus Reference1/Reference2 und Placement1/Placement2
	-> ASMT-Jointklasse samt Parametern
	-> outputFile(.asmt)
```

Die Zuordnung zwischen FreeCAD-Code und Datei lässt sich so lesen:

| FreeCAD-Methode | ASMT-Objekt/Block | Konkrete Wirkung |
|---|---|---|
| `makeMbdAssembly()` | `Assembly` | legt die Solver-Rootassembly `OndselAssembly` an |
| `fixGroundedPart()` | Root-Marker, Part-Marker, `FixedJoint` | verankert ein Teil über einen Assembly-Marker und den lokalen `FixingMarker` |
| `getMbdData()` / `makeMbdPart()` | `Part`, `Position3D`, `RotationMatrix`, `PrincipalMassMarker` | mappt ein FreeCAD-Part/Link auf einen Solver-Körper; Placement wird in Translation und Rotationsmatrix zerlegt |
| `handleOneSideOfJoint()` / `makeMbdMarker()` | `RefPoint` / `Marker` | berechnet die joint-lokale Markerposition und hängt sie an den zugehörigen Solver-Körper |
| `makeMbdJoint()` / `makeMbdJointOfType()` | `ConstraintSets/Joints/<JointType>` | wählt die Solver-Jointklasse, setzt Parameter und referenziert beide Markerpfade |
| `outputFile()` / `storeOnLevel()` | Textdatei | schreibt den Solver-Objektbaum mit Tab-Einrückung aus |

### Reales Joint-Beispiel aus FreeCAD/OndselSolver

Dieser unveränderte Ausschnitt stammt aus [`__cubes.asmt`](./examples/07-ondselsolver-real-asmt/__cubes.asmt). Er zeigt sowohl die erzeugte Erdung als auch ein Winkelgelenk. Die Pfade unter `MarkerI` und `MarkerJ` verweisen auf die zuvor serialisierten Marker:

```text
	ConstraintSets
		Joints
			FixedJoint
				Name
					__cubes#GroundedJoint
				MarkerI
					/OndselAssembly/marker-__cubes#Box001
				MarkerJ
					/OndselAssembly/__cubes#Box001/FixingMarker
			AngleJoint
				Name
					__cubes#Angle
				MarkerI
					/OndselAssembly/__cubes#Box001/__cubes#Angle
				MarkerJ
					/OndselAssembly/__cubes#Box002/__cubes#Angle
				theIzJz
					0.17453292519943295
```

`theIzJz` ist hier der Winkelparameter in Radiant. Der Wert `0.17453292519943295` entspricht 10 Grad. Entscheidend ist die Datenkette: FreeCAD-Joint → ASMT-Jointklasse → zwei serialisierte Markerpfade plus Gelenkparameter.

### Was wird dabei nicht exportiert?

Der Pfad `makeMbdPart()` schreibt Position und 3x3-Rotationsmatrix, erzeugt einen PrincipalMassMarker und setzt im normalen Aufruf Standardwerte für Masse (`1.0`), Dichte (`1.0`) und Trägheitsmomente (`1.0, 1.0, 1.0`). Er serialisiert damit nicht automatisch CAD-B-Reps oder aus der Form berechnete reale Masseneigenschaften. ASMT ist an dieser Stelle ein Solver-Modell, nicht ein Ersatz für die vollständige FreeCAD-Datei.

`exportAsASMT()` baut und schreibt die ASMT-Struktur; der Exportpfad ruft selbst nicht `solve()` auf. Lösen und ASMT-Export sind getrennte Operationen. Ebenso registriert FreeCAD `.asmt` zwar als Dateityp, aber der aktuelle [AssemblyImport.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/AssemblyImport.py)-Stub importiert noch keine Solver-Struktur in ein FreeCAD-Dokument.

## A.7 Quellen und Stand

- Ondsel, [„Christmas comes early! A pre-release of the integrated assembly workbench“](https://www.ondsel.com/blog/assembly-wb-prerelease/), 01.12.2025, Abschnitt „ASMT files“: historische Primärbeschreibung als internes, einfaches Plain-Text-/Debugformat.
- [OndselSolver, ASMTAssembly.cpp](https://github.com/Ondsel-Development/OndselSolver/blob/09d6175a/OndselSolver/ASMTAssembly.cpp) und [ASMTItem.cpp](https://github.com/Ondsel-Development/OndselSolver/blob/09d6175a/OndselSolver/ASMTItem.cpp): Parser- und Serializer-Implementierung im archivierten Upstream-Stand.
- FreeCAD, [Assembly/Init.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/Init.py): Kommentar, dass ein geeignetes Interoperabilitätsformat noch Forschungsgegenstand ist und ASMT als Platzhalter behandelt wird.
- DeepWiki, [ASMT File Format](https://deepwiki.com/FreeCAD/OndselSolver/4.4-asmt-file-format) und [File Formats and Exchange](https://deepwiki.com/Ondsel-Development/OndselSolver/4-file-formats-and-exchange): Sekundärzusammenfassungen mit Quellverweisen; keine normative Spezifikation.
- Solver-Quellstand am **30.09.2026**: [ASMTAssembly.cpp](vendor/OndselSolver/OndselSolver/ASMTAssembly.cpp), [ASMTPart.cpp](vendor/OndselSolver/OndselSolver/ASMTPart.cpp), [ASMTSpatialItem.cpp](vendor/OndselSolver/OndselSolver/ASMTSpatialItem.cpp), [ASMTAssembly.h](vendor/OndselSolver/OndselSolver/ASMTAssembly.h) und [Units.h](vendor/OndselSolver/OndselSolver/Units.h) im auf Commit `4be80eef` fixierten Submodul.
- FreeCAD-Referenzquellen: [AssemblyObject.cpp](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/AssemblyObject.cpp), [CommandExportASMT.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/CommandExportASMT.py) und [AssemblyImport.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/AssemblyImport.py).