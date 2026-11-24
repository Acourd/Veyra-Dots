-- MaterialYZen Timer.lua
-- Temporizador reutilizable en ES y EN para PomodoroPill y FocusSession.

local totalSeconds = 1500
local remaining = 1500
local running = false
local mode = "FOCUS" -- FOCUS | BREAK

function Initialize()
  totalSeconds = tonumber(SELF:GetOption("DefaultSeconds", "1500")) or 1500
  remaining = totalSeconds
  SyncDisplay()
end

function Update()
  if running and remaining > 0 then
    remaining = remaining - 1
    if remaining == 0 then
      running = false
      if mode == "FOCUS" then
        local done = tonumber(SKIN:GetVariable("FocusSessionsDone", "0")) or 0
        done = done + 1
        SKIN:Bang("!WriteKeyValue", "Variables", "FocusSessionsDone", tostring(done), SKIN:GetVariable("@") .. "Productivity.inc")
        SKIN:Bang("!SetVariable", "FocusSessionsDone", tostring(done))
      end
    end
  end
  SyncDisplay()
  return remaining
end

function Toggle()
  if remaining <= 0 then
    remaining = totalSeconds
  end
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
    if mode == "FOCUS" then
      statusText = (lang == "EN") and "FOCUSING" or "ENFOCADO"
    else
      statusText = (lang == "EN") and "BREAK" or "DESCANSO"
    end
  else
    statusText = (lang == "EN") and "PAUSED" or "PAUSADO"
  end

  SKIN:Bang("!SetVariable", "TimerMin", string.format("%02d", m))
  SKIN:Bang("!SetVariable", "TimerSec", string.format("%02d", s))
  SKIN:Bang("!SetVariable", "TimerText", string.format("%02d:%02d", m, s))
  SKIN:Bang("!SetVariable", "TimerStatus", statusText)
  SKIN:Bang("!SetVariable", "TimerRatio", string.format("%.4f", ratio))
  if SKIN:GetMeter("MeterPlayIcon") and SKIN:GetMeter("MeterPauseIcon") then
    if running then
      SKIN:Bang("!HideMeter", "MeterPlayIcon")
      SKIN:Bang("!ShowMeter", "MeterPauseIcon")
    else
      SKIN:Bang("!ShowMeter", "MeterPlayIcon")
      SKIN:Bang("!HideMeter", "MeterPauseIcon")
    end
  end
  if SKIN:GetMeasure("MeasureRatioCalc") then
    SKIN:Bang("!UpdateMeasure", "MeasureRatioCalc")
  end
  if SKIN:GetMeasure("MeasureBarFill") then
    SKIN:Bang("!UpdateMeasure", "MeasureBarFill")
  end
  SKIN:Bang("!UpdateMeter", "*")
  SKIN:Bang("!Redraw")
end
