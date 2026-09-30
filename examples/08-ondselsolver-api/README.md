# OndselSolver-API-Beispiele

Dieses Mini-Projekt macht die C++-Beispiele aus Part II ausführbar. Es verwendet die bekannte Fixture `__cubes.asmt` aus Beispiel 07, baut OndselSolver aus dem lokalen Submodul und prüft Schreib-/Lese-Roundtrips.

## Ausführen

```bash
./run.sh inspect
./run.sh part-api
./run.sh joint-api
./run.sh settings-api
```

`inspect` liest Parts und Joints aus der Fixture aus. `part-api`, `joint-api` und `settings-api` prüfen die Fabriken, Setter, `add*()`-Methoden und Owner-Zuordnungen im Speicher. Die neu erzeugten Objekte werden nicht gelöst.

Ein ASMT-Write/Read-Roundtrip wird bewusst nicht als bestanden ausgegeben: `ASMTJoint::storeOnLevel()` leitet den ASMT-Typ im aktuellen Quellstand mit einem festen Offset aus `typeid().name()` ab. Unter GCC entstehen dabei ungültige Abschnittsnamen wie `dJointE`, die `assemblyFromFile()` nicht wieder erkennt. Das vollständige Solve-Beispiel mit `assembly->solve()` steht in [`../07-ondselsolver-real-asmt`](../07-ondselsolver-real-asmt/README.md); `solve()` setzt die Zeiteinstellungen selbst zurück und ist hier nicht mit den konfigurierbaren Integrationsparametern vermischt.
