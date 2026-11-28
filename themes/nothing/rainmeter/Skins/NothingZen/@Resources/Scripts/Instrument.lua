-- Drawing primitives in logical pixels. Only changed Direct2D shapes are sent to Rainmeter.
local Instrument = {}

function Instrument.new(skin)
    local canvas = {
        scale = tonumber(skin:GetVariable('WidgetScale', '1')) or 1,
        on = skin:GetVariable('OnSurface'),
        off = skin:GetVariable('DotOff'),
        muted = skin:GetVariable('OnSurfaceMuted'),
        accent = skin:GetVariable('Accent'),
        cache = {},
    }

    function canvas:dot(x, y, radius, color)
        local s = self.scale
        return string.format('Ellipse %.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0',
            x * s, y * s, radius * s, color)
    end

    function canvas:line(x1, y1, x2, y2, width, color)
        local s = self.scale
        return string.format('Line %.2f,%.2f,%.2f,%.2f | StrokeWidth %.2f | Stroke Color %s | StrokeStartCap Round | StrokeEndCap Round',
            x1 * s, y1 * s, x2 * s, y2 * s, width * s, color)
    end

    function canvas:bar(x, y, width, height, color, corner)
        local s = self.scale
        local radius = corner or math.min(width, height) / 2
        return string.format('Rectangle %.2f,%.2f,%.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0',
            x * s, y * s, width * s, height * s, radius * s, color)
    end

    function canvas:draw(meter, shapes)
        local previous = self.cache[meter] or {}
        for i, shape in ipairs(shapes) do
            if shape ~= previous[i] then
                local key = i == 1 and 'Shape' or 'Shape' .. i
                skin:Bang('!SetOption', meter, key, shape)
            end
        end
        self.cache[meter] = shapes
    end

    function canvas:text(meter, value)
        if self.cache[meter] ~= value then
            skin:Bang('!SetOption', meter, 'Text', value)
            self.cache[meter] = value
        end
    end

    function canvas:redraw()
        skin:Bang('!UpdateMeter', '*')
        skin:Bang('!Redraw')
    end

    return canvas
end

return Instrument
