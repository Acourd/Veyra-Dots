local slot, wide, count, shapes
local picked, lastGlyph
local audio

local function muted()
    return audio:GetValue() < 0
end

local function render()
    local glyph = picked == 3 and muted() and count + 1 or picked
    if glyph == lastGlyph then return false end
    lastGlyph = glyph
    local offset = wide and ' | Offset 8,8.5' or ' | Offset 11,11'
    local key = 'MosaicShape' .. glyph .. 'Part'
    for i = 2, shapes + 1 do
        local geometry = SKIN:GetVariable(key .. i, '')
        if geometry == '' then
            geometry = 'Line 0,0,1,0 | StrokeWidth 0'
        else
            local path = geometry:match('^Path (Geometry%d+)')
            if path then
                SKIN:Bang('!SetOption', 'MeterTool', path, SKIN:GetVariable('MosaicPath' .. glyph .. path))
            end
            geometry = SKIN:ReplaceVariables(geometry) .. offset
        end
        SKIN:Bang('!SetOption', 'MeterTool', 'Shape' .. i, geometry)
    end
    if wide then
        local detail
        if picked == 3 then
            detail = SKIN:GetVariable(glyph > count and 'MosaicSoundOff' or 'MosaicSoundOn')
        elseif picked == 4 then
            detail = SKIN:GetVariable(SKIN:GetVariable('ThemeMode') == 'Dark' and 'LblDark' or 'LblLight')
        else
            detail = SKIN:GetVariable('MosaicOpenSettings')
        end
        SKIN:Bang('!SetOption', 'MeterToolLabel', 'Text', SKIN:GetVariable('MosaicTool' .. picked))
        SKIN:Bang('!SetOption', 'MeterToolDetail', 'Text', detail)
    end
    return true
end

function Initialize()
    slot = SELF:GetOption('Slot')
    wide = SELF:GetOption('Wide') == '1'
    count = tonumber(SELF:GetOption('Count'))
    shapes = tonumber(SELF:GetOption('Shapes'))
    picked = math.max(1, math.min(count, tonumber(SKIN:GetVariable(slot, '1')) or 1))
    audio = SKIN:GetMeasure('MeasureAudio')
end

function Update()
    render()
    return picked
end

function Select(index)
    if index < 1 or index > count or index == picked then return end
    picked = index
    SKIN:Bang('!WriteKeyValue', 'Variables', slot, tostring(picked), SKIN:GetVariable('@') .. 'Tools.inc')
    render()
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
end

function Cycle(direction)
    Select((picked - 1 + direction) % count + 1)
end

function Activate()
    SKIN:Bang(SKIN:GetVariable('MosaicAction' .. picked))
end
