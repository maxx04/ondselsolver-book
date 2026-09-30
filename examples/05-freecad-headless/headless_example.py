import FreeCAD

# Ein einfacher headless FreeCAD-Lauf:
# - Dokument erzeugen
# - einfache Objektdefinition
# - Ausgabe in der Konsole

doc = FreeCAD.newDocument("HeadlessDemo")
box = doc.addObject("Part::Box", "DemoBox")
box.Length = 10
box.Width = 20
box.Height = 5

print("Dokument:", doc.Name)
print("Box-Länge:", box.Length)
print("Box-Breite:", box.Width)
print("Box-Höhe:", box.Height)
