-- OneUIZen — Cassette.lua
-- Anima los dos carretes vectoriales del widget Retro Cassette cuando NowPlaying esta reproduciendo.

local angle = 0

function Initialize()
  DrawReels()
end

function Update()
  local mState = SKIN:GetMeasure("MeasureState")
  local playing = mState and (mState:GetValue() == 1) or false
  if playing then
    angle = (angle + 22) % 360
    DrawReels()
  end
  return 1
end

local function spokeCoords(cx, cy, rIn, rOut, deg)
  local rad = math.rad(deg)
  local x1 = math.floor(cx + rIn * math.cos(rad) + 0.5)
  local y1 = math.floor(cy + rIn * math.sin(rad) + 0.5)
  local x2 = math.floor(cx + rOut * math.cos(rad) + 0.5)
  local y2 = math.floor(cy + rOut * math.sin(rad) + 0.5)
  return x1, y1, x2, y2
end

function DrawReels()
  local col = SKIN:GetVariable("OnSurface", "248,250,252,255")
  local acc = SKIN:GetVariable("Accent", "59,130,246,255")
  local lx, ly = 112, 92
  local rx, ry = 236, 92

  local idx = 1
  for i = 0, 2 do
    local d = angle + i * 120
    local x1, y1, x2, y2 = spokeCoords(lx, ly, 6, 15, d)
    local k1 = (idx == 1) and "Shape" or ("Shape" .. idx)
    SKIN:Bang("!SetOption", "MeterReelSpokes", k1,
      string.format("Line %d,%d,%d,%d | StrokeWidth 2.4 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round", x1, y1, x2, y2, col))
    idx = idx + 1

    local rx1, ry1, rx2, ry2 = spokeCoords(rx, ry, 6, 15, d + 40)
    local k2 = "Shape" .. idx
    SKIN:Bang("!SetOption", "MeterReelSpokes", k2,
      string.format("Line %d,%d,%d,%d | StrokeWidth 2.4 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round", rx1, ry1, rx2, ry2, acc))
    idx = idx + 1
  end

  SKIN:Bang("!UpdateMeter", "MeterReelSpokes")
  SKIN:Bang("!Redraw")
end
