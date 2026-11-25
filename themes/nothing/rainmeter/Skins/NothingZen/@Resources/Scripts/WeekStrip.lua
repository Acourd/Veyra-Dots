-- OneUIZen WeekStrip.lua
-- Genera 5 días centrados en hoy (Ayer-1, Ayer, HOY, Mañana, Mañana+1) estilo One UI 7.

function Initialize()
  UpdateStrip()
end

function Update()
  UpdateStrip()
  return os.date("%d")
end

function UpdateStrip()
  local now = os.time()
  local t = os.date("*t", now)
  local lang = SKIN:GetVariable("Language", "ES")

  local wdays = (lang == "EN")
    and { "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" }
    or  { "DOM", "LUN", "MAR", "MIE", "JUE", "VIE", "SAB" }

  local months = (lang == "EN")
    and { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
    or  { "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" }

  SKIN:Bang("!SetVariable", "StripHeader", months[t.month] .. " " .. t.year)

  for i = 1, 5 do
    local offset = (i - 3) * 86400
    local dt = os.date("*t", now + offset)
    SKIN:Bang("!SetVariable", "WD" .. i, wdays[dt.wday])
    SKIN:Bang("!SetVariable", "DN" .. i, string.format("%02d", dt.day))
  end
end
