#!/usr/bin/python3
"""Kommentare (Annotationen) aus einer PDF auslesen: Seite, Typ, Kommentar, markierter Text.

Aufruf: tools/kommentare.py buch-kommentiert.pdf
Benötigt: pypdf (sudo apt install python3-pypdf) und pdftotext (poppler-utils).
"""
import subprocess
import sys

from pypdf import PdfReader

SKIP = {"/Link", "/Popup", "/Widget"}


def text_in_rect(pdf, page_no, page_h, x0, y0, x1, y1):
    # pdftotext erwartet Koordinaten von oben links in Punkten
    pad = 1
    args = ["pdftotext", "-f", str(page_no), "-l", str(page_no),
            "-x", str(int(x0 - pad)), "-y", str(int(page_h - y1 - pad)),
            "-W", str(int(x1 - x0 + 2 * pad)), "-H", str(int(y1 - y0 + 2 * pad)),
            pdf, "-"]
    out = subprocess.run(args, capture_output=True, text=True).stdout
    return " ".join(out.split())


def main(pdf):
    reader = PdfReader(pdf)
    found = 0
    for i, page in enumerate(reader.pages, start=1):
        page_h = float(page.mediabox.height)
        annots = page.get("/Annots")
        annots = annots.get_object() if annots is not None else []
        for ref in annots:
            a = ref.get_object()
            sub = a.get("/Subtype")
            if sub in SKIP:
                continue
            found += 1
            comment = a.get("/Contents") or ""
            marked = ""
            quads = a.get("/QuadPoints")
            if quads:
                q = [float(v) for v in quads]
                parts = []
                for k in range(0, len(q), 8):
                    xs, ys = q[k:k + 8:2], q[k + 1:k + 8:2]
                    parts.append(text_in_rect(pdf, i, page_h, min(xs), min(ys), max(xs), max(ys)))
                marked = " ".join(p for p in parts if p)
            elif "/Rect" in a:
                x0, y0, x1, y1 = (float(v) for v in a["/Rect"])
                # Notiz-Symbol: Text in der Zeile daneben als Kontext
                marked = text_in_rect(pdf, i, page_h, 0, y0 - 4, float(page.mediabox.width), y1 + 4)
            print(f"--- Seite {i} | {sub}")
            if comment:
                print(f"Kommentar: {comment}")
            if marked:
                print(f"Text:      {marked}")
    if not found:
        print("Keine Kommentare gefunden.")


if __name__ == "__main__":
    main(sys.argv[1])
