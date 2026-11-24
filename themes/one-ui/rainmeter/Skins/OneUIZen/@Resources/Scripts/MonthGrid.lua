-- OneUIZen MonthGrid.lua
-- Genera la cuadrícula mensual 6x7 estilo Samsung Calendar con resaltado exacto del día actual.

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
    and { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
    or  { "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" }

  SKIN:Bang("!SetVariable", "MonthTitle", months[t.month] .. " " .. t.year)
  for i = 1, 7 do
    SKIN:Bang("!SetVariable", "MHdr" .. i, dayHdr[i])
  end

  local firstTs = os.time({ year = t.year, month = t.month, day = 1 })
  local firstT = os.date("*t", firstTs)
  local startCol = (firstT.wday == 1) and 7 or (firstT.wday - 1)
  local lastTs = os.time({ year = t.year, month = t.month + 1, day = 0 })
  local totalDays = os.date("*t", lastTs).day

  local todayX = 148
  local todayY = 62

  for row = 0, 5 do
    for col = 1, 7 do
      local cell = row * 7 + col
      local dayNum = cell - startCol + 1
      if dayNum >= 1 and dayNum <= totalDays then
        local cx = 148 + (col - 1) * 30
        local cy = 62 + row * 22
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

  SKIN:Bang("!SetVariable", "TodayBoxX", tostring(todayX - 11))
  SKIN:Bang("!SetVariable", "TodayBoxY", tostring(todayY - 9))
end
