# 02. Wie funktioniert OndselSolver?

## 1. Grundprinzip

OndselSolver arbeitet mit einem klassischen Muster: Er nimmt ein Mechanikmodell, übersetzt es in Gleichungen und löst dann eine oder mehrere konsistente Konfigurationen. Das geschieht üblicherweise nicht in einem Schritt „per Hand“, sondern iterativ.

Die wichtigsten Schritte sind:

1. Modellierung der Teile und Beziehungen
2. Erzeugung der Gleichungssysteme aus den Constraints
3. Berechnung eines Näherungswertes
4. Iterative Verfeinerung bis zur Lösung
5. Rückgabe der berechneten Platzierungen

## 2. Teile, Gelenke und Constraints

Ein Mehrkörpersystem besteht aus mehreren Teilen. Sie bewegen sich relativ zueinander, aber nicht frei. Ihre Bewegung wird durch Verbindungen eingeschränkt.

Beispiele:

- Festes Gelenk
- Drehgelenk
- Schiebegelenk
- Planare Beziehung
- Punkt-auf-Linie
- Winkel- oder Abstandsbeschränkung

Diese Beziehungen erzeugen sogenannte Constraints. Ein Constraint ist eine mathematische Bedingung, mit der die mögliche Bewegung der Teile eingeschränkt wird.

## 3. Freiheitsgrade

Ein Teil im Raum hat normalerweise sechs Freiheitsgrade:

- drei Translationen
- drei Rotationen

Ein Joint oder Constraint nimmt davon einige weg. Ein festes Gelenk entfernt praktisch alle Freiheitsgrade, ein Drehgelenk nur eine Rotation, ein Schiebegelenk nur eine Translation. So entsteht ein System, das bei der korrekten Kombination stabil und lösbar wird.

## 4. Warum Iteration nötig ist

Die meisten realen mechanischen Beziehungen sind nicht linear. Das bedeutet:

- Die Positionsänderung eines Teils beeinflusst andere Bedingungen gleichzeitig.
- Die Lösung kann nicht immer geschlossen per Formel bestimmt werden.
- Man muss mit einem Näherungsprozess starten und sich schrittweise verbessern.

Das ist der Kern der numerischen Lösung: Start mit einer geschätzten Konfiguration, berechne Fehler, korrigiere Positionen, wiederhole bis der Fehler klein genug ist.

## 5. Newton-Verfahren als einfaches Denkmodell

Ein sehr verbreiteter Gedanke in Solvern ist das Newton-Verfahren oder ähnliche iterative Verfahren:

- Definiere eine Fehlermenge
- Berechne die Ableitung des Fehlers
- Korrigiere die Variablen in Richtung kleinerer Fehler
- Wiederhole, bis der Fehler unter einem Toleranzwert liegt

In einfachen Worten:

- Der Solver schaut, wie groß der Fehler des aktuellen Zustands ist.
- Dann schätzt er, in welche Richtung sich die beweglichen Größen verändern müssen.
- Danach wiederholt er das, bis die Lösung „gut genug“ ist.

## 6. Wichtiger Unterschied zwischen „geometrisch korrekt“ und „physikalisch vollständig“

Ein Solver kann eine konsistente geometrische Lösung finden, ohne dass das gesamte mechanische System mit Massen, Kräften und Simulationsdauer vollständig modelliert ist. Das ist bei Assemblies oft genau der gewünschte Einsatz.

Der Fokus liegt dann auf:

- Stabilität der Konfiguration
- Konsistenz der Beziehungen
- Erfüllung der Constraints

Nicht immer auf physikalische Dynamik im engeren Sinne.

## 7. So sieht ein typischer Ablauf aus

Ein typischer Solve-Lauf läuft in etwa so:

1. Daten aus FreeCAD werden in Solver-Objekte übersetzt.
2. Jedes Teil bekommt eine Position und Orientierung.
3. Jede Verbindung wird als Constraint oder Joint modelliert.
4. Der Solver baut das Gleichungssystem auf.
5. Der Solver startet mit einer Näherung.
6. Fehler werden berechnet.
7. Iterationen verbessern die Lösung.
8. Das Ergebnis wird als neue Platzierungen zurückgegeben.

## 8. Warum dieses Modell für FreeCAD relevant ist

In FreeCAD macht das Modell genau folgendes:

- Die Benutzeroberfläche beschreibt nur die Beziehungen.
- Der Solver führt die numerische Berechnung durch.
- FreeCAD übernimmt das Ergebnis und zeigt es visuell an.

Damit bleibt die Bedienung verständlich, während der mathematische Kern unabhängig arbeitet.

## 9. Ein kleines C++-Beispiel: Konzept statt Compile-Ready-API

Das folgende Beispiel ist bewusst einfach und dient dem Lernverständnis. Es zeigt den denkbaren Ablauf, wie eine Beziehungsliste in einen Solver-Kontext übersetzt werden kann.

```cpp
#include <vector>
#include <string>
#include <cmath>

struct Part {
    std::string name;
    double x;
    double y;
    double z;
};

struct DistanceConstraint {
    std::string partA;
    std::string partB;
    double targetDistance;
};

int main() {
    std::vector<Part> parts = {
        {"A", 0.0, 0.0, 0.0},
        {"B", 3.0, 0.0, 0.0}
    };

    DistanceConstraint c{"A", "B", 5.0};

    // Einfache Fehlerfunktion: Abstand muss targetDistance sein.
    auto residual = [&](const Part& a, const Part& b) {
        double dx = b.x - a.x;
        double dy = b.y - a.y;
        double dz = b.z - a.z;
        double dist = std::sqrt(dx * dx + dy * dy + dz * dz);
        return dist - c.targetDistance;
    };

    double error = residual(parts[0], parts[1]);
    // Fehler wird iterativ reduziert.
    // Der Solver korrigiert dann die Positionen von B oder A.

    return 0;
}
```

Wichtig ist hier nicht die genaue Bibliothek, sondern das Muster:

- Teile mit Variablen
- Constraint mit gewünschter Kennzahl
- Fehlerfunktion
- iterative Annäherung

## 10. Ein kleines Python-Beispiel: Datenmodellierung und Fehlerbewertung

```python
import math

parts = {
    "A": {"x": 0.0, "y": 0.0, "z": 0.0},
    "B": {"x": 3.0, "y": 0.0, "z": 0.0},
}

def distance_error(part_a, part_b, target_distance):
    dx = part_b["x"] - part_a["x"]
    dy = part_b["y"] - part_a["y"]
    dz = part_b["z"] - part_a["z"]
    actual = math.sqrt(dx * dx + dy * dy + dz * dz)
    return actual - target_distance

error = distance_error(parts["A"], parts["B"], 5.0)
print(f"Fehler vor Korrektur: {error}")
```

Das zeigt auch die zentrale Idee: Eine Beziehung ist in der Regel eine Funktion, die einen Fehlerwert liefert. Je kleiner der Fehler, desto näher ist der Zustand an einer gültigen Lösung.

## 11. Fazit

OndselSolver funktioniert nicht durch „magische Intuition“, sondern nach einem klaren logischen Muster:

- Beziehungen werden in mathematische Bedingungen übersetzt
- Fehler werden bewertet
- Positionen werden iterativ angepasst
- Eine Lösung wird gefunden, wenn der Fehler klein genug ist

Das ist das zentrale Verständnis, das für die gesamte FreeCAD-Assembly-Arbeit wichtig ist.
