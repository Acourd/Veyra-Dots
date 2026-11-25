-- OneUIZen Timer.lua
-- Temporizador Pomodoro/Enfoque reutilizable en ES/EN.

local totalSeconds = 1500
local remaining = 1500
local running = false
local mode = "FOCUS"

function Initialize()
  totalSeconds = tonumber(SELF:GetOption("DefaultSeconds", "1500")) or 1500
  remaining = totalSeconds
  SyncDisplay()
end

function Update()
  if running and remaining > 0 then
    remaining = remaining - 1
    if remaining == 0 then running = false end
  end
  SyncDisplay()
  return remaining
end

function Toggle()
  if remaining <= 0 then remaining = totalSeconds end
  running = not running
  SyncDisplay()
end

function Reset()
  running = false
  remaining = totalSeconds
  SyncDisplay()
end

function SetMinutes(mins, newMode)
  running = false
  totalSeconds = (tonumber(mins) or 25) * 60
  remaining = totalSeconds
  mode = newMode or "FOCUS"
  SyncDisplay()
end

function SyncDisplay()
  local m = math.floor(remaining / 60)
  local s = remaining % 60
  local ratio = (totalSeconds > 0) and (remaining / totalSeconds) or 0
  local lang = SKIN:GetVariable("Language", "ES")

  local statusText
  if remaining == 0 then
    statusText = (lang == "EN") and "DONE" or "LISTO"
  elseif running then
    statusText = (mode == "FOCUS")
      and ((lang == "EN") and "FOCUSING" or "ENFOCADO")
      or  ((lang == "EN") and "BREAK" or "DESCANSO")
  else
    statusText = (lang == "EN") and "PAUSED" or "PAUSADO"
  end

  SKIN:Bang("!SetVariable", "TimerText", string.format("%02d:%02d", m, s))
  SKIN:Bang("!SetVariable", "TimerStatus", statusText)
  SKIN:Bang("!SetVariable", "TimerRatio", string.format("%.4f", ratio))
  if SKIN:GetMeasure("MeasureRatioCalc") then SKIN:Bang("!UpdateMeasure", "MeasureRatioCalc") end
  SKIN:Bang("!UpdateMeter", "*")
  SKIN:Bang("!Redraw")
end
