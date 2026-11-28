-- OneUIDaysLeft.lua — Days Remaining Engine for OneUIZen CountdownCard
function Update()
    local target = SKIN:GetVariable('CountdownDate', '2026-12-31')
    local y, m, d = target:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
    if not y then return 0 end
    local tTarget = os.time({year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 0})
    local now = os.date('*t')
    local tNow = os.time({year = now.year, month = now.month, day = now.day, hour = 0})
    local diff = math.max(0, math.floor((tTarget - tNow) / 86400 + 0.5))
    SKIN:Bang('!SetOption', 'MeterDays', 'Text', tostring(diff))
    SKIN:Bang('!UpdateMeter', 'MeterDays')
    SKIN:Bang('!Redraw')
    return diff
end
