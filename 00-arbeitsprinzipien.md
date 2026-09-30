# 00. Arbeitsprinzipien dieses Buches

## 1. Warum dieses Buch als lebendes Projekt aufgebaut ist

Ein Buch über einen aktiven Solver in einer aktiven CAD-Umgebung muss mit dem Projekt wachsen. Das gilt besonders für FreeCAD und OndselSolver, weil sich Architektur, Bugs, APIs und Modellierungsprinzipien über Zeit verändern. Ein einmal fertiges Buch würde schnell veralten.

Darum gilt hier:

- Das Buch wird nicht komplett neu geschrieben.
- Kapitel werden ergänzt, korrigiert und vertieft.
- Neue Erkenntnisse werden in die vorhandene Struktur eingefügt.
- Jeder Abschnitt erhält eine sachliche, überprüfbare Grundlage.

## 2. Vorgehensweise der Dokumentation

Für dieses Projekt gilt ein einfacher Standard:

- Beschreibung des Sachverhalts auf verständlicher Ebene
- Einordnung in die reale FreeCAD-/OndselSolver-Architektur
- Beispiel oder kleine Reproduktion
- Hinweise, was in diesem Kontext relevant ist
- Verknüpfung mit den echten Dateien und Modulen im Sandbox-Projekt

## 3. Grundidee von OndselSolver

OndselSolver modelliert Mechanik als Beziehungssystem:

- Teile haben Positionen und Orientierungen.
- Gelenke, Kontakte und Constraints beschreiben Beziehungen zwischen diesen Positionen.
- Der Solver löst diese Beziehungen so, dass das System konsistent ist.

Das ist nicht dasselbe wie ein „Baukastensystem mit fertigen 3D-Schnitten“. Vielmehr ist der Solver ein numerischer Gleichungslöser, der geometrische und kinematische Bedingungen erfüllt.

## 4. Wichtiges Verständnis für Leser

Ein neuer Leser muss die folgenden Grundbegriffe verstehen:

- Part: ein Bauteil oder ein physischer Körper
- Joint: Verbindung zwischen Teilen
- Constraint: geometrische oder kinematische Bedingung
- Solve: Berechnung einer konsistenten Konfiguration
- Residuum: Restfehler einer Gleichung oder Beziehung
- Iteration: wiederholte Annäherung an eine Lösung

## 5. Wie dieses Buch mit Realcode verknüpft wird

Die Praxis ist wichtiger als bloße Theorie. Dieses Buch bezieht sich daher auf die im Sandbox-Projekt vorhandenen Quellstellen, insbesondere:

- FreeCAD-Assembly-Struktur
- OndselSolver-Quellcode im dritten Party Bereich
- Aufgaben und Bugreports aus dem Sandbox

Das bedeutet: Wenn ein Kapitel etwas über die Kommunikation zwischen FreeCAD und OndselSolver sagt, dann verweist es auf die Architektur der Baugruppenmodul-Implementierung und auf die typische Datenflusslogik, nicht nur auf allgemeine Theorie.

## 6. Regel für Ergänzungen

Wenn ein neues Kapitel hinzugefügt wird, gilt:

- bestehende Kapitel bleiben unverändert, soweit nicht klar notwendig
- neue Erkenntnisse werden an das Ende oder in eine passende Ergänzung eingefügt
- bei Fehlern wird der Text korrigiert, aber nicht in einem „Neuaufbau“ der gesamten Datei verworfen

## 7. Ziel dieses Buches

Das Buch soll das Verständnis schaffen, nicht nur einfach Fakten aufzuzählen. Ein Lernender soll am Ende verstehen:

- Was ein Solver macht
- Wie ein CAD-System ihm Daten liefert
- Wie das Ergebnis zurück in die 3D-Geometrie übernommen wird
- Warum FreeCAD und OndselSolver in einem gemeinsamen Architekturmodell verbunden sind

Dieses Buch ist somit ein langfristiger Lern- und Arbeitsdokument.
