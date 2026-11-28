-- Bottom-up dot matrix for battery and CPU measures.
local cols, rows, startX, startY, stepX, stepY, radius
local meter, measureName, onColor, offColor, accent
local previousLit, previousHigh

function Initialize()
    local scale = tonumber(SKIN:GetVariable('WidgetScale', '1')) or 1
    cols = tonumber(SELF:GetOption('Cols', '10')) or 10
    rows = tonumber(SELF:GetOption('Rows', '5')) or 5
    startX = (tonumber(SELF:GetOption('StartX', '32')) or 32) * scale
    startY = (tonumber(SELF:GetOption('StartY', '57')) or 57) * scale
    stepX = (tonumber(SELF:GetOption('StepX', '16')) or 16) * scale
    stepY = (tonumber(SELF:GetOption('StepY', '16')) or 16) * scale
    radius = (tonumber(SELF:GetOption('DotRadius', '4')) or 4) * scale
    meter = SELF:GetOption('TargetMeter', 'MeterDotGrid')
    measureName = SELF:GetOption('SourceMeasure', 'MeasurePct')
    onColor = SKIN:GetVariable('OnSurface')
    offColor = SKIN:GetVariable('DotOff')
    accent = SKIN:GetVariable('Accent')
end

function Update()
    local measure = SKIN:GetMeasure(measureName)
    local pct = math.max(0, math.min(100, measure and measure:GetValue() or 0))
    local total = cols * rows
    local lit = math.floor(pct * total / 100 + 0.5)
    local high = pct >= 80
    if lit == previousLit and high == previousHigh then return pct end

    local accentStart = math.floor(total * 0.75)
    for index = 1, total do
        local x = startX + ((index - 1) % cols) * stepX
        local y = startY + (rows - 1 - math.floor((index - 1) / cols)) * stepY
        local color = offColor
        if index <= lit then
            color = high and index > accentStart and accent or onColor
        end
        local key = index == 1 and 'Shape' or 'Shape' .. index
        SKIN:Bang('!SetOption', meter, key, string.format(
            'Ellipse %.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0', x, y, radius, color))
    end
    previousLit, previousHigh = lit, high
    return pct
end
