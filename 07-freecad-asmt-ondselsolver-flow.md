# 07. Praxisfluss: FreeCAD → ASMT/Assembly → OndselSolver → Rückgabe in FreeCAD

## 1. Warum dieses Kapitel notwendig ist

Das bisherige Buch erklärt isolierte Konzepte. Das hier ist der praktische „End-to-End-Fluss“: Wie die echte Architektur ein Baugruppenmodell in eine solverfähige Darstellung überführt und danach die Lösung wieder zurück in die CAD-Welt schreibt.

Das ist der Kern, den ein Lernender wirklich verstehen muss.

## 2. Der komplette Ablauf

Ein realer Flow in einem FreeCAD-Assembly-System läuft im Grundsatz so:

1. Der Nutzer modelliert Teile und Beziehungen in FreeCAD.
2. Die Assembly-Logik erkennt die relevanten Objekte und ihre Verbindungen.
3. Die Baugruppe wird in eine solverorientierte Repräsentation übersetzt.
4. Die Übersetzung kann als ASMT- oder Assembly-ähnliches Modell erfolgen.
5. OndselSolver löst die Beziehungssysteme.
6. Die berechneten Platzierungen werden in die FreeCAD-Objekte zurückgeschrieben.
7. Die Darstellung im 3D-Fenster wird aktualisiert.

Das ist der reale Kreislauf zwischen CAD und Solver.

## 3. Beispiel aus der Projektstruktur

In FreeCADs Assembly-Implementierung ist die Verbindung konkret im Code sichtbar:

- [CommandExportASMT.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/CommandExportASMT.py) exportiert eine Baugruppe als `.asmt`
- [Assembly/App/CMakeLists.txt](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/CMakeLists.txt) bindet `OndselSolver` in die Assembly-Library ein
- [AssemblyObject.cpp](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/App/AssemblyObject.cpp) verarbeitet die Solve- und Placement-Logik

Das zeigt bereits den vollständigen gedachten Ablauf:

- FreeCAD erzeugt das Modell
- Assembly kapselt und übersetzt es
- OndselSolver berechnet die Lösung
- FreeCAD zeigt das Ergebnis an

## 4. Ein konkretes, vereinfachtes Beispiel

Das folgende Beispiel zeigt den Ablauf ohne die komplette FreeCAD-API und ohne die reale Solver-Bibliothek zu kopieren. Es ist eine didaktische Darstellung.

```python
import FreeCAD as App

# 1) FreeCAD-Modell erzeugen
# Ein Dokument wird als Assembly-Kontext gestartet.
doc = App.newDocument("TandemDemo")

base = doc.addObject("Part::Box", "Base")
base.Length = 40
base.Width = 20
base.Height = 10

arm = doc.addObject("Part::Box", "Arm")
arm.Length = 30
arm.Width = 10
arm.Height = 10
arm.Placement.Base = (20, 0, 0)

# 2) In der echten Architektur würde hier ein Joint oder eine Constraint-Definition
#    entstehen, z. B. eine Achsen- oder Abstandsbeschränkung.
#    Der Assembly-Code sammelt diese Daten und gibt sie an den Solver weiter.

assembly_data = {
    "parts": ["Base", "Arm"],
    "constraints": [
        {"type": "distance", "part_a": "Base", "part_b": "Arm", "target": 25.0}
    ]
}

print("Assembly-Daten erstellt:")
print(assembly_data)

# 3) Solver-ähnliche Darstellung
solver_input = {
    "bodies": [
        {"id": "Base", "position": [0, 0, 0]},
        {"id": "Arm", "position": [20, 0, 0]},
    ],
    "constraints": [{"kind": "distance", "target": 25.0}]
}

print("Solver-Input vorbereitet:")
print(solver_input)

# 4) Ergebnisnachbereitung im FreeCAD-Kontext
# In der echten Pipeline würde der Solver neue Positionen berechnen und
# diese Werte in die Plazierungen zurückschreiben.
arm.Placement.Base = (25, 0, 0)

print("Arm-Platzierung nach Solve:", arm.Placement.Base)
```

Wichtig ist hier die Reihenfolge:

- FreeCAD modelliert die Geometrie
- Assembly definiert die Beziehungen
- Solver verarbeitet die Beziehung
- Ergebnis wird wieder in das CAD-Modell geschrieben

## 5. Der dreiteilige Blick auf den Ablauf

### 5.1 CAD-Seite

Die CAD-Seite kennt die Geometrie, die Objekte und die Sichtbarkeit. Sie ist die Benutzerschnittstelle und das Modell des Baugruppenkontexts.

### 5.2 Assembly-/ASMT-Seite

Diese Ebene formt die CAD-Daten in eine klare, solverorientierte Struktur um. Dabei ist ASMT das sichtbarste Format, aber der eigentliche Gedanke ist die gleiche Haltung: eine definierte, berechenbare Repräsentation der Baugruppe.

### 5.3 Solver-Seite

Das Mehrkörpersystem löst die Beziehungen, korrigiert die Positionen und liefert eine konsistente Konfiguration zurück.

## 6. Warum die Rückgabe in FreeCAD so wichtig ist

Wenn die Lösung berechnet ist, muss sie wieder in die CAD-Darstellung zurückfließen. Nur dann ist sie für den Benutzer sichtbar und nutzbar. Genau das passiert in der echten Architektur durch die Update- und Placement-Mechanik der Assembly-Objekte.

Ohne diese Rückübertragung wäre die Lösung nur eine numerische Nebenwirkung, kein nutzbares CAD-Ergebnis.

## 7. Praktische Lernfrage

Ein Leser sollte bei jeder Lösung sich immer fragen:

- Wo beginnt das Modell?
- Welche Daten werden zum Solver geschickt?
- Wie funktioniert die Übersetzung in die Assembly-/ASMT-Struktur?
- Was ist der Fehlerwert und wie wird er gelöst?
- Wie werden die berechneten Werte wieder in FreeCAD gesetzt?

Diese Fragen machen den gesamten Ablauf verständlich.

## 8. Fazit

Der echte Flow ist kein linearer Einzeiler, sondern ein geschlossener Kreis:

FreeCAD → Assembly/ASMT → OndselSolver → Ergebnis zurück in FreeCAD

Das ist die wichtigste praktische Sichtweise auf OndselSolver in einer CAD-Umgebung. Wenn man diesen Kreislauf verstanden hat, dann ist das gesamte Buch in seiner Grundlogik verankert.
