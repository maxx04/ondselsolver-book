# 04. Wie kommuniziert OndselSolver mit FreeCAD?

## 1. Das Grundmodell

Die Verbindung zwischen FreeCAD und OndselSolver ist kein „magischer Direktzugriff“, sondern ein klarer Datenfluss:

1. FreeCAD modelliert Objekte, Plazierungen und Beziehungen.
2. Die Assembly-Architektur sammelt diese Informationen.
3. Die Daten werden in eine Solver-geeignete Struktur übersetzt.
4. OndselSolver berechnet die Lösung.
5. FreeCAD übernimmt die berechneten Platzierungen erneut in die 3D-Objekte.

Das ist die zentrale Kommunikationsschicht.

## 2. Ein wichtiger Gedanke: Darstellung und Solver sind getrennt

Eine FreeCAD-Baugruppe hat eine sichtbare 3D-Darstellung und eine Mechanik-/Solver-Logik. Diese beiden Ebenen sind nicht identisch.

- Die GUI zeigt, was der Nutzer sieht.
- Die Baugruppenstruktur hält die Beziehungen fest.
- Der Solver arbeitet mit den modellierten Bedingungen.
- Die Resultate werden in die Objekte zurückgeschrieben.

Diese Trennung ist wichtig. Der Datenfluss ist nicht „ein Objekt ändert sich direkt im Solver und alles ist automatisch perfekt“, sondern „FreeCAD organisiert die Daten, der Solver verarbeitet sie, dann schreibt FreeCAD die Ergebnisse zurück“.

## 3. Ein typischer Ablauf in der FreeCAD-Assembly-Architektur

Ein realistischer Ablauf sieht so aus:

- Ein Objekt wird als Teil in einer Baugruppe erkannt.
- Ein Joint oder Constraint wird als Beziehung hinzugefügt.
- Die Baugruppenlogik sammelt alle relevanten Objekte und Beziehungen.
- Ein `AssemblyObject` oder ein vergleichbares Objekt dient als Fassade für den Solver.
- Der Solver erzeugt intern ein Modell aus Teilen, Körpern und Beziehungen.
- Nach der Berechnung werden die neuen Platzierungen in die FreeCAD-Objekte übernommen.

## 4. Warum die Kommunikationsschicht crucial ist

Die größte Schwierigkeit ist oft nicht der mathematische Kern, sondern die Übersetzung zwischen zwei Welten:

- FreeCAD spricht in Objekten, Referenzen, Links, Plazierungen und Joints.
- OndselSolver spricht in Körpern, Variablen, Constraints und iterativen Lösungsschritten.

Damit liegt die eigentliche Herausforderung darin, genau diese Daten korrekt zu übersetzen.

## 5. Die Rolle von Referenzen

In FreeCAD sind Beziehungen häufig als Referenzen gespeichert. Ein Joint zeigt zum Beispiel auf zwei Objekte oder Subkomponenten und definiert ihre relative Lage.

Der Solver braucht daraus eine kompakte, berechenbare Darstellung. Das heißt:

- Objekt identifizieren
- Beziehung bestimmen
- Parameter auslesen
- numerischen Zustand aufbauen

Das ist der Kern einer Projektion von CAD-Daten in Solver-Daten.

## 6. Das Problem der Identität

Ein zentrales Thema in der FreeCAD-Assembly-Architektur ist Identität:

- Das sichtbare Objekt kann eine Spiegelung oder ein Link sein.
- Das echte Objekt kann an einer anderen Stelle im Dokument liegen.
- Der Solver will eine eindeutige, konsistente Teil-Identität.

Das erklärt, warum in komplexen Baugruppen sehr viel an Auflösung und Abbildung geschieht. Die Kommunikationsschicht muss sicherstellen, dass identische physische Teile nicht verwechselt werden.

## 7. Warum `AssemblyObject` und `AssemblyLink` wichtig sind

Im FreeCAD-Assembly-Code sind diese Strukturen der zentrale Übersetzungsmechanismus:

- `AssemblyObject` ist die eigentliche Baugruppe und die Solver-Fassade
- `AssemblyLink` stellt eingebettete oder verlinkte Strukturen in der Baugruppe dar

Diese Objekte helfen dabei, die freie CAD-Welt und die Solver-Welt sauber zu trennen und wieder zusammenzubinden.

## 8. Was bei der Rückgabe an FreeCAD passiert

Nach der Berechnung ist ein wichtiger Schritt die Rückgabe der Lösung in die CAD-Welt:

- neue Plazierungen werden gesetzt
- relative Beziehungen werden aktualisiert
- visuelle Darstellung wird neu gezeichnet
- Statusinformationen werden ergänzt

Ohne diese Rückgabe wäre die Lösung zwar numerisch korrekt, aber für den Benutzer nicht sichtbar.

## 9. Beispiel: Datenfluss in verständlicher Form

```python
# 1) FreeCAD-Klasse modelliert Benutzer-Input
assembly = {
    "parts": ["base", "arm"],
    "joints": [{"type": "revolute", "a": "base", "b": "arm"}],
}

# 2) Übersetzung in Solver-Daten
solver_model = {
    "bodies": [
        {"id": "base", "position": [0, 0, 0]},
        {"id": "arm", "position": [2, 0, 0]},
    ],
    "constraints": [{"kind": "revolute", "body_a": "base", "body_b": "arm"}],
}

# 3) Ergebnis aus dem Solver
result = {
    "arm": {"position": [2, 0, 0], "rotation": [0, 0, 0.5]},
}

# 4) FreeCAD übernimmt die Platzierung
# -> Darstellung wird erneuert
```

Das ist ein didaktisches Beispiel. In der echten Architektur erfolgt die Übersetzung deutlich komplexer, aber das Muster bleibt dasselbe.

## 10. Wichtige Lernfrage für den Leser

Wenn ein Solver in FreeCAD nicht funktioniert, dann lohnt es sich immer, diese Fragen zu beantworten:

- Welche Objekte wurden genau an den Solver übergeben?
- Welche Beziehungen wurden modelliert?
- Gab es eine fehlerhafte Referenz?
- Wurden die Resultate richtig zurück in die Platzierungen übernommen?

Das sind die Fragen, die die Kommunikationsschicht zwischen FreeCAD und OndselSolver verständlich machen.

## 11. Fazit

OndselSolver und FreeCAD kommunizieren nicht über „eine gemeinsame Realität“, sondern über eine gut definierte Daten- und Übersetzungslogik.

Die harte Arbeit liegt nicht nur im Rechnen, sondern in der sauberen Verknüpfung von:

- 3D-Modellierung
- semantischer Baugruppenlogik
- geometrischen Beziehungen
- Solver-Parametern
- resultierenden Placements

Das ist der Kern, den ein Lernender verstehen muss, wenn er FreeCAD und OndselSolver wirklich durchdringen will.
