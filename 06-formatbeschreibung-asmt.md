# 06. Formatbeschreibung ASMT

## 1. Was ist ASMT?

ASMT ist ein Assemblies-/Solver-Format, das als Austausch- und Zwischendarstellung zwischen einer FreeCAD-Äquivalenzmodellierung und dem OndselSolver genutzt werden kann. Es ist kein rein „grafisches“ Format, sondern ein strukturiertes Datenformat für Mechanik- und Kinematik-Modelle.

In diesem Projekt ist ASMT bereits als Vorstellung und Export-Mechanismus sichtbar:

- [CommandExportASMT.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/CommandExportASMT.py) enthält den Exportbefehl für `.asmt`-Dateien
- [Init.py](https://github.com/FreeCAD/FreeCAD/blob/main/src/Mod/Assembly/Init.py) registriert `.asmt` als Importtyp
- `vendor/OndselSolver/OndselSolver/ASMTAssembly.cpp` und verwandte Klassen im Submodul modellieren das Solver-seitige Format

Damit ist ASMT ein sehr konkretes Bindeglied zwischen FreeCAD-Modell und OndselSolver-Repräsentation.

## 2. Warum ein separates Format sinnvoll ist

Ein 3D-Modell in FreeCAD enthält oft mehr als nur mechanische Beziehungen. Es enthält:

- geometrische Bauteile,
- Platzierung und Transformation,
- Joints und Constraints,
- Gruppen und Bezugssysteme,
- zusätzliche Metadaten der Bearbeitung.

Der Solver benötigt aber meist eine klarere, reduzierte und strukturierte Darstellung. Genau dafür ist ASMT nützlich: Es beschreibt die Assembly-Informationen in einer Form, die für die Berechnung besser geeignet ist.

## 3. Typische Inhalte eines ASMT-Modells

Ein ASMT-Modell enthält typischerweise eine Kombination aus:

- Teilen (`part`, `body`, `item`-ähnliche Objekte)
- Verbindungen (`joint`, `constraint`)
- Bezugssystemen (`frame`, `marker`, `coordinate system`)
- Platzierungen (`position`, `rotation`, `orientation`)
- Informationen über die Beziehung zwischen den Teilen

Das Format soll also nicht nur Geometrie speichern, sondern auch die Kinematik- und Constraints-Semantik.

## 4. Das ASMT-Modell aus Sicht der Solver-Architektur

Im OndselSolver-Code sind Strukturen wie `ASMTAssembly`, `ASMTPart`, `ASMTJoint` oder ähnliche Klasen eine unmittelbare signalisierte Sichtweise auf eine Assembly-Definition. Diese Klassen sind nicht zufällig benannt: Sie modellieren die gleiche Idee wie in FreeCAD, nur in einer formelleren, solverorientierten Weise.

Das bedeutet:

- Ein Assembly-Teil in FreeCAD soll im ASMT-Format als ein solverfähiger Teil erscheinen.
- Ein Joint in FreeCAD wird als ASMT-Joint bzw. Constraint-Klasse ins Modell übertragen.
- Die Positionsergebnisse des Solvers werden später wieder in die FreeCAD-Objekte zurückgegeben.

## 5. Ein Beispiel für die Struktur eines ASMT-Dokuments

ASMT ist in der Praxis für Menschen meist nicht komplett „handgeschriebenes XML“, sondern ein lesbares, strukturiertes Textformat. Die genaue Ausformung kann je nach Implementierung variieren, aber die Idee bleibt konstant:

```text
Assembly {
  Name: ExampleAssembly

  Part {
    Name: Base
    Position: 0 0 0
  }

  Part {
    Name: Arm
    Position: 10 0 0
  }

  Joint {
    Type: Revolute
    PartA: Base
    PartB: Arm
    Axis: Z
  }
}
```

Wichtig ist hier nicht die exakte Syntax eines bestimmten Standards, sondern das Konzept:

- Teile werden benannt
- Beziehungen werden als Joints oder Constraints beschrieben
- die relative Lage wird durch Formulierung der Verbindung definiert

## 6. Wie ASMT mit FreeCAD zusammenhängt

ASMT ist die Brücke zwischen:

- dem verständlichen, graphischen FreeCAD-Modell,
- und der numerischen, solverorientierten Darstellung.

FreeCAD erzeugt oder exportiert die Assembly-Daten in ein Format, das der Solver semantisch verarbeiten kann. Danach kann der Solver die Positions- und Orientierungswerte berechnen und in die FreeCAD-Objekte zurückführen.

Diese Rolle ist in `CommandExportASMT.py` deutlich sichtbar: Es ist eine explizite Export-Aktion, die auf eine existierende Assembly angewendet wird.

## 7. Warum ASMT für Lernende wichtig ist

Ein Leser, der das Buch ernsthaft verstehen will, sollte ASMT als „eine zugeschnittene, solverfreundliche Version der CAD-Assembly-Informationen“ verstehen. Das hilft bei drei Dingen:

- die Datenstruktur zu verstehen,
- die Rollen von Teilen, Gelenken und Constraints zu erkennen,
- die Verbindung zwischen Benutzeroberfläche und numerischer Berechnung zu sehen.

## 8. Ein wichtiger realistischer Punkt

In diesem Projekt selbst ist ASMT noch als Forschungs-/Interoperabilitätsformat sichtbar, nicht als vollständig ausgereiftes, universell abgeschlossenes Dateiformat. Das zeigt die `Init.py`-Kommentierung sehr klar: „The correct format for assembly interoperability is a research topic. ASMT is a placeholder.“

Das heißt:

- ASMT ist ein sehr wichtiges, relevantes Konzept,
- aber es ist noch keine „fertige, abschließende universelle Spezifikation“ in dem Sinne, wie ein vollständiger Dateistandard sein könnte.
- Für Lernzwecke ist es trotzdem ein sehr nützliches Denkmodell.

## 9. Fazit

ASMT ist die sprachliche und strukturelle Brücke zwischen einem visuellen CAD-Modell und dem mathematischen Mehrkörpersystem des Solvers. Es macht aus einer Baugruppe eine strukturierte, berechenbare Definition aus Teilen, Beziehungen und Constraints.

Für den Lernenden bedeutet das:

- ASMT ist kein bloßes Nebenprodukt,
- sondern ein Schlüsselkonzept für das Verständnis von FreeCAD + OndselSolver.

Das ist genau der Punkt, an dem der Übergang von „Objektmodellierung“ zu „solverfähiger Mechanik“ sichtbar wird.
