-- Veyra-Dots - DotClock.lua
-- Renderiza dígitos reales LED de matriz de puntos 5x7 estilo Nothing OS (HH:MM).

local glyphs = {
  ["0"] = { "01110", "10001", "10011", "10101", "11001", "10001", "01110" },
  ["1"] = { "00100", "01100", "00100", "00100", "00100", "00100", "01110" },
  ["2"] = { "01110", "10001", "00001", "00110", "01000", "10000", "11111" },
  ["3"] = { "11110", "00001", "00001", "01110", "00001", "00001", "11110" },
  ["4"] = { "00010", "00110", "01010", "10010", "11111", "00010", "00010" },
  ["5"] = { "11111", "10000", "10000", "11110", "00001", "00001", "11110" },
  ["6"] = { "01110", "10000", "10000", "11110", "10001", "10001", "01110" },
  ["7"] = { "11111", "00001", "00010", "00100", "01000", "01000", "01000" },
  ["8"] = { "01110", "10001", "10001", "01110", "10001", "10001", "01110" },
  ["9"] = { "01110", "10001", "10001", "01111", "00001", "00001", "01110" }
}

local lastKey = ""

function Initialize()
  Render(true)
end

function Update()
  Render(false)
  return 1
end

function Render(force)
  local fmt = SKIN:GetVariable("HourFormat", "%H")
  local t = os.date("*t")
  local h = t.hour
  if fmt == "%I" then
    h = h % 12
    if h == 0 then h = 12 end
  end
  local str = string.format("%02d%02d", h, t.min)
  local blink = (t.sec % 2 == 0) and 1 or 0
  local key = str .. "_" .. blink
  if not force and key == lastKey then return end
  lastKey = key

  local onCol = SKIN:GetVariable("DotOn", SKIN:GetVariable("OnSurface", "245,245,247,255"))
  local offCol = SKIN:GetVariable("DotOff", "46,49,56,255")
  local accCol = SKIN:GetVariable("Accent", "215,25,33,255")
  local startX = tonumber(SKIN:GetVariable("DotStartX", "24")) or 24
  local startY = tonumber(SKIN:GetVariable("DotStartY", "46")) or 46
  local step = tonumber(SKIN:GetVariable("DotStep", "9")) or 9
  local r = tonumber(SKIN:GetVariable("DotRadius", "3.4")) or 3.4

  local digitOffsets = { 0, 56, 134, 190 }
  local sIdx = 1

  for d = 1, 4 do
    local ch = string.sub(str, d, d)
    local g = glyphs[ch] or glyphs["0"]
    local dx = startX + digitOffsets[d]
    for row = 1, 7 do
      local line = g[row]
      for col = 1, 5 do
        local lit = (string.sub(line, col, col) == "1")
        local colStr = lit and onCol or offCol
        local cx = dx + (col - 1) * step
        local cy = startY + (row - 1) * step
        local sName = (sIdx == 1) and "Shape" or ("Shape" .. sIdx)
        SKIN:Bang("!SetOption", "MeterDotGrid", sName,
          string.format("Ellipse %d,%d,%.1f | Fill Color %s | StrokeWidth 0", cx, cy, r, colStr))
        sIdx = sIdx + 1
      end
    end
  end

  -- Dos puntos parpadeantes en rojo/acento Nothing
  local colonX = startX + 112
  local cCol = (blink == 1) and accCol or offCol
  for _, row in ipairs({ 3, 5 }) do
    local cy = startY + (row - 1) * step
    local sName = "Shape" .. sIdx
    SKIN:Bang("!SetOption", "MeterDotGrid", sName,
      string.format("Ellipse %d,%d,%.1f | Fill Color %s | StrokeWidth 0", colonX, cy, r + 0.3, cCol))
    sIdx = sIdx + 1
  end

  SKIN:Bang("!UpdateMeter", "MeterDotGrid")
  SKIN:Bang("!Redraw")
end
