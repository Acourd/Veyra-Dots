local view, path
local counts = {0,0,0,0,0}
local today, recordOnly

function Initialize()
    view = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua').new(SKIN)
    path = SKIN:GetVariable('@') .. 'AIActivity.inc'
    recordOnly = SELF:GetOption('RecordOnly', '0') == '1'
end

local function load()
    today = os.date('%Y-%m-%d')
    local snapshot = SKIN:GetVariable('AiActivity', '')
    local file = io.open(path, 'rb')
    if file then
        snapshot = (file:read('*a') or ''):gsub('%z', ''):match('AiActivity=([^\r\n]+)') or snapshot
        file:close()
    end
    local day, p1, p2, p3, p4, p5 = snapshot:match('^(%d%d%d%d%-%d%d%-%d%d)|(%d+)|(%d+)|(%d+)|(%d+)|(%d+)$')
    counts = day == today and {tonumber(p1),tonumber(p2),tonumber(p3),tonumber(p4),tonumber(p5)} or {0,0,0,0,0}
end

local function draw()
    if recordOnly then return 0 end
    local total = 0
    for i = 1, 5 do
        view:label('MeterCount' .. i, tostring(counts[i]))
        total = total + counts[i]
    end
    view:label('MeterTotal', tostring(total) .. ' ' .. SKIN:GetVariable('UiAiLaunches'))
    return total
end

function Update()
    if recordOnly then return 0 end
    load()
    return draw()
end

function Record(slot)
    if slot < 1 or slot > 5 or slot % 1 ~= 0 then return end
    load()
    counts[slot] = math.min(9999, counts[slot] + 1)
    local snapshot = today .. '|' .. table.concat(counts,'|')
    SKIN:Bang('!WriteKeyValue','Variables','AiActivity',snapshot,path)
    draw()
    SKIN:Bang('!UpdateMeter','*')
    SKIN:Bang('!Redraw')
end
