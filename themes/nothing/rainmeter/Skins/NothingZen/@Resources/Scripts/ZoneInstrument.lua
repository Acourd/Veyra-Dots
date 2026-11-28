local face
local localTime, remoteTime
local previous

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    localTime = SKIN:GetMeasure('MeasureLocalHours')
    remoteTime = SKIN:GetMeasure('MeasureRemoteHours')
end

function Update()
    local a, b = tonumber(localTime:GetStringValue()), tonumber(remoteTime:GetStringValue())
    if not a or not b then return 0 end
    local key = a * 10000 + b
    if previous == key then return 0 end
    previous = key
    local shapes = {}
    for i, clock in ipairs({a, b}) do
        local row = i == 1 and 48 or 103
        for hour = 0, 23 do
            local color = hour >= 6 and hour < 18 and face.muted or face.off
            shapes[#shapes + 1] = face:dot(154 + hour * 6, row, 1.8, color)
        end
        local fraction = math.floor(clock / 100) + (clock % 100) / 60
        local x = 154 + fraction * 6
        shapes[#shapes + 1] = face:line(x, row - 4, x, row + 4, 2, face.accent)
    end
    face:draw('MeterZoneTracks', shapes)
    return 0
end
