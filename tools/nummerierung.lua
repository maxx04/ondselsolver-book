-- Automatische Nummerierung für buch.md
--
-- Überschriften:
--   # Titel {.teil}          -> "Teil I – Titel" (zählt nicht als Kapitel)
--   # Anhang {.anhang}       -> ab hier werden Kapitel mit A, B, ... gezählt
--   # Titel {#kap-…}         -> Kapitel 1, 2, ...
--   ## / ### Titel           -> Abschnitt 1.1 / 1.1.1
--   {.unnumbered}            -> bleibt ohne Nummer (auch alle Unterabschnitte eines
--                               nicht nummerierten Kapitels)
-- Abbildungen:
--   ![Beschriftung](bilder/datei.png){#abb-…}  -> "Abbildung 3.1: Beschriftung"
-- Querverweise im Text (Ausgabe als Link):
--   @kap-… -> "Kapitel 3"  /  "Anhang A"
--   @abs-… -> "Abschnitt 3.2"
--   @abb-… -> "Abbildung 3.1"

local labels = {}

local function roman(n)
  local values = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, v in ipairs(values) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

local function has_class(el, name)
  for _, c in ipairs(el.classes) do
    if c == name then return true end
  end
  return false
end

local function prefix(text, inlines)
  local result = pandoc.List({ pandoc.Span(pandoc.Str(text), { class = "nummer" }), pandoc.Space() })
  result:extend(inlines)
  return result
end

local function number_document(doc)
  local part, chapter, appendix = 0, 0, 0
  local in_appendix = false
  local chapter_label = nil -- nil: aktuelles Kapitel ist nicht nummeriert
  local sections = {}
  local figures = 0

  return doc:walk({
    traverse = "topdown",

    Header = function(h)
      if h.level == 1 then
        sections, figures = {}, 0
        if has_class(h, "teil") then
          part = part + 1
          chapter_label = nil
          local label = "Teil " .. roman(part)
          h.content = prefix(label .. " –", h.content)
          if h.identifier ~= "" then labels[h.identifier] = label end
          return h
        end
        if has_class(h, "anhang") then
          in_appendix = true
          chapter_label = nil
          return h
        end
        if has_class(h, "unnumbered") then
          chapter_label = nil
          return h
        end
        local ref
        if in_appendix then
          appendix = appendix + 1
          chapter_label = string.char(64 + appendix)
          ref = "Anhang " .. chapter_label
          h.content = prefix("Anhang " .. chapter_label .. ":", h.content)
        else
          chapter = chapter + 1
          chapter_label = tostring(chapter)
          ref = "Kapitel " .. chapter_label
          h.content = prefix(chapter_label, h.content)
        end
        if h.identifier ~= "" then labels[h.identifier] = ref end
        return h
      end

      if h.level > 3 or chapter_label == nil or has_class(h, "unnumbered") then
        return h
      end
      local depth = h.level - 1
      sections[depth] = (sections[depth] or 0) + 1
      for i = depth + 1, #sections do sections[i] = nil end
      local parts = { chapter_label }
      for i = 1, depth do parts[#parts + 1] = tostring(sections[i] or 0) end
      local label = table.concat(parts, ".")
      h.content = prefix(label, h.content)
      if h.identifier ~= "" then labels[h.identifier] = "Abschnitt " .. label end
      return h
    end,

    Figure = function(fig)
      figures = figures + 1
      local label = chapter_label and (chapter_label .. "." .. figures) or tostring(figures)
      local caption = fig.caption.long
      if caption[1] and (caption[1].t == "Plain" or caption[1].t == "Para") then
        caption[1].content = prefix("Abbildung " .. label .. ":", caption[1].content)
      else
        caption:insert(1, pandoc.Plain(prefix("Abbildung " .. label, {})))
      end
      fig.caption.long = caption
      if fig.identifier ~= "" then labels[fig.identifier] = "Abbildung " .. label end
      return fig
    end,
  })
end

local function resolve_refs(cite)
  local out = pandoc.List()
  for i, c in ipairs(cite.citations) do
    local id = c.id
    if not id:match("^kap%-") and not id:match("^abs%-") and not id:match("^abb%-")
        and not id:match("^anh%-") and not id:match("^teil%-") then
      return nil -- kein Buchverweis, Original stehen lassen
    end
    local label = labels[id]
    if not label then
      io.stderr:write("WARNUNG: unbekannter Verweis @" .. id .. "\n")
      label = "??"
    end
    if i > 1 then out:extend({ pandoc.Str(","), pandoc.Space() }) end
    out:insert(pandoc.Link(label, "#" .. id))
  end
  return out
end

-- Mermaid-Diagramme im HTML vom Browser zeichnen lassen.
local function mermaid(block)
  if FORMAT:match("html") and has_class(block, "mermaid") then
    local escaped = block.text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    return pandoc.RawBlock("html", '<pre class="mermaid">' .. escaped .. "</pre>")
  end
end

return {
  { Pandoc = number_document },
  { Cite = resolve_refs, CodeBlock = mermaid },
}
