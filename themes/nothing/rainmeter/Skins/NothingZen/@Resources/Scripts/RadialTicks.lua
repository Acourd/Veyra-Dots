-- Circular Direct2D dial shared by the clock, volume control and focus timer.
local scale, cx, cy, outer, inner, major, tickCount
local tickMeter, handsMeter, mode, source, onColor, offColor, accent
local previousValue
local ticks = {}
local fullTurn = 2 * math.pi

local function point(fraction, radius)
    local angle = fraction * fullTurn - math.pi / 2
    return cx + radius * scale * math.cos(angle), cy + radius * scale * math.sin(angle)
end

local function line(x1, y1, x2, y2, width, color)
    return string.format('Line %.2f,%.2f,%.2f,%.2f | StrokeWidth %.2f | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
        x1, y1, x2, y2, width * scale, color)
end

function Initialize()
    scale = tonumber(SKIN:GetVariable('WidgetScale', '1')) or 1
    cx = (tonumber(SELF:GetOption('CenterX', '104')) or 104) * scale
    cy = (tonumber(SELF:GetOption('CenterY', '104')) or 104) * scale
    outer = tonumber(SELF:GetOption('RadiusOuter', '90')) or 90
    inner = tonumber(SELF:GetOption('RadiusInner', '82')) or 82
    major = tonumber(SELF:GetOption('RadiusMajor', '76')) or 76
    tickCount = tonumber(SELF:GetOption('Ticks', '60')) or 60
    tickMeter = SELF:GetOption('TargetMeter', 'MeterTicks')
    handsMeter = SELF:GetOption('HandsMeter', '')
    mode = SELF:GetOption('Mode', 'clock')
    source = SELF:GetOption('SourceMeasure', 'MeasureProgress')
    onColor = SKIN:GetVariable('OnSurface')
    offColor = SKIN:GetVariable('DotOff')
    accent = SKIN:GetVariable('Accent')

    for i = 0, tickCount - 1 do
        local isMajor = i % (tickCount / 12) == 0
        local x1, y1 = point(i / tickCount, isMajor and major or inner)
        local x2, y2 = point(i / tickCount, outer)
        local baseColor = mode == 'clock' and isMajor and onColor or offColor
        ticks[i] = {
            key = i == 0 and 'Shape' or 'Shape' .. (i + 1),
            off = line(x1, y1, x2, y2, isMajor and 1.8 or 1.25, baseColor),
            on = line(x1, y1, x2, y2, 2, onColor),
            marker = line(x1, y1, x2, y2, 2.8, accent),
        }
    end
end

local function style(i, value)
    if mode == 'clock' then return i == value and 'marker' or 'off' end
    if i == value - 1 then return 'marker' end
    return i < value and 'on' or 'off'
end

local function drawHands(now)
    if handsMeter == '' then return end
    local hx, hy = point((now.hour % 12 + now.min / 60) / 12, 45)
    local mx, my = point((now.min + now.sec / 60) / 60, 64)
    local sx, sy = point(now.sec / 60, 70)
    SKIN:Bang('!SetOption', handsMeter, 'Shape', line(cx, cy, hx, hy, 5, onColor))
    SKIN:Bang('!SetOption', handsMeter, 'Shape2', line(cx, cy, mx, my, 3, onColor))
    SKIN:Bang('!SetOption', handsMeter, 'Shape3', line(cx, cy, sx, sy, 1.8, accent))
    SKIN:Bang('!SetOption', handsMeter, 'Shape4', string.format(
        'Ellipse %.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0', cx, cy, 4.5 * scale, accent))
end

function Update()
    local value
    if mode == 'clock' then
        local now = os.date('*t')
        value = now.sec
        if value ~= previousValue then drawHands(now) end
    else
        local measure = SKIN:GetMeasure(source)
        local pct = math.max(0, math.min(100, measure and measure:GetValue() or 0))
        value = math.floor(pct * tickCount / 100 + 0.5)
    end
    if value == previousValue then return value end
    for i = 0, tickCount - 1 do
        local current = style(i, value)
        if previousValue == nil or style(i, previousValue) ~= current then
            local tick = ticks[i]
            SKIN:Bang('!SetOption', tickMeter, tick.key, tick[current])
        end
    end
    previousValue = value
    return value
end
