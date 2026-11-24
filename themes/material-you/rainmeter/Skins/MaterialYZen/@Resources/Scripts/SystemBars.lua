-- MaterialYZen SystemBars.lua
-- Dibuja 3 columnas de 10 segmentos redondeados usando porcentaje normalizado (GetRelativeValue) para CPU, RAM y Disco C:.

function Initialize()
  UpdateBars()
end

function Update()
  UpdateBars()
  return 1
end

function UpdateBars()
  local mCpu = SKIN:GetMeasure("MeasureCPU")
  local mRam = SKIN:GetMeasure("MeasureRAM")
  local mDisk = SKIN:GetMeasure("MeasureDiskPct")

  -- GetRelativeValue() devuelve siempre 0.0..1.0 tanto para CPU como para RAM y FreeDiskSpace (bytes)
  local cpu = mCpu and math.floor(mCpu:GetRelativeValue() * 100 + 0.5) or 0
  local ram = mRam and math.floor(mRam:GetRelativeValue() * 100 + 0.5) or 0
  local disk = mDisk and math.floor(mDisk:GetRelativeValue() * 100 + 0.5) or 0

  local primary = SKIN:GetVariable("Primary", "168,199,250,255")
  local dim = SKIN:GetVariable("SurfaceContainer", "29,36,48,245")

  local values = { cpu, ram, disk }
  local colX = { 21, 65, 109 }

  local idx = 1
  for c = 1, 3 do
    local pct = math.max(0, math.min(100, values[c]))
    local lit = math.floor((pct / 100) * 10 + 0.5)
    if pct > 0 and lit == 0 then lit = 1 end
    for seg = 1, 10 do
      local y = 116 - (seg - 1) * 9
      local color = (seg <= lit) and primary or dim
      local key = (idx == 1) and "Shape" or ("Shape" .. idx)
      SKIN:Bang("!SetOption", "MeterSegments", key,
        string.format("Rectangle %d,%d,28,6,3 | Fill Color %s | StrokeWidth 0", colX[c], y, color))
      idx = idx + 1
    end
  end

  SKIN:Bang("!UpdateMeter", "MeterSegments")
  SKIN:Bang("!Redraw")
end
