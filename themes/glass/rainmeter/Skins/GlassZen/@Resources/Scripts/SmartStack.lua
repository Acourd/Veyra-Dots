-- OneUIZen — SmartStack.lua
-- Gestiona el cambio interactivo entre 3 paginas del widget apilado One UI Smart Stack.

local page = 1
local totalPages = 3

function Initialize()
  ShowPage(1)
end

function Update()
  return 1
end

function Next()
  page = (page % totalPages) + 1
  ShowPage(page)
end

function Prev()
  page = ((page - 2) % totalPages) + 1
  ShowPage(page)
end

function ShowPage(p)
  page = p
  local accent = SKIN:GetVariable("Accent", "59,130,246,255")
  local muted = SKIN:GetVariable("Track", "38,42,54,255")

  for i = 1, totalPages do
    if i == page then
      SKIN:Bang("!ShowMeterGroup", "Page" .. i)
    else
      SKIN:Bang("!HideMeterGroup", "Page" .. i)
    end
  end

  -- 3 indicadores centrados horizontalmente en X=174 (card 4..344 -> center 174)
  local dotX = { 154, 174, 194 }
  for i = 1, totalPages do
    local k = (i == 1) and "Shape" or ("Shape" .. i)
    if i == page then
      SKIN:Bang("!SetOption", "MeterPageDots", k,
        string.format("Rectangle %d,168,16,6,3 | Fill Color %s | StrokeWidth 0", dotX[i] - 8, accent))
    else
      SKIN:Bang("!SetOption", "MeterPageDots", k,
        string.format("Ellipse %d,171,3 | Fill Color %s | StrokeWidth 0", dotX[i], muted))
    end
  end

  SKIN:Bang("!UpdateMeter", "MeterPageDots")
  SKIN:Bang("!Redraw")
end
