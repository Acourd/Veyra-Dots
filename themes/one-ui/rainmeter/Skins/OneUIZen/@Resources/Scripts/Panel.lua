-- Build vector shapes and update only the values that changed.
local Panel = {}

function Panel.new(skin)
    local view = {cache = {}, scale = tonumber(skin:GetVariable('OneUICompact', '1')) or 1}

    function view:set(meter, key, value)
        local id = meter .. ':' .. key
        if self.cache[id] ~= value then
            skin:Bang('!SetOption', meter, key, value)
            self.cache[id] = value
        end
    end

    function view:label(meter, value)
        self:set(meter, 'Text', value)
    end

    function view:color(name)
        return skin:GetVariable(name)
    end

    return view
end

function Panel.rect(x, y, width, height, color, corner, scale)
    scale = scale or 1
    return string.format('Rectangle %.2f,%.2f,%.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0',
        x * scale, y * scale, width * scale, height * scale, corner * scale, color)
end

function Panel.dot(x, y, radius, color)
    return string.format('Ellipse %.2f,%.2f,%.2f | Fill Color %s | StrokeWidth 0', x, y, radius, color)
end

return Panel
