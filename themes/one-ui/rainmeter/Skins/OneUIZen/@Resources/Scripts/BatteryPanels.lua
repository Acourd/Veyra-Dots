local panel, view, status, percent, plugged, lifetime
local historyEnabled, samples
local maxSamples = 61
local transparent = '0,0,0,0'

function Initialize()
    panel = dofile(SKIN:GetVariable('@') .. 'Scripts\\Panel.lua')
    view = panel.new(SKIN)
    status = SKIN:GetMeasure('MeasureStatus')
    percent = SKIN:GetMeasure('MeasurePercent')
    plugged = SKIN:GetMeasure('MeasureAC')
    lifetime = SKIN:GetMeasure('MeasureLifetime')
    historyEnabled = SELF:GetOption('History', '0') == '1'
    samples = {}
end

local function updateHistory(value)
    if value >= 0 then
        samples[#samples + 1] = value
        if #samples > maxSamples then table.remove(samples, 1) end
    elseif #samples > 0 then
        samples = {}
    end
    for i = 1, maxSamples do
        local sample = samples[i + #samples - maxSamples]
        local height = sample and 2 + sample * 0.82 or 2
        local color = sample and view:color(i == maxSamples and 'Accent' or 'SamsungBlue') or transparent
        view:set('MeterHistory', i == 1 and 'Shape' or 'Shape' .. i,
            panel.rect(43 + (i - 1) * 4.5, 166 - height, 2.6, height, color, 1.3, view.scale))
    end
    view:label('MeterSpan', value < 0 and '--' or #samples < 2 and SKIN:GetVariable('UiSampling')
        or string.format('%d:%02d %s', math.floor((#samples - 1) / 4), ((#samples - 1) % 4) * 15, SKIN:GetVariable('UiRecorded')))
end

function Update()
    local state, value = status:GetValue(), percent:GetValue()
    local ac = plugged:GetValue() == 1
    local available = state > 0 and value >= 0 and value <= 100
    local nominal = available and value or -1
    local label = not available and 'UiNoBattery' or state == 1 and 'LblCharging' or
        ac and 'UiPlugged' or 'UiOnBattery'
    view:label('MeterPercent', available and string.format('%.0f%%', value) or '--')
    view:label('MeterStatus', SKIN:GetVariable(label))
    if historyEnabled then
        updateHistory(nominal)
    else
        local seconds = available and not ac and lifetime:GetValue() or -1
        local estimate = seconds > 0 and seconds < 172800 and
            string.format('%d h %02d min', math.floor(seconds / 3600), math.floor(seconds / 60) % 60)
            or SKIN:GetVariable('UiNoEstimate')
        view:label('MeterEstimate', estimate)
    end
    return math.max(0, nominal)
end
