-- OneUIZen Reminders.lua
-- Lee y agrega recordatorios en @Resources\Reminders.txt con decodificacion segura UTF-8 -> ANSI para tildes en Rainmeter.

local function utf8ToAnsi(str)
  if not str then return "" end
  local map = {
    ["\195\161"] = "\225", ["\195\169"] = "\233", ["\195\173"] = "\237",
    ["\195\179"] = "\243", ["\195\186"] = "\250", ["\195\177"] = "\241",
    ["\195\188"] = "\252", ["\195\129"] = "\193", ["\195\137"] = "\201",
    ["\195\141"] = "\205", ["\195\147"] = "\211", ["\195\154"] = "\218",
    ["\195\145"] = "\209", ["\194\191"] = "\191", ["\194\161"] = "\161"
  }
  return (str:gsub("[\194\195][\128-\191]", map))
end

function Initialize()
  LoadReminders()
end

function Update()
  LoadReminders()
  return 1
end

function LoadReminders()
  local filePath = SKIN:GetVariable("@") .. "Reminders.txt"
  local lines = {}
  local f = io.open(filePath, "r")
  if f then
    local first = true
    for line in f:lines() do
      if first then
        line = line:gsub("^\239\187\191", "")
        first = false
      end
      local trimmed = utf8ToAnsi(line):match("^%s*(.-)%s*$")
      if trimmed ~= "" then
        table.insert(lines, trimmed)
      end
      if #lines >= 3 then break end
    end
    f:close()
  end

  for i = 1, 3 do
    local text = lines[i] or ""
    SKIN:Bang("!SetVariable", "RemLine" .. i, text)
    SKIN:Bang("!SetVariable", "RemHidden" .. i, (text ~= "") and "0" or "1")
  end
  SKIN:Bang("!UpdateMeter", "*")
  SKIN:Bang("!Redraw")
end

function AddPending()
  local newText = SKIN:GetVariable("PendingRem", "")
  if not newText then return end
  local trimmed = newText:match("^%s*(.-)%s*$")
  if trimmed == "" then return end

  local filePath = SKIN:GetVariable("@") .. "Reminders.txt"
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
  SKIN:Bang("!SetVariable", "PendingRem", "")
  LoadReminders()
end
