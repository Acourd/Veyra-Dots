-- A short reaction drill. Display time is rounded to the nearest 10 ms.
local face
local state = 'idle'
local activationAt, signalAt, best
local result = ''

local function draw()
    local labels = {
        idle = 'SigTry', wait = 'SigWait', go = 'SigNow',
        early = 'SigEarly', result = 'SigRetry', missed = 'SigMissed',
    }
    face:text('MeterAction', SKIN:GetVariable(labels[state]))
    local metric = SKIN:GetVariable('SigReaction')
    if state == 'result' then
        metric = result
    elseif best then
        metric = SKIN:GetVariable('SigBest') .. '  ' .. best .. ' MS'
    end
    face:text('MeterResult', metric)

    local shapes = {}
    for row = 0, 4 do
        for column = 0, 8 do
            local dx, dy = math.abs(column - 4), math.abs(row - 2)
            local color, radius = face.off, 1.55
            if state == 'go' and dx + dy <= 3 then color, radius = face.accent, 3.6
            elseif state == 'wait' and dx == 0 and dy == 0 then color, radius = face.accent, 3.6
            elseif state == 'early' and dx == dy then color, radius = face.accent, 3.1
            elseif (state == 'idle' or state == 'result' or state == 'missed') and dx + dy == 2 then
                color, radius = face.on, 2.8
            end
            shapes[#shapes + 1] = face:dot(54 + column * 14, 50 + row * 10, radius, color)
        end
    end
    face:draw('MeterPixels', shapes)
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    math.randomseed(os.time())
    draw()
end

function Update()
    local now = os.clock()
    if state == 'wait' and now >= activationAt then
        state, signalAt = 'go', now
        draw()
    elseif state == 'go' and now - signalAt > 3 then
        state = 'missed'
        draw()
    end
    return 0
end

function Press()
    local now = os.clock()
    if state == 'wait' then
        state = 'early'
    elseif state == 'go' then
        local milliseconds = math.max(10, math.floor((now - signalAt) * 100 + 0.5) * 10)
        best = best and math.min(best, milliseconds) or milliseconds
        result = milliseconds .. ' MS'
        state = 'result'
    else
        state, activationAt = 'wait', now + math.random(190, 370) / 100
    end
    draw()
    face:redraw()
end
