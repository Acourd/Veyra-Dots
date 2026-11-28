local face
local offset = 0
local previous
local monthNames = {
    ES = {'ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'},
    EN = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'},
}

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
end

function Update()
    local now = os.date('*t')
    local key = tostring(now.yday) .. ':' .. offset
    if previous == key then return now.day end
    previous = key
    local first = os.date('*t', os.time({year=now.year, month=now.month+offset, day=1, hour=12}))
    local last = os.date('*t', os.time({year=first.year, month=first.month+1, day=0, hour=12})).day
    local starts = (first.wday + 5) % 7
    local names = monthNames[SKIN:GetVariable('Language')] or monthNames.ES
    local visibleToday = offset == 0
    face:text('MeterMonth', string.format('%s %d', names[first.month], first.year))
    face:text('MeterBigDay', string.format('%02d', now.day))
    local active = starts + now.day - 1
    local x = 139 + (active % 7) * 30
    local y = 88 + math.floor(active / 7) * 22
    face:draw('MeterToday', {face:dot(x, y, 9.2, visibleToday and face.accent or '0,0,0,0')})
    for i = 0, 41 do
        local n = i - starts + 1
        local name = 'MeterCell' .. (i + 1)
        face:text(name, n >= 1 and n <= last and string.format('%02d', n) or ' ')
        SKIN:Bang('!SetOption', name, 'FontColor', visibleToday and i == active and SKIN:GetVariable('OnAccent') or face.on)
    end
    return now.day
end

function Move(delta)
    offset = math.max(-12, math.min(12, offset + delta))
    Update()
    face:redraw()
end

function Today()
    offset = 0
    Update()
    face:redraw()
end
