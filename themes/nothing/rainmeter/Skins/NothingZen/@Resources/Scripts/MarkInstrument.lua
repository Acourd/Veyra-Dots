local face, storage, paper
local history = {}
local displayedDate

local function dateKey(timestamp)
    return os.date('%Y-%m-%d', timestamp)
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    paper = SKIN:GetVariable('SurfaceElevated')
    storage = SKIN:GetVariable('@') .. 'SignalState.inc'
    for day in SKIN:GetVariable('MarkedDays', ''):gmatch('%d%d%d%d%-%d%d%-%d%d') do
        history[day] = true
    end
end

function Update()
    local now = os.date('*t')
    local today = dateKey()
    if today == displayedDate then return 0 end
    displayedDate = today

    local shapes = {}
    local count = 0
    for i = 1, 7 do
        local day = os.time({year = now.year, month = now.month, day = now.day + i - 7, hour = 12})
        local marked = history[dateKey(day)]
        if marked then count = count + 1 end
        local x = 34 + (i - 1) * 42
        local ink = marked and (i == 7 and face.accent or face.on) or '0,0,0,0'
        shapes[#shapes + 1] = face:bar(x - 16, 62, 32, 37, paper, 5)
        shapes[#shapes + 1] = face:line(x - 13, 96, x + 13, 96, 1.2, i == 7 and face.accent or face.off)
        shapes[#shapes + 1] = face:line(x - 4, 71, x - 1, 74, 1.5, ink)
        shapes[#shapes + 1] = face:line(x - 1, 74, x + 5, 68, 1.5, ink)
        face:text('MeterDay' .. i, os.date('%d', day))
    end
    face:draw('MeterStamps', shapes)
    face:text('MeterCount', string.format('%d / 7', count))
    face:text('MeterStampText', SKIN:GetVariable(history[today] and 'SigUnmark' or 'SigMark'))
    return count
end

function ToggleToday()
    local key = dateKey()
    history[key] = not history[key]
    local dates = {}
    for date, marked in pairs(history) do
        if marked then dates[#dates + 1] = date end
    end
    table.sort(dates)
    local first = math.max(1, #dates - 30)
    SKIN:Bang('!WriteKeyValue', 'Variables', 'MarkedDays', table.concat(dates, ',', first), storage)
    displayedDate = nil
    Update()
    face:redraw()
end
