local face, uptime
local previous

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
    uptime = SKIN:GetMeasure('MeasureUptime')
end

function Update()
    local boot = math.floor((os.time() - uptime:GetValue()) / 60) * 60
    if previous == nil then
        previous = boot
        face:text('MeterBoot', os.date('%d/%m  %H:%M', boot))
    end
    return 0
end
