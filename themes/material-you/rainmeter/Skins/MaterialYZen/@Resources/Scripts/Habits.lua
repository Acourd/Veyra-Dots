-- MaterialYZen Habits.lua
-- Gestiona los 7 puntos semanales de HabitDots en ES o EN.

function Initialize()
  SyncHabits()
end

function Update()
  SyncHabits()
  return 1
end

function SyncHabits()
  local primary = SKIN:GetVariable("Primary", "168,199,250,255")
  local container = SKIN:GetVariable("SurfaceContainer", "29,36,48,245")
  local lang = SKIN:GetVariable("Language", "ES")
  local unit = SKIN:GetVariable("LblDays", (lang == "EN") and "DAYS" or "DÍAS")
  local count = 0

  for i = 1, 7 do
    local val = tonumber(SKIN:GetVariable("HabitDay" .. i, "0")) or 0
    if val == 1 then
      count = count + 1
      SKIN:Bang("!SetVariable", "DotColor" .. i, primary)
    else
      SKIN:Bang("!SetVariable", "DotColor" .. i, container)
    end
  end

  SKIN:Bang("!SetVariable", "HabitStreak", tostring(count) .. " / 7 " .. unit)
  SKIN:Bang("!UpdateMeter", "*")
  SKIN:Bang("!Redraw")
end

function ToggleDay(dayIndex)
  local i = tonumber(dayIndex)
  if not i or i < 1 or i > 7 then return end
  local cur = tonumber(SKIN:GetVariable("HabitDay" .. i, "0")) or 0
  local nextVal = (cur == 1) and 0 or 1
  local prodFile = SKIN:GetVariable("@") .. "Productivity.inc"
  SKIN:Bang("!WriteKeyValue", "Variables", "HabitDay" .. i, tostring(nextVal), prodFile)
  SKIN:Bang("!SetVariable", "HabitDay" .. i, tostring(nextVal))
  SyncHabits()
end

function ResetWeek()
  local prodFile = SKIN:GetVariable("@") .. "Productivity.inc"
  for i = 1, 7 do
    SKIN:Bang("!WriteKeyValue", "Variables", "HabitDay" .. i, "0", prodFile)
    SKIN:Bang("!SetVariable", "HabitDay" .. i, "0")
  end
  SyncHabits()
end
