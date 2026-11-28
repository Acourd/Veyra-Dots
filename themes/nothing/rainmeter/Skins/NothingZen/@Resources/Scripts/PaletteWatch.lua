local nextCheck = 0
local running = false
local auto

function Initialize()
    auto = SKIN:GetVariable('AccentName') == 'Auto'
end

function Update()
    local now = os.time()
    if auto and not running and now >= nextCheck then
        running = true
        nextCheck = now + 45
        SKIN:Bang('!CommandMeasure', 'MeasureWallpaper', 'Run')
    end
    return 0
end

function Finish()
    running = false
    local output = SKIN:GetMeasure('MeasureWallpaper'):GetStringValue()
    if auto and output:find('NOTHING_AUTO_CHANGED', 1, true) then
        SKIN:Bang('!RefreshGroup', 'NothingZen')
    end
end
