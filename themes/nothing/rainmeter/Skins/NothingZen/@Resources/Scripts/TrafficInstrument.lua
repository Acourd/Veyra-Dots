local face, downMeasure, upMeasure
local samples = {}
local window = 30
local columns = 30
local rows = 5

local function rate(bytes)
    if bytes >= 1000000 then return string.format('%.1f MB/s', bytes / 1000000) end
    if bytes >= 1000 then return string.format('%.1f kB/s', bytes / 1000) end
    return string.format('%.0f B/s', bytes)
end

local function draw()
    local shapes = {}
    local sampleCount = #samples
    local peak = 0
    for i = math.max(1, sampleCount - window + 1), sampleCount do
        peak = math.max(peak, samples[i][1], samples[i][2])
    end
    for column = 1, columns do
        local offset = (columns - column) * (window / columns)
        local last = sampleCount - offset
        local values = {0, 0}
        for index = math.max(1, last - window / columns + 1), last do
            values[1] = math.max(values[1], samples[index][1])
            values[2] = math.max(values[2], samples[index][2])
        end
        local x = 38 + (column - 1) * 13.1
        for direction = 1, 2 do
            local fraction = values[direction] / math.max(peak, 1)
            local height = math.ceil(math.sqrt(fraction) * rows)
            local sign = direction == 1 and -1 or 1
            for row = 1, rows do
                local color = face.off
                if row <= height then
                    color = column == columns and face.accent or (direction == 1 and face.on or face.muted)
                end
                shapes[#shapes + 1] = face:dot(x, 112 + sign * (4 + row * 8), row <= height and 2.65 or 1.45, color)
            end
        end
    end
    face:draw('MeterHistory', shapes)
    local current = samples[sampleCount] or {0, 0}
    face:text('MeterDown', rate(current[1]))
    face:text('MeterUp', rate(current[2]))
    face:text('MeterRangeText', window .. ' S')
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    downMeasure = SKIN:GetMeasure('MeasureDown')
    upMeasure = SKIN:GetMeasure('MeasureUp')
end

function Update()
    samples[#samples + 1] = {math.max(0, downMeasure:GetValue()), math.max(0, upMeasure:GetValue())}
    if #samples > 60 then table.remove(samples, 1) end
    draw()
    return #samples
end

function ToggleWindow()
    window = window == 30 and 60 or 30
    draw()
    face:redraw()
end
