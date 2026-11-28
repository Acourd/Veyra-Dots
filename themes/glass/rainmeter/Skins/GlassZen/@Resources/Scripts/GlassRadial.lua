-- GlassRadial.lua — Pure Direct2D Liquid Glass Arcs & Analog Dial Engine
-- Zero GDI+ Roundlines: razor-sharp anti-aliased Direct2D Meter=Shape arcs & hands

function Initialize()
    mode = SELF:GetOption('Mode', 'arc')
    cx = tonumber(SELF:GetOption('CenterX', '90')) or 90
    cy = tonumber(SELF:GetOption('CenterY', '90')) or 90
    radius = tonumber(SELF:GetOption('Radius', '62')) or 62
    strokeW = tonumber(SELF:GetOption('StrokeWidth', '8')) or 8
    meterName = SELF:GetOption('TargetMeter', 'MeterArc')
    measureName = SELF:GetOption('SourceMeasure', '')
    colorVar = SELF:GetOption('ColorVar', 'Accent')
    trackVar = SELF:GetOption('TrackVar', 'Track')
    tickCount = tonumber(SELF:GetOption('TickCount', '60')) or 60
end

local function fmt(n)
    return string.format('%.2f', n)
end

local function updateArc()
    local val = 0
    if measureName ~= '' then
        local m = SKIN:GetMeasure(measureName)
        if m then val = tonumber(m:GetValue()) or 0 end
    end
    local maxVal = tonumber(SELF:GetOption('MaxValue', '100')) or 100
    if maxVal <= 0 then maxVal = 100 end
    local pct = math.max(0, math.min(1, val / maxVal))

    local col = SKIN:GetVariable(colorVar, '56,189,248,255')
    local trk = SKIN:GetVariable(trackVar, '255,255,255,34')

    -- Base track ellipse
    SKIN:Bang('!SetOption', meterName, 'Shape',
        string.format('Ellipse %s,%s,%s | Fill Color 0,0,0,0 | StrokeWidth %s | Stroke Color %s',
            fmt(cx), fmt(cy), fmt(radius), fmt(strokeW), trk))

    -- Active arc via Direct2D Path
    if pct <= 0.004 then
        SKIN:Bang('!SetOption', meterName, 'Shape2', 'Ellipse 0,0,0 | Fill Color 0,0,0,0 | StrokeWidth 0')
        SKIN:Bang('!SetOption', meterName, 'Shape3', 'Ellipse 0,0,0 | Fill Color 0,0,0,0 | StrokeWidth 0')
    elseif pct >= 0.996 then
        SKIN:Bang('!SetOption', meterName, 'Shape2',
            string.format('Ellipse %s,%s,%s | Fill Color 0,0,0,0 | StrokeWidth %s | Stroke Color %s',
                fmt(cx), fmt(cy), fmt(radius), fmt(strokeW), col))
        SKIN:Bang('!SetOption', meterName, 'Shape3',
            string.format('Ellipse %s,%s,%s | Fill Color 255,255,255,230 | StrokeWidth 0',
                fmt(cx), fmt(cy - radius), fmt(math.max(2, strokeW * 0.32))))
    else
        local startAng = -math.pi / 2
        local sweep = pct * 2 * math.pi
        local endAng = startAng + sweep
        local sx = cx + radius * math.cos(startAng)
        local sy = cy + radius * math.sin(startAng)
        local ex = cx + radius * math.cos(endAng)
        local ey = cy + radius * math.sin(endAng)
        local largeArc = (sweep > math.pi) and 1 or 0
        local pathDef = string.format('%s,%s | ArcTo %s,%s,%s,%s,0,0,%d',
            fmt(sx), fmt(sy), fmt(ex), fmt(ey), fmt(radius), fmt(radius), largeArc)
        SKIN:Bang('!SetOption', meterName, 'ArcPath', pathDef)
        SKIN:Bang('!SetOption', meterName, 'Shape2',
            string.format('Path ArcPath | Fill Color 0,0,0,0 | StrokeWidth %s | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
                fmt(strokeW), col))
        -- Luminous specular tip dot
        SKIN:Bang('!SetOption', meterName, 'Shape3',
            string.format('Ellipse %s,%s,%s | Fill Color 255,255,255,235 | StrokeWidth 0',
                fmt(ex), fmt(ey), fmt(math.max(2, strokeW * 0.3))))
    end
    SKIN:Bang('!UpdateMeter', meterName)
    SKIN:Bang('!Redraw')
    return math.floor(pct * 100 + 0.5)
