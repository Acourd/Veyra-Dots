-- DotClock.lua — Centered 5x7 Vector Dot-Matrix Clock (Nothing OS)
local FONT = {
    ['0'] = {'01110','10001','10001','10001','10001','10001','01110'},
    ['1'] = {'00100','01100','00100','00100','00100','00100','01110'},
    ['2'] = {'01110','10001','00001','00110','01000','10000','11111'},
    ['3'] = {'11110','00001','00001','01110','00001','00001','11110'},
    ['4'] = {'00010','00110','01010','10010','11111','00010','00010'},
    ['5'] = {'11111','10000','11110','00001','00001','10001','01110'},
    ['6'] = {'01110','10000','11110','10001','10001','10001','01110'},
    ['7'] = {'11111','00001','00010','00100','01000','01000','01000'},
    ['8'] = {'01110','10001','10001','01110','10001','10001','01110'},
    ['9'] = {'01110','10001','10001','01111','00001','00001','01110'},
}

local offsets = {30, 94, 182, 246}
local hour, minute, scale, onColor, offColor, accent
local colonDrawn
local lastDigits = {}

function Initialize()
    hour = SKIN:GetMeasure('MeasureHour')
    minute = SKIN:GetMeasure('MeasureMin')
    scale = tonumber(SKIN:GetVariable('WidgetScale', '1')) or 1
    onColor = SKIN:GetVariable('OnSurface')
    offColor = SKIN:GetVariable('DotOff')
    accent = SKIN:GetVariable('Accent')
end

local function setDot(index, x, y, radius, color)
    local key = index == 1 and 'Shape' or 'Shape' .. index
    SKIN:Bang('!SetOption', 'MeterDots', key, string.format(
        'Ellipse %.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0',
        x * scale, y * scale, radius * scale, color))
end

function Update()
    local hours = hour:GetStringValue():match('%d+') or '00'
    local minutes = minute:GetStringValue():match('%d+') or '00'
    local time = string.format('%02d%02d', tonumber(hours), tonumber(minutes))
    for digit = 1, 4 do
        local glyph = FONT[time:sub(digit, digit)] or FONT['0']
        local previous = lastDigits[digit]
        if glyph ~= previous then
            for row = 1, 7 do
                for column = 1, 5 do
                    local pixel = glyph[row]:sub(column, column)
                    if not previous or pixel ~= previous[row]:sub(column, column) then
                        local index = (digit - 1) * 35 + (row - 1) * 5 + column
                        setDot(index, offsets[digit] + (column - 1) * 11, 53 + (row - 1) * 11,
                            3.75, pixel == '1' and onColor or offColor)
                    end
                end
            end
            lastDigits[digit] = glyph
        end
    end
    if not colonDrawn then
        setDot(141, 160, 75, 4.5, accent)
        setDot(142, 160, 97, 4.5, accent)
        colonDrawn = true
    end
    return hours .. ':' .. minutes
end
