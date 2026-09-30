# 05. FreeCAD-Beispiele mit Bibliotheken und Solver-Integration

## 1. Warum dieses Kapitel wichtig ist

Ein Leser versteht OndselSolver erst wirklich, wenn er sieht, wie die Bibliotheken in der echten FreeCAD-Welt zusammenspielen. In der Praxis ist das nicht „ein Solver, der isoliert läuft“, sondern ein Zusammenspiel aus mehreren Bibliotheken und Modulen.

In FreeCADs Assembly-Implementierung ist das sichtbar:

- [Assembly/App/CMakeLists.txt](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/CMakeLists.txt) verbindet das Assembly-Modul mit `Part`, `PartDesign`, `Spreadsheet`, `FreeCADApp` und `OndselSolver`
- [CommandExportASMT.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/CommandExportASMT.py) exportiert eine Baugruppe als `.asmt`
- [AssemblyObject.cpp](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/AssemblyObject.cpp) und [AssemblyObject.h](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/AssemblyObject.h) kapseln die Baugruppenlogik und den Solver-Zugang

Das zeigt: Es gibt eine klare Trennung zwischen

- CAD-Bibliotheken und Objekten,
- Assembly-Logik,
- Solver-Integration,
- GUI/Interaktion.

## 2. Die wichtigsten Bibliotheken im FreeCAD-Assembly-Kontext

### 2.1 FreeCADApp

`FreeCADApp` ist die Kernbibliothek zur Verwaltung von Dokumenten, Objekten, Eigenschaften und Parametern.

Sie beschreibt die Grundlage, auf der ein Part, ein Link, eine Baugruppe oder ein Joint entsteht.

### 2.2 Part / PartDesign

Diese Bibliotheken liefern die geometrischen und parametrischen Funktionen. Sie sind wichtig, wenn geometrische Formen, Plazierungen und profilebasiertes Arbeiten in die Solver-Logik eingebunden werden.

### 2.3 Assembly-Modul

Das Assembly-Modul ist die konkrete Brücke zwischen:

- geometrischem CAD-Modell,
- Joints/Constraints,
- Solver-Objekten,
- berechneten Resultaten.

Im realen Code ist das in [Assembly/App/CMakeLists.txt](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/CMakeLists.txt) gut sichtbar:

```cmake
set(Assembly_LIBS
    Part
    PartDesign
    Spreadsheet
    FreeCADApp
    OndselSolver
)
```

Das ist ein sehr wichtiges Beispiel für die Integrationslogik: Das Assembly-Modul verwendet FreeCAD-Bibliotheken und zusätzlich die Solver-Bibliothek.

## 3. Typischer Datenfluss in einem FreeCAD-Setup

Ein realer Ablauf sieht in der Praxis typischerweise so aus:

1. FreeCAD erzeugt ein Dokument und Objekte.
2. Assembly-Objekte sammeln die Teile und Joints.
3. Das Assembly-Modul ordnet sie für den Solver an.
4. OndselSolver löst die Beziehungssysteme.
5. Die Ergebnisse werden in die FreeCAD-Platzierungen zurück geschrieben.

Das heißt: Der Solver ist kein selbstständiges CAD-System, sondern ein Teil einer größeren Architektur.

## 4. Ein kleines Python-Beispiel mit FreeCAD und Solver-Logik

Das folgende Beispiel ist bewusst einfach und zeigt das Grundmuster, ohne die komplette FreeCAD-API zu reproduzieren.

```python
import FreeCAD as App

# Ein einfaches Dokument als Basis für eine Baugruppe
# In der echten FreeCAD-Architektur würden hier Beispiele mit AssemblyObject,
# Joint-Definitionen und Solver-Aufrufen folgen.
doc = App.newDocument("DemoAssembly")

base = doc.addObject("Part::Box", "Base")
arm = doc.addObject("Part::Box", "Arm")

# Repräsentation der geometrischen Daten
base.Placement.Base = (0, 0, 0)
arm.Placement.Base = (20, 0, 0)

# Logik: Die Position eines Teils ist das, was der Solver in
# einer konsistenten Baugruppe schließlich berechnet.
print("Base: ", base.Placement.Base)
print("Arm: ", arm.Placement.Base)
```

