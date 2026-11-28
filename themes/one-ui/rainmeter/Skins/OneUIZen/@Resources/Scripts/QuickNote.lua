local view
local notes, position = {}, 1
local latin = {}
for i = 160, 255 do
    local a, b = i < 192 and 194 or 195, i < 192 and i or i - 64
    latin[string.char(a,b)] = string.char(i)
end

function Initialize()
    view = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua').new(SKIN)
end

local function draw()
    position = math.max(1, math.min(position, #notes))
    view:label('MeterBody', notes[position] or SKIN:GetVariable('UiNoNotes'))
    view:label('MeterCount', string.format('%d / %d', #notes > 0 and position or 0, #notes))
end

function Update()
    notes = {}
    local file = io.open(SKIN:GetVariable('@') .. 'Reminders.txt', 'r')
    if file then
        for line in file:lines() do
            local text = line:gsub('^\239\187\191', ''):gsub('[\194\195][\128-\191]', latin):match('^%s*(.-)%s*$')
            if text ~= '' then notes[#notes + 1] = text end
        end
        file:close()
    end
    draw()
    return #notes
end

function Move(delta)
    if #notes > 0 then position = (position - 1 + delta) % #notes + 1 end
    draw()
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
end
