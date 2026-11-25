-- Veyra-Dots - SolarArc.lua
-- Calcula la posicion orbital en vivo del sol/luna a lo largo de un arco semicircular (06:00-20:00 dia, 20:00-06:00 noche).

function Initialize()
  UpdateSolar()
end

function Update()
  UpdateSolar()
  return 1
end

function UpdateSolar()
  local t = os.date("*t")
  local mins = t.hour * 60 + t.min
  local dayStart = 6 * 60   -- 06:00
  local dayEnd = 20 * 60    -- 20:00
  local isDay = (mins >= dayStart and mins <= dayEnd)

  local progress = 0
  if isDay then
    progress = (mins - dayStart) / (dayEnd - dayStart)
  else
    local nightMins = (mins > dayEnd) and (mins - dayEnd) or (mins + (24 * 60 - dayEnd))
    progress = nightMins / (10 * 60)
  end
  progress = math.max(0, math.min(1, progress))

  local cx = tonumber(SKIN:GetVariable("ArcCenterX", "172")) or 172
  local cy = tonumber(SKIN:GetVariable("ArcCenterY", "118")) or 118
  local r = tonumber(SKIN:GetVariable("ArcRadius", "92")) or 92

  -- Angulo de izquierda (pi) a derecha (0) sobre el semicirculo superior
  local theta = math.pi * (1 - progress)
  local ox = math.floor(cx + r * math.cos(theta) + 0.5)
  local oy = math.floor(cy - r * math.sin(theta) + 0.5)

  local sunCol = SKIN:GetVariable("SolarOrbDay", "255,193,7,255")
  local moonCol = SKIN:GetVariable("SolarOrbNight", SKIN:GetVariable("Primary", SKIN:GetVariable("Accent", "168,199,250,255")))
  local glowCol = isDay and SKIN:GetVariable("SolarGlowDay", "255,193,7,70") or SKIN:GetVariable("SolarGlowNight", "168,199,250,60")
  local orbCol = isDay and sunCol or moonCol

  SKIN:Bang("!SetOption", "MeterSolarOrb", "Shape",
    string.format("Ellipse %d,%d,13 | Fill Color %s | StrokeWidth 0", ox, oy, glowCol))
  SKIN:Bang("!SetOption", "MeterSolarOrb", "Shape2",
    string.format("Ellipse %d,%d,7.5 | Fill Color %s | StrokeWidth 0", ox, oy, orbCol))
  SKIN:Bang("!UpdateMeter", "MeterSolarOrb")

  local dayPct = math.floor((mins / 1440) * 100 + 0.5)
  local lblPhase = isDay and SKIN:GetVariable("LblDaylight", "Luz del d\237a") or SKIN:GetVariable("LblNight", "Noche")
  SKIN:Bang("!SetOption", "MeterSolarPhase", "Text", string.format("%s - %d%%", lblPhase, dayPct))
  SKIN:Bang("!UpdateMeter", "MeterSolarPhase")
  SKIN:Bang("!Redraw")
end
