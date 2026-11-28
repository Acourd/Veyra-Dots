local face
local started
local lastState
local phases = {
    {length = 4, label = 'SigInhale'},
    {length = 3, label = 'SigHold'},
    {length = 5, label = 'SigExhale'},
}
local cycle = 12
local rounds = 4
local dots = 48

local function draw(phase, stage, second, remaining, round)
    local key = table.concat({phase or 0, stage, second, remaining, round}, ':')
    if lastState == key then return end
    lastState = key
    local label = phase and SKIN:GetVariable(phases[phase].label) or SKIN:GetVariable('SigBreath')
    local secondary = phase and string.format('%d / %d', round, rounds) or SKIN:GetVariable('SigBreathTempo')
    face:text('MeterPhase', label)
    face:text('MeterCount', phase and string.format('%02d', remaining) or SKIN:GetVariable('SigStart'))
    face:text('MeterCycle', secondary)

    local shapes = {}
    for i = 0, dots - 1 do
        local angle = i / dots * 2 * math.pi - math.pi / 2
        local active = phase and i < math.floor(second / cycle * dots)
        local cursor = phase and i == math.floor(second / cycle * dots)
        local color = cursor and face.accent or (active and face.on or face.off)
        if not phase and i % 16 == 0 then color = face.accent end
        local radius = (i % 4 == 0 or cursor) and 3 or 1.85
        shapes[i + 1] = face:dot(104 + math.cos(angle) * 83, 104 + math.sin(angle) * 83, radius, color)
    end
    face:draw('MeterRing', shapes)
end

function Initialize()
    face = dofile(SKIN:GetVariable('@') .. 'Scripts\\Instrument.lua').new(SKIN)
end

function Update()
    local elapsed = started and math.max(0, os.time() - started) or 0
    if started and elapsed >= cycle * rounds then started = nil end
    if not started then
        draw(nil, 0, 0, 0, 0)
        return 0
    end

    local second = elapsed % cycle
    local phaseSecond = second
    local round = math.floor(elapsed / cycle) + 1
    for i, phase in ipairs(phases) do
        if phaseSecond < phase.length then
            draw(i, phaseSecond, second, phase.length - phaseSecond, round)
            break
        end
        phaseSecond = phaseSecond - phase.length
    end
    return elapsed
end

function Toggle()
    if started then started = nil else started = os.time() end
    Update()
    face:redraw()
end
