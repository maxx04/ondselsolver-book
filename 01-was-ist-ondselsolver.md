# 01. Was ist OndselSolver?

## 1. Ein kurzer Satz

OndselSolver ist ein Mehrkörper- und Assembliesolver. Er berechnet, wie Teile in einer Konstruktion zueinander liegen müssen, wenn bestimmte geometrische Beziehungen, Gelenke, Abstände oder Winkel eingehalten werden sollen.

In einem CAD-Kontext ist das besonders wichtig für Baugruppen, Mechanismen und Kinematik. FreeCAD kann Teile und Beziehungen modellieren; der Solver findet dann eine konsistente Lage der Teile, wenn diese Beziehungen erfüllt sein müssen.

## 2. Warum ein Solver überhaupt nötig ist

Ohne Solver wäre eine Baugruppe nur eine Menge von Objekten mit Positionen. Der Benutzer kann sie manuell bewegen, aber das System kennt die Beziehungen zwischen den Teilen nicht in numerisch umsetzbarer Form.

Ein Solver bringt genau diese logische Schicht ein:

- „Teil A ist mit Teil B über eine Drehachse verbunden“
- „Teil C muss auf der Ebene von Teil D liegen“
- „Die Distanz zwischen den Punkten muss 45 mm betragen“
- „Die Drehung von Teil X muss mit Translation von Teil Y gekoppelt sein“

Der Solver nimmt diese Bedingungen, modelliert sie als Gleichungen und sucht nach einer konsistenten Lösung.

## 3. OndselSolver in der FreeCAD-Welt

In der FreeCAD-Assembly-Architektur wirkt OndselSolver als die Berechnungsebene hinter der Baugruppenlogik. Der Benutzersicht bleibt dabei meist die 3D-Baugruppe und die Joint-Definitionen erhalten. Unter der Oberfläche übernimmt der Solver die Berechnung der Positionen und Orientierungen.

Das ist entscheidend: FreeCAD stellt die Daten bereit, OndselSolver verarbeitet sie. Danach kann FreeCAD die berechneten Platzierungen wieder in die 3D-Geometrie einsetzen.

## 4. Typische Aufgaben eines Solvers

Ein Assembly-Solver muss typischerweise diese Dinge leisten:

- bekannte Ausgangslage prüfen
- Freiheitsgrade erkennen
- Constraints und Gelenke auflösen
- fehlende oder redundante Bedingungen entdecken
- zu einer konsistenten Lage konvergieren
- Ergebnisse in Form neuer Platzierungen zurückgeben

## 5. Kinematik vs. Dynamik

Ein wichtiger Punkt: Ein Solver für Baugruppen ist nicht automatisch nur eine „Bewegungssimulation“ im Sinne einer vollständigen Dynamik mit Kräften, Massen und Zeitintegration.

Die Grundidee ist oft:

- Kinematik: Wie liegen die Teile zueinander, wenn die Beziehungen erfüllt werden?
- Dynamik: Wie bewegen sie sich über Zeit unter Kräften, Trägheit und Bewegungsgesetzen?

OndselSolver kann in diesem Zusammenhang als Mehrkörper-Mechanik-Engine verstanden werden: Sie arbeitet mit geometrischen und mechanischen Constraints, nicht nur mit bloßer Geometrie-Objektplatzierung.

## 6. Warum das für FreeCAD relevant ist

Für FreeCAD ist das besonders wichtig, weil Baugruppen oft aus mehreren Teilen bestehen, die eine funktionale Beziehung zueinander besitzen. Beispiele:

- Schwenkarm und Gelenk
- Lager und Ausrichtung
- Korrekte Position von Bohrungen oder Schnitten
- Kinematische Kette mit mehreren beweglichen Gliedern

Der Solver macht aus diesen Beziehungen eine technische, berechenbare Struktur. Das ist der Kern dessen, was in FreeCAD als Assembly-Lösung bezeichnet wird.

## 7. Ein einfaches Alltagsschema

Wenn ein Benutzer eine Baugruppe zusammenbaut, dann beschreibt er meist intuitiv:

- „Diese zwei Teile sollen fest verbunden sein.“
- „Diese Linie und diese Achse sollen aufeinander liegen.“
- „Dieser Winkel soll 90° betragen.“

Der Solver verwandelt diese Aussagen in formalisierte Gleichungen. Dann löst er sie im Sinne eines Systems aus miteinander verbundenen Bedingungen.

## 8. Die zentrale Idee in einem Satz

OndselSolver ist die Recheneinheit, die in FreeCAD aus geometrischen Relationen eine konsistente mechanische Konfiguration erzeugt.

Damit ist es nicht nur ein Spezialwerkzeug, sondern ein grundlegender Baustein, der das Denken in „Objekten“ in das Denken in „Beziehungen“ übersetzt.

## 9. Wichtige Lernfrage

Der Leser sollte sich im Verlauf des Buches immer fragen:

- Welche Beziehung beschreibt dieser Joint oder Constraint?
- Welches Teil hat welchen Freiheitsgrad?
- Welche Variable wird vom Solver gelöst?
- Was ist die Ausgangsbedingung und welche Resultate sind akzeptabel?

Diese Fragen sind der Schlüssel zum Verständnis von OndselSolver.
