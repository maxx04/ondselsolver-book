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
2. Neue Kapitel werden an passender Stelle in `buch.md` eingefügt; die Nummern vergibt der Build automatisch.
3. Jedes Kapitel dokumentiert den aktuellen Stand, nicht eine historische Version.
4. Zusätzliche Beispiele, Bug-Notizen und FreeCAD-spezifische Erkenntnisse werden als Ergänzungen angehängt.

## Das Buch: `buch.md`

Das ganze Buch steht in einer einzigen Datei, [`buch.md`](./buch.md). Kapitel, Abschnitte und Abbildungen tragen dort **keine festen Nummern**; sie werden beim Erzeugen automatisch vergeben. Wird ein Kapitel eingefügt oder verschoben, stimmen alle Nummern und Verweise nach dem nächsten Build wieder.

Aufbau:

- Vorwort: Arbeitsprinzipien dieses Buches (ohne Nummer)
- **Teil I – Grundlagen, FreeCAD und ASMT** (Kapitel 1–9)
- **Teil II – OndselSolver-Programmierschnittstelle** (Kapitel 10–15)
- **Anhang A** – ASMT-Format: dokumentierter Stand am 30.09.2026

### HTML und PDF erzeugen

```bash
./build.sh        # erzeugt buch.html und buch.pdf
./build.sh html   # nur buch.html
```

Benötigt werden `pandoc` und für die PDF Chromium oder Google Chrome (anderer Browser über `CHROME_BIN`). Mermaid-Diagramme lädt die HTML-Seite beim Anzeigen aus dem Netz. `buch.html` und `buch.pdf` sind Build-Ergebnisse und nicht im Repository.

### Schreibregeln für Nummern, Bilder und Verweise

| Was | So schreiben | Ergebnis |
|---|---|---|
| Kapitel | `# Titel {#kap-name}` | „7 Titel“ |
| Abschnitt | `## Titel` oder `### Titel` | „7.2 Titel“, „7.2.1 Titel“ |
| Überschrift ohne Nummer | `### Titel {.unnumbered}` | „Titel“ |
| Neuer Teil | `# Titel {.teil}` | „Teil III – Titel“ |
| Abbildung | `![Beschriftung](bilder/datei.png){#abb-name}` | „Abbildung 7.1: Beschriftung“ |
| Verweis auf Kapitel | `siehe @kap-name` | „siehe Kapitel 7“ (als Link) |
| Verweis auf Abschnitt | `siehe @abs-name` (Abschnitt mit `{#abs-name}`) | „siehe Abschnitt 7.2“ |
| Verweis auf Abbildung | `siehe @abb-name` | „siehe Abbildung 7.1“ |

Nur Bilder **mit** Beschriftung werden als Abbildung nummeriert. Bilder gehören in den Ordner `bilder/`. Ein Verweis auf eine unbekannte Marke erscheint als „??“, und der Build gibt eine Warnung aus. Die Nummerierung steckt in [`tools/nummerierung.lua`](./tools/nummerierung.lua), das Layout in [`tools/buch-kopf.html`](./tools/buch-kopf.html).

## Beispielordner

- `examples/01-distance-constraint` – kleines C++-Beispiel für Abstand und Residuum
- `examples/02-iterative-solver` – iteratives Korrigieren eines Fehlers
- `examples/03-solver-data-model` – Datenmodell für Solver-Input
- `examples/04-freecad-pipeline` – simulierte FreeCAD → Solver → Ergebnis-Pipeline
- `examples/05-freecad-headless` – FreeCAD App GUI-Smoke-Test und optionaler Headless-Test
- `examples/06-asmt-structure` – strukturierte ASMT-Datenmodell-Demo
- `examples/07-ondselsolver-real-asmt` – echter OndselSolver-Solve mit `__cubes.asmt`, `fourbar.asmt` und `piston.asmt`
- `examples/08-ondselsolver-api` – ausführbare ASMT-API-Beispiele zu Part, Joint, Gravitation und Simulationsparametern

Die GUI-Makros starten standardmäßig `~/freecad/App_weekly/freecad.App`. Details zur AppImage-Installation und zum Dash-Eintrag stehen im Buch im Kapitel „FreeCAD AppImage unter Ubuntu und Dash-Icon“.

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