Was wichtig ist: Das Beispiel zeigt den Stil der Verbindung zwischen CAD-Objekten und einer für den Solver relevanten Geometrie- oder Platzierungsdatenstruktur.

## 5. Ein reales Muster aus dem Projekt

In der echten Implementation werden Assembly-Objekte und Solver-Objekte strukturell verbunden. Das ist in der C++-Integration sichtbar:

```cmake
add_library(Assembly SHARED ${Assembly_SRCS})
target_link_libraries(Assembly ${Assembly_LIBS})
```

Diese eine Zeile ist ein Schlüsselbegriff für den gesamten Abschnitt:

- `Assembly` ist ein FreeCAD-Modul
- `OndselSolver` ist die Solver-Bibliothek
- beide werden zu einer gemeinsamen Laufzeit-/Link-Umgebung kombiniert

## 6. Kopflose Ausführung (Headless) von FreeCAD

Für Automatisierung oder Server-/CI-Umgebungen ist ein entscheidender Fall die sogenannte headless Ausführung: FreeCAD wird ohne GUI gestartet. Das ist besonders hilfreich, wenn eine Baugruppe aus einer Python-Datei berechnet oder im Hintergrund aufgelöst werden soll.

Typischer Ablauf:

1. `freecadcmd` oder `FreeCADCmd` wird gestartet
2. eine Python-Datei wird geladen
3. die Baugruppe wird erzeugt oder geöffnet
4. die Solver-Logik wird ausgeführt
5. das Ergebnis wird in die Konsole oder in Dateien geschrieben

Ein typisches Muster sieht so aus:

```bash
freecadcmd -c "import FreeCAD; doc = FreeCAD.newDocument('HeadlessDemo'); print(doc.Name)"
```

Das ist der entscheidende Unterschied zu einer GUI-Version: Es gibt kein sichtbares Fenster, aber dieselbe CAD-/Solver-Logik kann verwendet werden.

## 7. Ein konkretes Beispiel für headless Nutzung

Im Buch liegt ein Beispiel unter:

- `examples/05-freecad-headless/`

Das Beispiel zeigt genau diesen Kopf-Los-Start und setzt ein Python-Skript mit der FreeCAD-API in Bewegung. Das ist die bevorzugte Ausführungsform für Automatisierung, Testläufe und Build-/CI-Szenarien.

## 8. Warum das für OndselSolver relevant ist

Die Solver-Integration wirkt nur dann wirklich sinnvoll, wenn das CAD-System die Daten sauber liefert und die Solver-Ergebnisse sauber in die CAD-Welt zurückschreibt. Genau diese Abbildung ist die eigentliche Ingenieursarbeit hinter FreeCAD + OndselSolver.

Die wichtigsten Fragen lauten deshalb:

- Welche Objekte werden aus der CAD-Welt an den Solver gegeben?
- Welche Joints oder Constraints wurden modelliert?
- Wie werden die Berechnungsergebnisse in die Ausgabe zurück übertragen?
- Wie funktioniert das in einer headless Umgebung ohne GUI?

Diese Fragen sind der Kern des Verständnisses.

## 9. Fazit

FreeCAD ist in der Praxis kein „einfaches“ 3D-Programm, sondern eine ingenieurtechnische Plattform mit mehreren Bibliotheken und klarer Modulstruktur. Die Kombination aus FreeCADApp, Part, PartDesign, Assembly und OndselSolver ist der eigentliche Kern der Mechanik-/Assembliestruktur.

Daraus ergibt sich eine einfache Wahrheit:

Der Solver wird nicht einfach „dazugeschaltet“, sondern als Teil einer vollständigen CAD-/Modellierungs-Architektur eingebettet.
