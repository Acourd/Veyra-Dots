-- OneUIZen Countdown.lua
-- Calcula los días restantes hasta CountdownDate (YYYY-MM-DD).

function Initialize()
  UpdateCountdown()
end

function Update()
  UpdateCountdown()
  return 1
end

function UpdateCountdown()
  local targetStr = SKIN:GetVariable("CountdownDate", "2026-12-31")
  local lang = SKIN:GetVariable("Language", "ES")
  local y, m, d = targetStr:match("(%d+)-(%d+)-(%d+)")
  if not y then y, m, d = 2026, 12, 31 end

  local nowT = os.date("*t")
  local todayMid = os.time({ year = nowT.year, month = nowT.month, day = nowT.day, hour = 0 })
  local targetMid = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 0 })
  local diffDays = math.floor((targetMid - todayMid) / 86400)

  local label
  if diffDays > 0 then
    label = (lang == "EN") and (diffDays == 1 and "day left" or "days left") or (diffDays == 1 and "dia restante" or "dias restantes")
  elseif diffDays == 0 then
    label = (lang == "EN") and "today!" or "hoy!"
  else
    diffDays = math.abs(diffDays)
    label = (lang == "EN") and "days ago" or "dias atras"
  end

  SKIN:Bang("!SetVariable", "DaysCount", tostring(diffDays))
  SKIN:Bang("!SetVariable", "DaysLabel", label)
end
