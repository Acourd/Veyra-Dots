local face, left, right

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    left = SKIN:GetMeasure('MeasureLeft')
    right = SKIN:GetMeasure('MeasureRight')
end

function Update()
    local shapes = {}
    for side, measure in ipairs({left,right}) do
        local rms = measure:GetValue()
        local db = 20 * math.log10(math.max(0.001, math.min(1, rms)))
        local count = math.floor((db + 60) / 60 * 20 + 0.5)
        local y = side == 1 and 63 or 94
        for i = 1, 20 do
            shapes[#shapes + 1] = face:bar(44 + (i - 1) * 9.7, y - 5, 5.7, 10,
                i <= count and (i > 16 and face.accent or face.on) or face.off)
        end
        face:text(side == 1 and 'MeterLeftValue' or 'MeterRightValue',
            db <= -59.95 and '--' or string.format('%.0f dB', db))
    end
    face:draw('MeterTicks', shapes)
    return 0
end
