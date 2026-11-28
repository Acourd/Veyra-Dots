-- OneUICounter.lua — Interactive Goal Counter for OneUIZen
local count = 0
local goal = 100

local function iniPath()
    return SKIN:GetVariable('CURRENTPATH') .. SKIN:GetVariable('CURRENTFILE')
end

function Initialize()
    count = tonumber(SKIN:GetVariable('CounterVal', '0')) or 0
    goal = tonumber(SKIN:GetVariable('CounterGoal', '100')) or 100
end

function RefreshUI()
    local pct = math.min(1, math.max(0, count / math.max(1, goal)))
    local barW = math.max(12, math.floor(pct * 150 + 0.5))
    local green = SKIN:GetVariable('SamsungGreen', '34,197,94,255')
    SKIN:Bang('!SetOption', 'MeterCount', 'Text', tostring(count))
    SKIN:Bang('!SetOption', 'MeterBarFill', 'Shape',
        string.format('Rectangle 20,86,%d,12,6 | Fill Color %s | StrokeWidth 0', barW, green))
    SKIN:Bang('!UpdateMeter', 'MeterCount')
    SKIN:Bang('!UpdateMeter', 'MeterBarFill')
    SKIN:Bang('!Redraw')
end

function Update()
    RefreshUI()
    return count
end

function Increment()
    count = count + 1
    SKIN:Bang('!WriteKeyValue', 'Variables', 'CounterVal', tostring(count), iniPath())
    RefreshUI()
end

function Decrement()
    if count > 0 then count = count - 1 end
    SKIN:Bang('!WriteKeyValue', 'Variables', 'CounterVal', tostring(count), iniPath())
    RefreshUI()
end

function Reset()
    count = 0
    SKIN:Bang('!WriteKeyValue', 'Variables', 'CounterVal', '0', iniPath())
    RefreshUI()
end
