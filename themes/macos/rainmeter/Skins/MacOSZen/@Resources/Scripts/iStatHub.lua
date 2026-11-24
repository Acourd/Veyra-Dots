-- MacOSZen — iStatHub.lua
-- Historial CPU de 16 muestras en vivo estilo iStat Menus / Stats para macOS Sequoia.

local samples = 16
local hist = {}

function Initialize()
  for i = 1, samples do hist[i] = 6 end
  Render()
end

function Update()
  local m = SKIN:GetMeasure("MeasureCpu")
  local v = m and m:GetValue() or 0
  table.remove(hist, 1)
  table.insert(hist, math.max(0, math.min(100, v)))
  Render()
  return 1
end

function Render()
  local x0 = tonumber(SKIN:GetVariable("GraphX", "22")) or 22
  local yBase = tonumber(SKIN:GetVariable("GraphBaseY", "106")) or 106
  local maxH = tonumber(SKIN:GetVariable("GraphH", "46")) or 46
  local step = tonumber(SKIN:GetVariable("GraphStep", "10")) or 10
  local barW = tonumber(SKIN:GetVariable("GraphBarW", "6")) or 6
  local lowCol = SKIN:GetVariable("MacTeal", "64,200,224,255")
  local midCol = SKIN:GetVariable("MacOrange", "255,159,10,255")
  local highCol = SKIN:GetVariable("MacPink", "255,55,95,255")

  for i = 1, samples do
    local v = hist[i]
    local h = math.max(4, math.floor((v / 100) * maxH + 0.5))
    local col = lowCol
    if v >= 75 then col = highCol elseif v >= 45 then col = midCol end
    local k = (i == 1) and "Shape" or ("Shape" .. i)
    SKIN:Bang("!SetOption", "MeterCpuGraph", k,
      string.format("Rectangle %d,%d,%d,%d,2.5 | Fill Color %s | StrokeWidth 0", x0 + (i - 1) * step, yBase - h, barW, h, col))
  end

  SKIN:Bang("!UpdateMeter", "MeterCpuGraph")
  SKIN:Bang("!Redraw")
end
