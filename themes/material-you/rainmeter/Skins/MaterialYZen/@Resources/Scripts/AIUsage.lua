-- Veyra-Dots — AIUsage.lua
-- Controla el porcentaje de consumo de IA (ChatGPT, Claude, Gemini, Grok) con persistencia en AIUsage.inc, barras semanticas y cuota total.

local keys = { "PctChatGPT", "PctClaude", "PctGemini", "PctGrok" }
local vals = { PctChatGPT = 35, PctClaude = 45, PctGemini = 25, PctGrok = 15 }

function Initialize()
  for _, k in ipairs(keys) do
    local v = tonumber(SKIN:GetVariable(k, "0")) or 0
    vals[k] = math.max(0, math.min(100, math.floor(v + 0.5)))
  end
  Render()
end

function Update()
  return 1
end

function Add(key, delta)
  if vals[key] == nil then return end
  local d = tonumber(delta) or 0
  vals[key] = math.max(0, math.min(100, vals[key] + d))
  SKIN:Bang("!WriteKeyValue", "Variables", key, tostring(vals[key]), SKIN:GetVariable("@") .. "AIUsage.inc")
  Render()
end

function ResetAll()
  local inc = SKIN:GetVariable("@") .. "AIUsage.inc"
  for _, k in ipairs(keys) do
    vals[k] = 0
    SKIN:Bang("!WriteKeyValue", "Variables", k, "0", inc)
  end
  Render()
end

function Render()
  local accent = SKIN:GetVariable("AiAccent", SKIN:GetVariable("Primary", SKIN:GetVariable("Accent", "59,130,246,255")))
  local warnCol = SKIN:GetVariable("AiWarnColor", "249,115,22,255")
  local critCol = SKIN:GetVariable("AiCritColor", "244,63,94,255")
  local trackCol = SKIN:GetVariable("AiTrackColor", SKIN:GetVariable("Track", SKIN:GetVariable("SurfaceContainer", "42,46,58,255")))
  local barX = tonumber(SKIN:GetVariable("AiBarX", "68")) or 68
  local barW = tonumber(SKIN:GetVariable("AiBarW", "192")) or 192

  local sum = 0
  for i, k in ipairs(keys) do
    local pct = vals[k]
    sum = sum + pct
    local rowY = tonumber(SKIN:GetVariable("AiRowY" .. i, tostring(76 + (i - 1) * 40))) or (76 + (i - 1) * 40)
    local fillW = (pct <= 0) and 0 or math.max(8, math.floor((pct / 100) * barW + 0.5))
    local col = accent
    if pct >= 90 then
      col = critCol
    elseif pct >= 75 then
      col = warnCol
    end

    SKIN:Bang("!SetOption", "MeterAiPct" .. i, "Text", pct .. "%")
    SKIN:Bang("!SetOption", "MeterAiPct" .. i, "FontColor", col)
    SKIN:Bang("!SetOption", "MeterAiBar" .. i, "Shape",
      string.format("Rectangle %d,%d,%d,7,3.5 | Fill Color %s | StrokeWidth 0", barX, rowY + 18, barW, trackCol))
    SKIN:Bang("!SetOption", "MeterAiBar" .. i, "Shape2",
      string.format("Rectangle %d,%d,%d,7,3.5 | Fill Color %s | StrokeWidth 0", barX, rowY + 18, fillW, col))
    SKIN:Bang("!UpdateMeter", "MeterAiPct" .. i)
    SKIN:Bang("!UpdateMeter", "MeterAiBar" .. i)
  end

  local avg = math.floor((sum / 4) + 0.5)
  local totCol = SKIN:GetVariable("AiTotalColor", SKIN:GetVariable("OnPrimaryContainer", accent))
  if avg >= 90 then totCol = critCol elseif avg >= 75 then totCol = warnCol end
  SKIN:Bang("!SetOption", "MeterAiTotalPct", "Text", avg .. "%")
  SKIN:Bang("!SetOption", "MeterAiTotalPct", "FontColor", totCol)
  SKIN:Bang("!UpdateMeter", "MeterAiTotalPct")
  SKIN:Bang("!Redraw")
end
