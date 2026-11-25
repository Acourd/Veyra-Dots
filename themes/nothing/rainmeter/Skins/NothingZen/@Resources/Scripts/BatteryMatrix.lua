-- MaterialYZen BatteryMatrix.lua
-- Genera dinámicamente una matriz de 50 puntos (10x5) donde cada punto equivale al 2% de batería.

function Initialize()
  UpdateMatrix()
end

function Update()
  UpdateMatrix()
  return 1
end

function UpdateMatrix()
  local pctMeasure = SKIN:GetMeasure("MeasurePercent")
  local pct = pctMeasure and math.floor(pctMeasure:GetValue() + 0.5) or 0
  local litCount = math.floor(pct / 2)
  if pct > 0 and litCount == 0 then litCount = 1 end

  local primary = SKIN:GetVariable("Primary", "168,199,250,255")
  local dim = SKIN:GetVariable("SurfaceContainer", "29,36,48,245")

  -- 5 filas x 10 columnas = 50 puntos
  for row = 0, 4 do
    for col = 0, 9 do
      local idx = row * 10 + col + 1
      local color = (idx <= litCount) and primary or dim
      local cx = 24 + col * 16
      local cy = 81 + row * 16
      local shapeKey = (idx == 1) and "Shape" or ("Shape" .. idx)
      SKIN:Bang("!SetOption", "MeterDots", shapeKey,
        string.format("Ellipse %d,%d,5 | Fill Color %s | StrokeWidth 0", cx, cy, color))
    end
  end

  SKIN:Bang("!UpdateMeter", "MeterDots")
  SKIN:Bang("!Redraw")
end
