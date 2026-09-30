# OndselSolver für FreeCAD – lebendes Buchprojekt

Dieses Buch ist kein einmaliges Dokument, sondern ein fortlaufendes Projekt. Jede neue Erkenntnis wird an die vorhandene Fassung angehängt, nicht ersetzt. Der Sinn ist ein Nachschlagewerk, das mit dem Projekt wächst.

## Repository

Der Solver-Quellcode für Beispiel 07 ist als Git-Submodul unter `vendor/OndselSolver` eingebunden. Klone das Repository mit:

```bash
git clone --recurse-submodules https://github.com/maxx04/ondselsolver-book.git
```

Falls das Submodul bei einem normalen Clone noch fehlt: `git submodule update --init --recursive`.

## Zielgruppe

- Einsteigerinnen und Einsteiger in FreeCAD, Mechanik und Simulation
- Leser mit wenig bis keiner Vorkenntnis über Mehrkörper-Systeme oder Solver
- Entwicklerinnen und Entwickler, die verstehen wollen, wie OndselSolver in die FreeCAD-Assembly-Architektur eingebettet ist

## Prinzip des Projekts

1. Das Buch wird nur erweitert, nicht neu geschrieben.
2. Neue Kapitel werden nummeriert und in bestehende Verzeichnisse eingefügt.
3. Jedes Kapitel dokumentiert den aktuellen Stand, nicht eine historische Version.
4. Zusätzliche Beispiele, Bug-Notizen und FreeCAD-spezifische Erkenntnisse werden als Ergänzungen angehängt.

## Inhaltsübersicht

- 00-arbeitsprinzipien.md – Grundprinzipien und Arbeitsregeln für das Buch
- 01-was-ist-ondselsolver.md – Einstieg, Begriff, Zweck, Rolle in FreeCAD
- 02-wie-funktioniert-ondselsolver.md – Rechenmodell, Kinematik, Constraints, Newton/Iteration
- 03-datenvorbereitung-und-ergebnisinterpretation.md – Vorbereitung von Daten für den Solver und Analyse der Resultate
- 04-kommunikation-mit-freecad.md – Verbindung zwischen FreeCAD und OndselSolver
- 05-freecad-beispiele-und-bibliotheken.md – reale FreeCAD-/Solver-Bibliotheken und Integrationsmuster
- 06-formatbeschreibung-asmt.md – Verständnis des ASMT-Formats als Brücke zwischen CAD und Solver
- 07-freecad-asmt-ondselsolver-flow.md – Praxisfluss: FreeCAD → ASMT/Assembly → OndselSolver → Rückgabe in FreeCAD
- 08-freecad-app-ubuntu-und-dash-icon.md – FreeCAD AppImage unter Ubuntu einrichten und im Dash anheften
- 09-konkrete-ondselsolver-asmt-beispiele.md – echte ASMT-Fixtures mit OndselSolver laden, lösen und zurückschreiben
- 10-anhang-asmt-format-stand-2026-09-30.md – aktueller ASMT-Stand, recherchierte Quellen, Parserstruktur und Grenzen

## Beispielordner

- `examples/01-distance-constraint` – kleines C++-Beispiel für Abstand und Residuum
- `examples/02-iterative-solver` – iteratives Korrigieren eines Fehlers
- `examples/03-solver-data-model` – Datenmodell für Solver-Input
- `examples/04-freecad-pipeline` – simulierte FreeCAD → Solver → Ergebnis-Pipeline
- `examples/05-freecad-headless` – FreeCAD App GUI-Smoke-Test und optionaler Headless-Test
- `examples/06-asmt-structure` – strukturierte ASMT-Datenmodell-Demo
- `examples/07-ondselsolver-real-asmt` – echter OndselSolver-Solve mit `__cubes.asmt`, `fourbar.asmt` und `piston.asmt`

Die GUI-Makros starten standardmäßig `~/freecad/App_weekly/freecad.App`. Details zur AppImage-Installation und zum Dash-Eintrag stehen in Kapitel 08.

## Hinweis zu den Beispielen

Die Beispielordner dienen nicht nur als Lernhilfe, sondern als kompilierbare Mini-Demos für die Kapitel. Sie sollen immer weiter ergänzt werden, statt neu geschrieben zu werden.

## Arbeitsweise

- Bei jeder neuen Erkenntnis wird ein Kapitel erweitert oder eine neue Ergänzung ergänzt.
- Wichtige Erkenntnisse aus Source, Tests, Bugreports und Praxis werden direkt in die relevanten Kapitel eingearbeitet.
- Wiederholte Themen sollten durch Querverweise verknüpft werden, nicht durch Abschreiben.

## Erste Grundposition

OndselSolver ist kein „Black Box“-Plugin, sondern ein Rechensystem für Mehrkörpersysteme, das geometrische Beziehungen und Bewegungsgesetze in numerischer Form löst. In FreeCAD tritt es vor allem als Assembly-Solver auf, der Bauteile durch Kontakte, Achsen, Winkel, Abstände und feste Verbindungen miteinander verbindet und dann eine konsistente Lage ermittelt.

Ein Leser sollte dabei nicht nur „den Button drücken“ wollen, sondern verstehen:

- welche Daten in den Solver eingehen,
- wie diese Daten modelliert werden,
- was der Solver als Ergebnis zurückliefert,
- wie FreeCAD das Ergebnis wieder in die 3D-Welt überträgt.

## Beispiele und kompilierbare Demos

Im Unterordner [examples](./examples/README.md) gibt es ein eigenes Beispiel-Set mit kompilierbaren C++-Programmen. Jeder Abschnitt hat dort einen passenden Mini-Ordner mit:

- `main.cpp` oder vergleichbarem Source-Code
- `CMakeLists.txt`
- eigener Build-Route für lokale Ausführung

Build-Beispiel:

```bash
cmake -S examples -B examples/build
cmake --build examples/build
```

## Nächster Schritt

Das erste Kapitel beginnt mit dem wesentlichen Grundbegriff: Was ist OndselSolver eigentlich?
