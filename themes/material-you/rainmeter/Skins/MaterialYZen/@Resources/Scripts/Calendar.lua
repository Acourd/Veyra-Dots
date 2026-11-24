-- MaterialYZen Calendar.lua
-- Calcula la tira semanal simétrica (Lun..Dom) y barra de progreso del mes en ES o EN.

function Initialize()
  UpdateWeek()
end

function Update()
  UpdateWeek()
  return os.date("%d")
end

function UpdateWeek()
  local now = os.time()
  local t = os.date("*t", now)
  local lang = SKIN:GetVariable("Language", "ES")
  local wdayMon = (t.wday == 1) and 7 or (t.wday - 1)

  local dayNames = (lang == "EN")
    and { "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN" }
    or  { "LUN", "MAR", "MIE", "JUE", "VIE", "SAB", "DOM" }

  local months = (lang == "EN")
    and { "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER" }
    or  { "ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE" }

  SKIN:Bang("!SetVariable", "CalHeader", months[t.month] .. " " .. t.year)
  SKIN:Bang("!SetVariable", "CalTodayIndex", tostring(wdayMon))

  local onPrimaryContainer = SKIN:GetVariable("OnPrimaryContainer", "211,227,253,255")
  local onSurface = SKIN:GetVariable("OnSurface", "227,232,240,255")
  local onSurfaceVariant = SKIN:GetVariable("OnSurfaceVariant", "166,178,200,255")

  for i = 1, 7 do
    local diff = (i - wdayMon) * 86400
    local dt = os.date("*t", now + diff)
    SKIN:Bang("!SetVariable", "DayNum" .. i, string.format("%02d", dt.day))
    SKIN:Bang("!SetVariable", "DayLbl" .. i, dayNames[i])
    if i == wdayMon then
      SKIN:Bang("!SetVariable", "DayLblColor" .. i, onPrimaryContainer)
      SKIN:Bang("!SetVariable", "DayNumColor" .. i, onPrimaryContainer)
    else
      SKIN:Bang("!SetVariable", "DayLblColor" .. i, onSurfaceVariant)
      SKIN:Bang("!SetVariable", "DayNumColor" .. i, onSurface)
    end
  end

  local nextMonth = os.time({ year = t.year, month = t.month + 1, day = 0 })
  local daysInMonth = os.date("*t", nextMonth).day
  local pct = math.floor((t.day / daysInMonth) * 100)
  local barW = math.max(12, math.floor((t.day / daysInMonth) * 224))
  local pctLabel = SKIN:GetVariable("LblMonthPct", (lang == "EN") and "of month" or "del mes")
  local suffix = "% " .. pctLabel

  -- Centros simétricos en tarjeta interna (X=14..268, ancho 254):
  -- Centros de columna: 39, 73, 107, 141, 175, 209, 243 (paso 34px, pill ancho 32px -> X = centro - 16)
  local pillX = 23 + (wdayMon - 1) * 34

  SKIN:Bang("!SetVariable", "MonthProgress", tostring(pct) .. suffix)
  SKIN:Bang("!SetVariable", "MonthBarW", tostring(barW))
  SKIN:Bang("!SetVariable", "TodayPillX", tostring(pillX))
end
