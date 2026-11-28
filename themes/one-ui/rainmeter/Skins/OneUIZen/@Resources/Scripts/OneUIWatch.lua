-- OneUIWatch.lua — Crisp Direct2D Vector Hands for OneUIZen Analog Watch (0 Roundline)
function Initialize()
    cx = tonumber(SELF:GetOption('CenterX', '96')) or 96
    cy = tonumber(SELF:GetOption('CenterY', '96')) or 96
end

function Update()
    local now = os.date('*t')
    local fg = SKIN:GetVariable('OnSurface', '246,248,253,255')
    local acc = SKIN:GetVariable('Accent', '59,130,246,255')
    local coral = SKIN:GetVariable('SamsungCoral', '244,63,94,255')

    local h = (now.hour % 12) + (now.min / 60.0)
    local m = now.min + (now.sec / 60.0)
    local hA = (h / 12.0) * 2 * math.pi - math.pi / 2
    local mA = (m / 60.0) * 2 * math.pi - math.pi / 2
    local sA = (now.sec / 60.0) * 2 * math.pi - math.pi / 2

    local hx, hy = math.floor(cx + math.cos(hA) * 40 + 0.5), math.floor(cy + math.sin(hA) * 40 + 0.5)
    local mx, my = math.floor(cx + math.cos(mA) * 58 + 0.5), math.floor(cy + math.sin(mA) * 58 + 0.5)
    local sx, sy = math.floor(cx + math.cos(sA) * 66 + 0.5), math.floor(cy + math.sin(sA) * 66 + 0.5)

    SKIN:Bang('!SetOption', 'MeterHands', 'Shape',
        string.format('Line %d,%d,%d,%d | StrokeWidth 6 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round', cx, cy, hx, hy, fg))
    SKIN:Bang('!SetOption', 'MeterHands', 'Shape2',
        string.format('Line %d,%d,%d,%d | StrokeWidth 4 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round', cx, cy, mx, my, acc))
    SKIN:Bang('!SetOption', 'MeterHands', 'Shape3',
        string.format('Line %d,%d,%d,%d | StrokeWidth 2 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round', cx, cy, sx, sy, coral))
    SKIN:Bang('!SetOption', 'MeterHands', 'Shape4',
        string.format('Ellipse %d,%d,5 | Fill Color %s | StrokeWidth 0', cx, cy, acc))
    SKIN:Bang('!UpdateMeter', 'MeterHands')
    SKIN:Bang('!Redraw')
    return now.sec
end
