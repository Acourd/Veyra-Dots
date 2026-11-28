local face, cpu, ram
local samples = {}
local columns = 37

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    cpu = SKIN:GetMeasure('MeasureCPU')
    ram = SKIN:GetMeasure('MeasureRAMRatio')
end

function Update()
    local current = {cpu:GetValue(), ram:GetValue()}
    samples[#samples + 1] = current
    if #samples > columns then table.remove(samples, 1) end
    local signals = {}
    for row = 1, 2 do
        face:text(row == 1 and 'MeterCPUValue' or 'MeterMemoryValue', string.format('%.0f%%', current[row]))
        for col = 1, columns do
            local sample = samples[col + #samples - columns]
            local ratio = sample and math.max(0, math.min(1, sample[row] / 100)) or 0
            local baseline = row == 1 and 93 or 155
            local h = math.max(2, math.floor(ratio * 26))
            local color = ratio == 0 and face.off or
                ((col == columns or ratio >= 0.9) and face.accent or (row == 1 and face.on or face.muted))
            signals[#signals + 1] = face:bar(28 + (col - 1) * 9, baseline - h, 4.5, h, color, 0.9)
        end
    end
    face:draw('MeterSignals', signals)
    return 0
end
