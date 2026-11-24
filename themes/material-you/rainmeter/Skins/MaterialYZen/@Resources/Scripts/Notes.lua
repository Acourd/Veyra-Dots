-- MaterialYZen Notes.lua
-- Lee las primeras 4 líneas de @Resources\Notes.txt y agrega notas de forma segura (sin inyección de comillas).

function Initialize()
  LoadNotes()
end

function Update()
  LoadNotes()
  return 1
end

function LoadNotes()
  local filePath = SKIN:GetVariable("@") .. "Notes.txt"
  local lang = SKIN:GetVariable("Language", "ES")
  local unit = " " .. SKIN:GetVariable("LblNotes", (lang == "EN") and "notes" or "notas")
  local lines = {}
  local totalCount = 0
  local f = io.open(filePath, "r")
  if f then
    local isFirst = true
    for line in f:lines() do
      if isFirst then
        line = line:gsub("^\239\187\191", "")
        isFirst = false
      end
      local trimmed = line:match("^%s*(.-)%s*$")
      if trimmed ~= "" then
        totalCount = totalCount + 1
        if #lines < 4 then
          table.insert(lines, trimmed)
        end
      end
    end
    f:close()
  end

  for i = 1, 4 do
    local text = lines[i] or ""
    SKIN:Bang("!SetVariable", "NoteLine" .. i, text)
    SKIN:Bang("!SetVariable", "NoteVisible" .. i, (text ~= "") and "0" or "1")
  end
  SKIN:Bang("!SetVariable", "NoteCount", tostring(totalCount) .. unit)
  SKIN:Bang("!UpdateMeter", "*")
  SKIN:Bang("!Redraw")
end

function AddPendingNote()
  local newText = SKIN:GetVariable("PendingNote", "")
  if not newText then return end
  local trimmed = newText:match("^%s*(.-)%s*$")
  if trimmed == "" then return end

  local filePath = SKIN:GetVariable("@") .. "Notes.txt"
  local existing = ""
  local f = io.open(filePath, "r")
  if f then
    existing = f:read("*a") or ""
    f:close()
  end

  local out = io.open(filePath, "w")
  if out then
    out:write(trimmed .. "\n" .. existing)
    out:close()
  end
  SKIN:Bang("!SetVariable", "PendingNote", "")
  LoadNotes()
end
