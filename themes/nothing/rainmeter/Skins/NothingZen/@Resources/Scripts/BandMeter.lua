-- A bounded raster-free scale used for charge, storage, playback and the focus timeline.
local face, source, count, x, y, width, height, gap, reverse, corner

local function option(name, fallback)
    return tonumber(SELF:GetOption(name, tostring(fallback))) or fallback
end

local function value(measure)
    return math.max(0, math.min(100, measure:GetValue()))
end

local function bars(shapes, percent, baseline)
    local lit = math.floor(percent * count / 100 + 0.5)
    local pitch = width / count
    for i = 1, count do
        local active = reverse and i > count - lit or not reverse and i <= lit
        local tip = reverse and i == count - lit + 1 or not reverse and i == lit
        local color = active and (tip and face.accent or face.on) or face.off
        shapes[#shapes + 1] = face:bar(x + (i - 1) * pitch, baseline, pitch - gap, height, color, corner)
    end
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    source = SKIN:GetMeasure(SELF:GetOption('SourceMeasure', 'MeasureProgress'))
    count, x, y = option('Cells', 24), option('Left', 24), option('Top', 66)
    width, height, gap = option('Span', 272), option('CellHeight', 10), option('Gap', 3)
    reverse = option('Reverse', 0) == 1
    corner = option('Corner', math.min(width / count - gap, height) / 2)
end

function Update()
    local shapes = {}
    local percent = value(source)
    bars(shapes, percent, y)
    face:draw('MeterTicks', shapes)
    return percent
end
