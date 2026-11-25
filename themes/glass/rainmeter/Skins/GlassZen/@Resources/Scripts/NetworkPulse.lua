-- Veyra-Dots — NetworkPulse.lua
-- Sparkline dual en vivo (16 muestras de Bajada/Subida) para widgets de telemetria de red.

local samples = 16
local downHist = {}
local upHist = {}
local peak = 102400 -- 100 KB/s piso inicial dinamico

function Initialize()
  for i = 1, samples do
    downHist[i] = 0
    upHist[i] = 0
  end
  Render()
end

function Update()
  local mIn = SKIN:GetMeasure("MeasureNetIn")
  local mOut = SKIN:GetMeasure("MeasureNetOut")
  local vIn = mIn and mIn:GetValue() or 0
  local vOut = mOut and mOut:GetValue() or 0

  table.remove(downHist, 1)
  table.insert(downHist, vIn)
  table.remove(upHist, 1)
  table.insert(upHist, vOut)

  local maxV = 102400
  for i = 1, samples do
    if downHist[i] > maxV then maxV = downHist[i] end
    if upHist[i] > maxV then maxV = upHist[i] end
  end
  peak = maxV

  Render()
  return 1
end

function Render()
  local x0 = tonumber(SKIN:GetVariable("NetGraphX", "24")) or 24
  local yBase = tonumber(SKIN:GetVariable("NetGraphBaseY", "124")) or 124
  local maxH = tonumber(SKIN:GetVariable("NetGraphH", "54")) or 54
  local step = tonumber(SKIN:GetVariable("NetGraphStep", "18")) or 18
  local barW = tonumber(SKIN:GetVariable("NetGraphBarW", "6")) or 6
  local downCol = SKIN:GetVariable("NetDownColor", SKIN:GetVariable("Primary", SKIN:GetVariable("Accent", "59,130,246,255")))
  local upCol = SKIN:GetVariable("NetUpColor", SKIN:GetVariable("Secondary", "139,92,246,255"))
  local trackCol = SKIN:GetVariable("NetTrackColor", SKIN:GetVariable("Track", SKIN:GetVariable("SurfaceContainer", "42,46,58,255")))

  local idx = 1
  for i = 1, samples do
    local x = x0 + (i - 1) * step
    local hD = math.max(4, math.floor((downHist[i] / peak) * maxH + 0.5))
    local hU = math.max(4, math.floor((upHist[i] / peak) * maxH + 0.5))

    local k1 = (idx == 1) and "Shape" or ("Shape" .. idx)
    local colD = (downHist[i] > 512) and downCol or trackCol
    SKIN:Bang("!SetOption", "MeterNetGraph", k1,
      string.format("Rectangle %d,%d,%d,%d,3 | Fill Color %s | StrokeWidth 0", x, yBase - hD, barW, hD, colD))
    idx = idx + 1

    local k2 = "Shape" .. idx
    local colU = (upHist[i] > 512) and upCol or trackCol
    SKIN:Bang("!SetOption", "MeterNetGraph", k2,
      string.format("Rectangle %d,%d,%d,%d,3 | Fill Color %s | StrokeWidth 0", x + barW + 2, yBase - hU, barW, hU, colU))
    idx = idx + 1
  end

  SKIN:Bang("!UpdateMeter", "MeterNetGraph")
  SKIN:Bang("!Redraw")
end