end

local function updateAnalog()
    local now = os.date('*t')
    local h = (now.hour % 12) + (now.min / 60.0)
    local m = now.min + (now.sec / 60.0)
    local s = now.sec

    local hAng = (h / 12.0) * 2 * math.pi - math.pi / 2
    local mAng = (m / 60.0) * 2 * math.pi - math.pi / 2
    local sAng = (s / 60.0) * 2 * math.pi - math.pi / 2

    local fg = SKIN:GetVariable('OnSurface', '248,251,255,255')
    local muted = SKIN:GetVariable('OnSurfaceMuted', '188,202,224,180')
    local acc = SKIN:GetVariable('Accent', '56,189,248,255')

    -- 12 crisp luminous hour ticks + 48 fine minute ticks (built once)
    if not ticksBuilt then
        ticksBuilt = true
        for i = 0, 59 do
            local a = (i / 60.0) * 2 * math.pi - math.pi / 2
            local isMajor = (i % 5 == 0)
            local rIn = isMajor and (radius - 11) or (radius - 6)
            local rOut = radius - 2
            local x1 = cx + math.cos(a) * rIn
            local y1 = cy + math.sin(a) * rIn
            local x2 = cx + math.cos(a) * rOut
            local y2 = cy + math.sin(a) * rOut
            local sw = isMajor and 2 or 1
            local c = isMajor and fg or muted
            local key = (i == 0) and 'Shape' or ('Shape' .. (i + 1))
            SKIN:Bang('!SetOption', 'MeterTicks', key,
                string.format('Line %s,%s,%s,%s | StrokeWidth %d | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
                    fmt(x1), fmt(y1), fmt(x2), fmt(y2), sw, c))
        end
        SKIN:Bang('!UpdateMeter', 'MeterTicks')
    end

    -- Hour, minute, second vector hands (Direct2D crisp lines)
    local hx, hy = cx + math.cos(hAng) * 38, cy + math.sin(hAng) * 38
    local mx, my = cx + math.cos(mAng) * 54, cy + math.sin(mAng) * 54
    local sx, sy = cx + math.cos(sAng) * 60, cy + math.sin(sAng) * 60
    local sbx, sby = cx - math.cos(sAng) * 12, cy - math.sin(sAng) * 12

    SKIN:Bang('!SetOption', meterName, 'Shape',
        string.format('Line %s,%s,%s,%s | StrokeWidth 4 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
            fmt(cx), fmt(cy), fmt(hx), fmt(hy), fg))
    SKIN:Bang('!SetOption', meterName, 'Shape2',
        string.format('Line %s,%s,%s,%s | StrokeWidth 3 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
            fmt(cx), fmt(cy), fmt(mx), fmt(my), fg))
    SKIN:Bang('!SetOption', meterName, 'Shape3',
        string.format('Line %s,%s,%s,%s | StrokeWidth 1 | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
            fmt(sbx), fmt(sby), fmt(sx), fmt(sy), acc))
    SKIN:Bang('!SetOption', meterName, 'Shape4',
        string.format('Ellipse %s,%s,4 | Fill Color %s | StrokeWidth 1 | Stroke Color 255,255,255,220',
            fmt(cx), fmt(cy), acc))
    SKIN:Bang('!UpdateMeter', meterName)
    SKIN:Bang('!Redraw')
    return s
end

function Update()
    if mode == 'analog' then
        return updateAnalog()
    else
        return updateArc()
    end
end
