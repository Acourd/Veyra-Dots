local face
local notes = {}
local index = 1
local lastBody, lastHeading, lastCounter
local ansi = {}

-- The Lua bridge expects Windows ANSI. Map Latin-1 UTF-8 sequences used by existing notes.
for byte = 160, 255 do
    local lead, trail = byte < 192 and 194 or 195, byte < 192 and byte or byte - 64
    ansi[string.char(lead, trail)] = string.char(byte)
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
end

local function draw()
    index = math.max(1, math.min(index, #notes))
    local body = notes[index] or SKIN:GetVariable('LblReminderEmpty')
    local counter = string.format('%02d / %02d', notes[index] and index or 0, #notes)
    local heading = SKIN:GetVariable('LblReminders')
    if body ~= lastBody or counter ~= lastCounter or heading ~= lastHeading then
        face:text('MeterNote', body)
        face:text('MeterCounter', counter)
        face:text('MeterHeader', heading)
        lastBody, lastCounter, lastHeading = body, counter, heading
    end
end

function Update()
    notes = {}
    local file = io.open(SKIN:GetVariable('@') .. 'Reminders.txt', 'r')
    if file then
        for line in file:lines() do
            local note = line:gsub('^\239\187\191', ''):gsub('[\194\195][\128-\191]', ansi):match('^%s*(.-)%s*$')
            if note ~= '' then notes[#notes + 1] = note end
        end
        file:close()
    end
    draw()
    return #notes
end

function Page(delta)
    if #notes > 0 then index = (index - 1 + delta) % #notes + 1 end
    draw()
    face:redraw()
end
