-- MaterialYZen MonthGrid.lua
-- Genera la cuadrícula mensual completa (6 filas x 7 columnas) en ES o EN y resalta el día actual.

function Initialize()
  BuildMonth()
end

function Update()
  BuildMonth()
  return os.date("%d")
end

function BuildMonth()
  local now = os.time()
  local t = os.date("*t", now)
  local lang = SKIN:GetVariable("Language", "ES")

  local dayHdr = (lang == "EN")
    and { "M", "T", "W", "T", "F", "S", "S" }
    or  { "L", "M", "X", "J", "V", "S", "D" }

  local months = (lang == "EN")
    and { "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER" }
    or  { "ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE" }

  SKIN:Bang("!SetVariable", "MonthTitle", months[t.month] .. " " .. t.year)
  for i = 1, 7 do
    SKIN:Bang("!SetVariable", "MHdr" .. i, dayHdr[i])
  end

  local firstTs = os.time({ year = t.year, month = t.month, day = 1 })
  local firstT = os.date("*t", firstTs)
  local startCol = (firstT.wday == 1) and 7 or (firstT.wday - 1) -- 1=Lun..7=Dom

  local lastTs = os.time({ year = t.year, month = t.month + 1, day = 0 })
  local totalDays = os.date("*t", lastTs).day

  local todayX = 163
  local todayY = 68

  for row = 0, 5 do
    local rowStr = {}
    for col = 1, 7 do
      local cell = row * 7 + col
      local dayNum = cell - startCol + 1
      if dayNum >= 1 and dayNum <= totalDays then
        local cx = 163 + (col - 1) * 32
        local cy = 68 + row * 22
        if dayNum == t.day then
          todayX = cx
          todayY = cy
        end
        SKIN:Bang("!SetVariable", "C" .. cell, tostring(dayNum))
      else
        SKIN:Bang("!SetVariable", "C" .. cell, "")
      end
    end
  end

  SKIN:Bang("!SetVariable", "TodayCircleX", tostring(todayX))
  SKIN:Bang("!SetVariable", "TodayCircleY", tostring(todayY))
end
