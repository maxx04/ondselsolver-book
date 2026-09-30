# 11. Part II: Programmierschnittstelle von OndselSolver

## 11.1 Ziel und Geltungsbereich

Part II beschreibt, wie ein C++-Programm OndselSolver aufruft und Solver-Assemblies modelliert. Die wichtigste Integrationsschicht dieses Quellstands ist die ASMT-Objektfamilie (`ASMTAssembly`, `ASMTPart`, Marker, Joints, Motions und Parameter). Der Aufruf `ASMTAssembly::solve()` übersetzt diese Objekte in das interne MbD-System und startet die Berechnung.

„Alle Funktionen“ muss hier präzise abgegrenzt werden: Der Quellbaum enthält Hunderte Klassen und tausende Methoden, darunter Matrixoperationen, symbolische Ableitungen, Constraint-Gleichungen und Integrator-Schritte. Diese sind nicht automatisch eine stabile Anwendungs-API. Die Kapitel behandeln daher vollständig die fachlichen ASMT-Einstiegspunkte und ordnen den internen Solver nach Funktionsfamilien ein. Parser-, Serialisierungs- und Diagnosehilfen werden als Implementierungs-/Erweiterungspunkte markiert, nicht als notwendige Anwendungsaufrufe.

Maßgebliche Referenz ist immer der eingebundene Quellstand unter `vendor/OndselSolver/OndselSolver`. Der Parser akzeptiert nur eine Teilmenge der im Verzeichnis vorhandenen Klassen. Eine vorhandene C++-Klasse ist kein Beweis, dass derselbe Typ aus einer ASMT-Datei geladen oder über `solve()` verwendet werden kann.

## 11.2 Schichtenmodell

| Ebene | Haupttypen | Aufgabe |
|---|---|---|
| Eingabe/Ausgabe | `ASMTAssembly::assemblyFromFile`, `outputFile` | ASMT laden und serialisieren |
| Solvermodell | `ASMTAssembly`, `ASMTPart`, `ASMTMarker`, `ASMTJoint` | Körper, Lage, Referenzen und Beziehungen darstellen |
| Analysevorgaben | `ASMTMotion`, `ASMTLimit`, `ASMTForceTorque`, `ASMTConstantGravity`, `ASMTSimulationParameters` | Bewegung und Analyseparameter festlegen |
| Übersetzung | `createMbD`, `deleteMbD`, `updateFromMbD` | ASMT-Objekte in interne MbD-Objekte abbilden und Ergebnisse zurückkopieren |
| Numerischer Kern | `System`, `Constraint`, Newton-Raphson-, Integrator- und Matrixklassen | Gleichungen aufstellen, lösen und integrieren |

Für gewöhnliche Programme ist die oberste ASMT-Schicht der sinnvollste Einstieg. Die Übersetzungs- und Numerikmethoden sind hauptsächlich für Solverentwicklung und gezielte Erweiterungen relevant.

## 11.3 Linken und Namensraum

Das echte Buchbeispiel bindet `ASMTAssembly.h` ein und linkt gegen die mit CMake gebaute Bibliothek `OndselSolver`:

```cpp
#include "ASMTAssembly.h"

#include <iostream>
#include <stdexcept>

int main(int argc, char* argv[]) {
    const std::string input = argc > 1 ? argv[1] : "__cubes.asmt";
    const std::string output = argc > 2 ? argv[2] : "__cubes-solved.asmt";

    try {
        auto assembly = MbD::ASMTAssembly::assemblyFromFile(input);
        assembly->solve();
        assembly->outputFile(output);
        std::cout << "Ergebnis geschrieben: " << output << '\n';
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
```

`MbD` ist der C++-Namensraum. `assemblyFromFile()` liefert einen `std::shared_ptr<ASMTAssembly>`; das Beispiel hält die Assembly deshalb mit `auto` und greift über `->` auf Methoden zu. Der genaue, getestete Build einschließlich Fixture-Pfad ist [`examples/07-ondselsolver-real-asmt`](./examples/07-ondselsolver-real-asmt/README.md).

## 11.4 Erzeugen oder Laden

Es gibt zwei typische Wege:

1. **ASMT laden:** `ASMTAssembly::assemblyFromFile(filename)` ist der kürzeste und im Buchbeispiel geprüfte Weg. Der Parser erzeugt die Objekte aus den unterstützten ASMT-Blöcken.
2. **Objekte in C++ erzeugen:** ASMT-Klassen bieten häufig eine statische Fabrik `With()`. Anschließend werden ihre Daten gesetzt und Objekte über Assembly-Methoden hinzugefügt. Diese Route verlangt genaue Kenntnis der konkreten Klassenfelder und Markerreferenzen; nicht alle Datenklassen bieten komfortable Setter.

`ASMTAssembly::With()` erzeugt eine leere Root-Assembly. `setName()` stammt von `ASMTItem`; Lage und Orientierung werden über `ASMTSpatialItem` gesetzt. Beim direkten Aufbau muss die Modellierung vollständig sein, bevor `solve()` aufgerufen wird: insbesondere Markerpfade, Joint-Seiten und Anfangslagen.

## 11.5 Lebenszyklus als Faustregel

```text
ASMT-Datei oder C++-Objekte
    -> ASMTAssembly
    -> solve()
    -> updateFromMbD() innerhalb der Rückgabe-/Ausgabepipeline
    -> outputFile()
```

Die öffentlichen Arbeitsaufrufe für den typischen Batch-Fall sind `assemblyFromFile()`, `solve()` und `outputFile()`. `parseASMT()`, `createMbD()`, `updateFromMbD()` und `storeOnLevel()` gehören zur Objektübersetzung beziehungsweise Serialisierung. Sie sind nützlich, wenn man die Schnittstelle erweitert, aber normalerweise keine zusätzlichen Schritte im Clientprogramm.

## 11.6 Was nicht versprochen wird

OndselSolver ist in diesem Repository eine C++-Bibliothek mit vielen öffentlich deklarierten Headermethoden; daraus folgt nicht automatisch eine versionierte ABI oder ein stabiler Vertrag für jede Methode. Der Parser nutzt im geprüften Stand exakte Abschnittsreihenfolgen und teilweise Assertions. Fehlerhafte ASMT-Eingaben können daher anders scheitern als mit einer umfassenden Schema-Validierung. Die konkrete Unterstützung ist je Typ in den Folgekapiteln an Parser und Fixtures gebunden.