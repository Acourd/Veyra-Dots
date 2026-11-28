local view, previousMinute
local slots = 3

function Initialize()
    view = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua').new(SKIN)
end

function Update()
    local now = os.time()
    local minute = math.floor(now / 60)
    if minute == previousMinute then return 0 end
    previousMinute = minute
    local localTime = os.date('*t', now)
    local endOfWindow = os.time({year=localTime.year,month=localTime.month,day=localTime.day+7,hour=0})
    local today = os.date('%Y-%m-%d', now)
    local lastDate = os.date('%Y-%m-%d', endOfWindow)
    for i = 1, 7 do
        local stamp = os.date('*t', os.time({year=localTime.year,month=localTime.month,day=localTime.day+i-1,hour=12}))
        view:label('MeterWeekDay' .. i, SKIN:GetVariable('UiAgendaWeek' .. stamp.wday, ''))
        view:label('MeterWeekNum' .. i, tostring(stamp.day))
    end

    local events = {}
    for i = 1, 8 do
        local item = SKIN:GetVariable('Event' .. i, '')
        local date, time, title = item:match('^(%d%d%d%d%-%d%d%-%d%d)|(%d%d:%d%d)|(.+)$')
        if date and date >= today and date < lastDate then
            local y, m, d = date:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
            local h, min = time:match('^(%d%d):(%d%d)$')
            local timestamp = os.time({year=tonumber(y),month=tonumber(m),day=tonumber(d),hour=tonumber(h),min=tonumber(min)})
            if timestamp and timestamp >= minute * 60 and timestamp < endOfWindow and os.date('%Y-%m-%d|%H:%M',timestamp) == date .. '|' .. time then
                events[#events+1] = {date=date,time=time,title=title,stamp=timestamp}
            end
        end
    end
    table.sort(events,function(a,b) return a.stamp < b.stamp end)
    local visible = math.min(slots, #events)
    local height = math.max(176, 122 + 40 * visible)
    view:set('MeterCard','H',tostring(height))
    view:set('MeterCard','Shape',string.format('Rectangle 2,2,302,%d,28 | Fill Color %s | StrokeWidth 1 | Stroke Color %s',
        height - 4, view:color('Surface'), view:color('Border')))
    view:set('MeterEmpty','Hidden',#events == 0 and '0' or '1')
    view:set('MeterEmptyDetail','Hidden',#events == 0 and '0' or '1')
    for i = 1, slots do
        local event = events[i]
        view:label('MeterEvent' .. i, event and event.title or ' ')
        view:label('MeterDay' .. i, event and
            (event.date == today and SKIN:GetVariable('UiToday') or os.date('%d/%m',event.stamp)) or ' ')
        view:label('MeterHour' .. i, event and event.time or ' ')
        for _, meter in ipairs({'MeterRow', 'MeterEvent', 'MeterDay', 'MeterHour'}) do
            view:set(meter .. i,'Hidden',event and '0' or '1')
        end
    end
    SKIN:Bang('!Redraw')
    return #events
end
