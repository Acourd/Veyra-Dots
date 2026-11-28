local view, device, controlOnly

function Initialize()
    view = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua').new(SKIN)
    device = SKIN:GetMeasure('MeasureAudio')
    controlOnly = SELF:GetOption('ControlOnly', '0') == '1'
end

function Update()
    local value = device:GetValue()
    if controlOnly then return 0 end
    local name = device:GetStringValue()
    local unavailable = name == '' or name:match('^ERROR')
    local number = unavailable and '--' or (value < 0 and SKIN:GetVariable('UiMutedShort')
        or string.format('%d%%', math.floor(math.max(0, math.min(100, value)) + 0.5)))
    view:label('MeterVolumeValue', number)
    view:label('MeterDevice', unavailable and SKIN:GetVariable('UiNoOutput') or name)
    view:label('MeterMuteLabel', SKIN:GetVariable(value < 0 and 'UiUnmute' or 'UiMute'))
    return math.max(0, math.min(100, value))
end

function SetLevel(percent)
    percent = tonumber(percent)
    if not percent then return end
    local level = math.floor(math.min(100, math.max(0, percent)) + 0.5)
    SKIN:Bang('!CommandMeasure', 'MeasureAudio', 'SetVolume ' .. level)
    SKIN:Bang('!Update')
end
