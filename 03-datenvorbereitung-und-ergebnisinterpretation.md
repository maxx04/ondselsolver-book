# 03. Datenvorbereitung für den Solver und Ergebnisinterpretation

## 1. Warum Datenvorbereitung so wichtig ist

Ein Solver ist nur so gut wie die Daten, die ihm gegeben werden. Wenn die Eingabedaten schlecht modelliert, inkonsistent, doppeldeutig oder numerisch instabil sind, wird selbst ein guter Solver keine zuverlässige Antwort liefern.

Für FreeCAD bedeutet das: Eine Baugruppe muss sinnvoll aufgebaut sein, damit OndselSolver sie verarbeiten kann.

## 2. Typische Vorbereitungsaufgaben

Vor einem Solve sind häufig diese Schritte nötig:

- Teil- und Joint-Definitionen prüfen
- Referenzen auf richtige Objekte auflösen
- unerwünschte oder redundante Constraints entfernen
- geerdete Teile und relative Bewegungen sauber trennen
- Startwerte plausibel wählen
- numerische Toleranzen prüfen

## 3. Gute Datenstruktur für den Solver

Ein einfacher und verständlicher Stil ist dieser:

- Jedes Teil erhält eine eindeutige ID
- Jedes Joint oder Constraint erhält einen Typ
- Jedes Joint enthält seine Referenzen und gewünschte Parameter
- Der Solver bekommt eine konsistente Liste dieser Objekte

In Python sieht das typischerweise so aus:

```python
parts = {
    "base": {"id": "base", "x": 0.0, "y": 0.0, "z": 0.0},
    "arm": {"id": "arm", "x": 2.0, "y": 0.0, "z": 0.0},
}

joints = [
    {"type": "revolute", "part_a": "base", "part_b": "arm", "axis": "z"},
]
```

Diese Struktur ist nicht „die echte API“ von OndselSolver, sondern ein Lernmodell. Es zeigt, wie man Daten logisch gruppiert und dem Solver bereitstellt.

## 4. C++-Ansatz für Solver-Daten

In C++ ist eine klare Struktur oft sehr hilfreich. Ein Beispiel:

```cpp
#include <string>
#include <vector>

struct PartData {
    std::string id;
    double x;
    double y;
    double z;
};

struct JointData {
    std::string type;
    std::string partA;
    std::string partB;
    double value;
};

int main() {
    std::vector<PartData> parts = {
        {"base", 0.0, 0.0, 0.0},
        {"arm", 2.0, 0.0, 0.0}
    };

    std::vector<JointData> joints = {
        {"revolute", "base", "arm", 90.0}
    };

    // Die Daten sind jetzt bereit für die Systembildung.
    // Der Solver kann diese Informationen in Constraints transformieren.
    return 0;
}
```

Der Kern ist hier nicht die genaue API, sondern das Prinzip: Die Daten müssen sauber, strukturiert und konsistent sein.

## 5. Häufige Fehler beim Vorbereiten von Solver-Daten

Diese Punkte treten besonders oft auf:

- Referenz auf falsches Teil
- unvollständige Gelenk-Definition
- inkonsistente Achsenausrichtung
- Redundanz von Constraints
- Geometrie mit zu wenig Informationen
- schlechte Startwerte

Diese Faktoren führen dazu, dass der Solver entweder nicht konvergiert oder eine Lösung findet, die zwar mathematisch denkbar ist, aber für die reale Anwendung unbrauchbar bleibt.

## 6. Ergebnisinterpretation

Wenn ein Solver eine Berechnung beendet, muss der Leser nicht nur wissen, ob der Solve „funktioniert hat“, sondern auch was das Ergebnis bedeutet.

Wichtige Fragen:

- Ist der Lösungsfehler klein genug?
- Gibt es noch freie Freiheitsgrade?
- Waren die Constraints wirklich erfüllt?
- Hat der Solver eine gültige Lösung gefunden oder nur einen Konsistenzpunkt?

## 7. Wie Fehlerwerte interpretiert werden

Ein Solver liefert normalerweise keine „schöne“ Zahl, sondern eine Residuen- oder Fehlerinformation. Das muss man lesen:

- Residuum nahe null: gute Übereinstimmung
- großes Residuum: Constraint nicht erfüllt
- keine Konvergenz: Ausgangslage oder Modell unpassend
- multiple Lösungen: gleiche Beziehung kann mehrere geometrische Lösungen zulassen

## 8. Python-Example zur Ergebnisprüfung

```python
results = {
    "base": {"x": 0.0, "y": 0.0, "z": 0.0},
    "arm": {"x": 4.0, "y": 0.0, "z": 0.0},
}

required_distance = 4.0

def check_distance(part_a, part_b, expected):
    dx = part_b["x"] - part_a["x"]
    dy = part_b["y"] - part_a["y"]
    dz = part_b["z"] - part_a["z"]
    actual = (dx * dx + dy * dy + dz * dz) ** 0.5
    residual = abs(actual - expected)
    return residual

residual = check_distance(results["base"], results["arm"], required_distance)
print(f"Residual der Abstandsbedingung: {residual}")
```

Das zeigt die zentrale Regel: Nicht „es gibt ein Ergebnis“, sondern „das Ergebnis erfüllt die gewünschte Beziehung innerhalb der Toleranz“ ist entscheidend.

## 9. Die praktische Bedeutung in FreeCAD

In FreeCAD bedeutet Ergebnisinterpretation konkret:

- untersucht man die Position der gelösten Teile,
- prüft man anschließend, ob die gezeichneten Beziehungen konsistent sind,
- vergleicht man die von der UI gezeigten Werte mit den vom Solver berechneten Werten,
- erkennt man früh, ob das Modell numerisch stabil ist.

## 10. Fazit

Vorbereitung und Interpretation sind zwei Seiten derselben Aufgabe:

- Die Vorbereitungsphase macht aus einer Idee ein mathematisch gültiges System.
- Die Interpretationsphase macht aus einer Lösung eine verständliche, nutzbare Baugruppenlage.

Ohne diese beiden Schritte wird ein Solver nicht als hilfreiches Werkzeug wahrgenommen, sondern als „Black Box“, die manchmal funktioniert und manchmal nicht.
