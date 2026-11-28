local urls = {
    'https://www.google.com/search?q=',
    'https://www.youtube.com/results?search_query=',
    'https://%s.wikipedia.org/w/index.php?search=',
}
local labels = {'UiFinderWebPrompt', 'UiFinderVideoPrompt', 'UiFinderWikiPrompt'}
local selected = 1

function Select(index)
    if not urls[index] then return end
    selected = index
    for i = 1, #urls do
        local highlighted = i == selected and 'Track' or 'SurfaceElevated'
        SKIN:Bang('!SetOption', 'MeterProvider' .. i, 'Shape',
            'Rectangle 0,0,86,28,14 | StrokeWidth 0 | Fill Color ' .. SKIN:GetVariable(highlighted))
    end
    SKIN:Bang('!SetOption', 'MeterPrompt', 'Text', SKIN:GetVariable(labels[index]))
    SKIN:Bang('!UpdateMeter', '*')
    SKIN:Bang('!Redraw')
    SKIN:Bang('!CommandMeasure', 'MeasureSearchInput', 'ExecuteBatch 1-2')
end

function Submit()
    local encoded = SKIN:ReplaceVariables('[&MeasureSearchInput:EncodeURL]')
    if encoded == '' or not encoded:match('^[A-Za-z0-9._~%%-]+$') then return end
    local base = urls[selected]
    if selected == 3 then
        base = base:format(SKIN:GetVariable('Language') == 'ES' and 'es' or 'en')
    end
    SKIN:Bang('["' .. base .. encoded .. '"]')
end
