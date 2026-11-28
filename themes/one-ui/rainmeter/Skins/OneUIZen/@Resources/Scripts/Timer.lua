-- Both focus skins share the same timer and use the elapsed time on the system clock.
local totalSeconds, remaining
local deadline
local mode = 'FOCUS'
local slot = 0

local function sync()
    local lang = SKIN:GetVariable('Language', 'ES')
    local en = lang == 'EN'
    local status
    if remaining == 0 then
        status = en and 'DONE' or 'LISTO'
    elseif deadline then
        if mode == 'FOCUS' then
            status = en and 'FOCUSING' or 'ENFOCADO'
        else
            status = en and 'BREAK' or 'DESCANSO'
        end
    elseif remaining == totalSeconds then
        status = en and 'READY' or 'PREPARADO'
    else
        status = en and 'PAUSED' or 'PAUSADO'
    end
    SKIN:Bang('!SetVariable', 'TimerText', string.format('%02d:%02d', math.floor(remaining / 60), remaining % 60))
    SKIN:Bang('!SetVariable', 'TimerStatus', status)
    SKIN:Bang('!SetVariable', 'TimerRatio', string.format('%.4f', remaining / totalSeconds))
    SKIN:Bang('!SetVariable', 'TimerSlot', tostring(slot))
    SKIN:Bang('!SetVariable', 'TimerAction', deadline and (en and 'Pause' or 'Pausar') or (en and 'Start' or 'Iniciar'))
    if SKIN:GetMeasure('MeasureRatioCalc') then SKIN:Bang('!UpdateMeasure', 'MeasureRatioCalc') end
end

local function refresh()
    sync()
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
end

local function tick()
    if not deadline then return end
    remaining = math.max(0, deadline - os.time())
    if remaining == 0 then deadline = nil end
end

function Initialize()
    totalSeconds = math.max(1, tonumber(SELF:GetOption('DefaultSeconds', '1500')) or 1500)
    remaining = totalSeconds
    sync()
end

function Update()
    if deadline then
        tick()
        sync()
    end
    return remaining
end

function Toggle()
    if deadline then
        tick()
        deadline = nil
    else
        if remaining == 0 then remaining = totalSeconds end
        deadline = os.time() + remaining
    end
    refresh()
end

function Reset()
    deadline, remaining = nil, totalSeconds
    refresh()
end

function SetMinutes(minutes, newMode)
    minutes = math.max(1, tonumber(minutes) or 25)
    deadline, totalSeconds, mode = nil, minutes * 60, newMode or 'FOCUS'
    remaining = totalSeconds
    slot = minutes == 50 and 1 or (minutes == 10 and 2 or 0)
    refresh()
end
