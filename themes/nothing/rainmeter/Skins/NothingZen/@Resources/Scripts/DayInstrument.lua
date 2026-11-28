local face
local startMinute, endMinute
local displayShift = false
local lastMinute

local function parseClock(value, fallback)
    local hour, minute = value:match('^(%d%d?):(%d%d)$')
    hour, minute = tonumber(hour), tonumber(minute)
    if hour and hour < 24 and minute < 60 then return hour * 60 + minute end
    return fallback
end

local function timeLabel(minute)
    return string.format('%02d:%02d', math.floor(minute / 60) % 24, minute % 60)
end

local function duration(minutes)
    return string.format('%d h %02d m', math.floor(minutes / 60), minutes % 60)
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    startMinute = parseClock(SKIN:GetVariable('ShiftStart', '09:00'), 540)
    endMinute = parseClock(SKIN:GetVariable('ShiftEnd', '18:00'), 1080)
    if startMinute == endMinute then startMinute, endMinute = 540, 1080 end
end

function Update()
    local now = os.date('*t')
    local minute = now.hour * 60 + now.min
    if lastMinute == minute then return minute end
    lastMinute = minute

    local start, length = 0, 1440
    local elapsed, remaining = minute, 1440 - minute
    local label = SKIN:GetVariable('SigUntilMidnight')
    if displayShift then
        start, length = startMinute, (endMinute - startMinute) % 1440
        local sinceStart = (minute - start) % 1440
        if sinceStart < length then
            elapsed, remaining = sinceStart, length - sinceStart
            label = SKIN:GetVariable('SigUntilShiftEnd')
        else
            elapsed, remaining = 0, (start - minute) % 1440
            label = SKIN:GetVariable('SigUntilShiftStart')
        end
    end

    face:text('MeterModeText', SKIN:GetVariable(displayShift and 'SigShift' or 'SigFullDay'))
    face:text('MeterRemaining', duration(remaining))
    face:text('MeterRemainingLabel', label)
    local ratio = elapsed / length
    local left, span, y = 30, 396, 120
    local shapes = {face:bar(left, y - 1, span, 2, face.off)}
    for i = 0, 24 do
        local major = i % 6 == 0
        local x = left + span * i / 24
        shapes[#shapes + 1] = face:line(x, y - (major and 7 or 3), x, y + 5,
            major and 1.6 or 1, i / 24 <= ratio and face.muted or face.off)
    end
    shapes[#shapes + 1] = face:bar(left, y - 1, math.max(0.1, span * ratio), 2, face.muted)
    shapes[#shapes + 1] = face:dot(left + span * ratio, y, 4.3, face.accent)
    face:draw('MeterTimeline', shapes)
    for i = 0, 4 do
        local value = math.floor(start + length * i / 4)
        face:text('MeterTime' .. i, displayShift and timeLabel(value) or string.format('%02d', i * 6))
    end
    return minute
end

function Toggle()
    displayShift = not displayShift
    lastMinute = nil
    Update()
    face:redraw()
end
