local view, day
local bits

local function today()
    return os.date('%Y-%m-%d')
end

local function save()
    SKIN:Bang('!WriteKeyValue', 'Variables', 'HabitRecord', day .. '|' .. bits,
        SKIN:GetVariable('@') .. 'Habits.inc')
end

local function rollDay()
    local current = today()
    if current == day then return false end
    day, bits = current, '0000'
    save()
    return true
end

local function draw()
    local done = 0
    for i = 1, 4 do
        local checked = bits:sub(i, i) == '1'
        if checked then done = done + 1 end
        local name = 'MeterCheck' .. i
        view:set('MeterTile' .. i, 'Shape', 'Rectangle 0,0,130,44,15 | StrokeWidth 0 | Fill Color ' ..
            view:color(checked and 'Track' or 'SurfaceElevated'))
        view:set(name, 'Shape', 'Ellipse 10,10,7 | StrokeWidth 1 | Fill Color 0,0,0,0 | Stroke Color ' ..
            view:color(checked and 'FinderGlyph' or 'OnSurfaceMuted'))
        view:set(name, 'Shape2', checked and
            ('Path Checkmark | StrokeWidth 2 | StrokeStartCap Round | StrokeEndCap Round | StrokeLineJoin Round | Stroke Color ' ..
                view:color('FinderGlyph')) or 'Line 0,0,1,0 | StrokeWidth 0')
        view:set(name, 'Checkmark', '6.5,10.5 | LineTo 9,13 | LineTo 13.5,7.5')
    end
    view:label('MeterCount', string.format('%d / 4', done))
end

local function redraw()
    draw()
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
end

function Initialize()
    view = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua').new(SKIN)
    day, bits = SKIN:GetVariable('HabitRecord', ''):match('^(%d%d%d%d%-%d%d%-%d%d)|([01][01][01][01])$')
    rollDay()
    draw()
end

function Update()
    if rollDay() then draw() end
    return 0
end

function Toggle(index)
    if index < 1 or index > 4 then return end
    rollDay()
    local value = bits:sub(index, index) == '1' and '0' or '1'
    bits = bits:sub(1, index - 1) .. value .. bits:sub(index + 1)
    save()
    redraw()
end

function ResetAll()
    day, bits = today(), '0000'
    save()
    redraw()
end
