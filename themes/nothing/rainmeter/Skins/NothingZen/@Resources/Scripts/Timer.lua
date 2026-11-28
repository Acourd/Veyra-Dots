-- OneUIZen Timer.lua
-- Temporizador Pomodoro/Enfoque reutilizable en ES/EN.

local totalSeconds = 1500
local remaining = 1500
local endsAt
local mode = "FOCUS"

function Initialize()
  totalSeconds = tonumber(SELF:GetOption("DefaultSeconds", "1500")) or 1500
  remaining = totalSeconds
  SyncDisplay()
end

function Update()
  if endsAt then
    remaining = math.max(0, endsAt - os.time())
    if remaining == 0 then endsAt = nil end
  end
  SyncDisplay()
  return remaining
end

function Toggle()
  if endsAt then
    remaining = math.max(0, endsAt - os.time())
    endsAt = nil
  else
    if remaining <= 0 then remaining = totalSeconds end
    endsAt = os.time() + remaining
  end
  RefreshDisplay()
end

function Reset()
  endsAt = nil
  remaining = totalSeconds
  RefreshDisplay()
end

function SetMinutes(mins, newMode)
  endsAt = nil
  totalSeconds = (tonumber(mins) or 25) * 60
  remaining = totalSeconds
  mode = newMode or "FOCUS"
  RefreshDisplay()
end

function SetBreak()
  SetMinutes(5, "BREAK")
end

function SyncDisplay()
  local m = math.floor(remaining / 60)
  local s = remaining % 60
  local ratio = (totalSeconds > 0) and (remaining / totalSeconds) or 0
  local lang = SKIN:GetVariable("Language", "ES")

  local statusText
  if remaining == 0 then
    statusText = (lang == "EN") and "DONE" or "LISTO"
  elseif endsAt then
    statusText = (mode == "FOCUS")
      and ((lang == "EN") and "FOCUSING" or "ENFOCADO")
      or  ((lang == "EN") and "BREAK" or "DESCANSO")
  elseif remaining == totalSeconds then
    statusText = SKIN:GetVariable("NzReady", "READY")
  else
    statusText = (lang == "EN") and "PAUSED" or "PAUSADO"
  end

  SKIN:Bang("!SetVariable", "TimerText", string.format("%02d:%02d", m, s))
  SKIN:Bang("!SetVariable", "TimerStatus", statusText)
  local action = endsAt and "NzPause" or (remaining > 0 and remaining < totalSeconds and "NzResume" or "NzStartStop")
  SKIN:Bang("!SetVariable", "TimerAction", SKIN:GetVariable(action, "START"))
  SKIN:Bang("!SetVariable", "TimerProfile", SKIN:GetVariable(mode == "FOCUS" and "LblFocus" or "NzBreakLabel"))
  SKIN:Bang("!SetVariable", "TimerRatio", string.format("%.6f", ratio))
end

function RefreshDisplay()
  SyncDisplay()
  SKIN:Bang("!UpdateMeasure", "MeasureProgress")
  SKIN:Bang("!UpdateMeasure", "MeasureTicks")
  SKIN:Bang("!UpdateMeter", "MeterTime")
  SKIN:Bang("!UpdateMeter", "MeterStatus")
  SKIN:Bang("!UpdateMeter", "MeterTitle")
  SKIN:Bang("!UpdateMeter", "MeterPlayText")
  SKIN:Bang("!UpdateMeter", "MeterTicks")
  SKIN:Bang("!Redraw")
end
