local face
-- Original, low-resolution glyphs that share one grid across search and launcher controls.
local glyphs = {
    web = {'0011100','0101010','1001001','1111111','1001001','0101010','0011100'},
    video = {'1111111','1000001','1010001','1011001','1010001','1000001','1111111'},
    mail = {'1111111','1100011','1010101','1001001','1000001','1000001','1111111'},
    sparkle = {'0001000','0001000','0011100','1111111','0011100','0001000','0001000'},
    search = {'0111000','1000100','1000100','1000100','0111000','0000110','0000011'},
}

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
end

function Update()
    local name = SELF:GetOption('Icon', 'search')
    local icons = name == 'apps' and {'web','video','mail','sparkle'} or {name}
    local spacing = name == 'apps' and 3.6 or 2.9
    for index, icon in ipairs(icons) do
        local x = name == 'apps' and 48 + 72 * (index - 1) or 34
        local y = name == 'apps' and 41 or 33
        local shapes = {}
        for row, pattern in ipairs(glyphs[icon]) do
            for column = 1, #pattern do
                if pattern:sub(column, column) == '1' then
                    shapes[#shapes + 1] = face:dot(x + (column - 4) * spacing, y + (row - 4) * spacing,
                        name == 'apps' and 1.35 or 1.02, icon == 'sparkle' and face.accent or face.on)
                end
            end
        end
        face:draw('MeterGlyph' .. index, shapes)
    end
    return 0
end
