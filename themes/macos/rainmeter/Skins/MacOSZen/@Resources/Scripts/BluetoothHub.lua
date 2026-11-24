-- Veyra-Dots - BluetoothHub.lua
-- Parsea salida de GetBluetooth.ps1 (via RunCommand) y actualiza 3 ranuras de dispositivos con estado en vivo y barra de bateria.

function Initialize()
  Parse()
end

function Update()
  return 1
end

local function splitPipe(str)
  local out = {}
  for part in string.gmatch(str .. "|", "(.-)|") do
    table.insert(out, part)
  end
  return out
end

function Parse()
  local m = SKIN:GetMeasure("MeasureBtCmd")
  local raw = m and m:GetStringValue() or ""

  local accent = SKIN:GetVariable("BtAccent", SKIN:GetVariable("Primary", SKIN:GetVariable("Accent", "59,130,246,255")))
  local okCol = SKIN:GetVariable("BtOnlineColor", "48,209,88,255")
  local dimCol = SKIN:GetVariable("BtOfflineColor", SKIN:GetVariable("OnSurfaceVariant", SKIN:GetVariable("OnSurfaceMuted", "152,152,157,255")))
  local trackCol = SKIN:GetVariable("BtTrackColor", SKIN:GetVariable("Track", SKIN:GetVariable("SurfaceContainer", "42,46,58,255")))
  local warnCol = SKIN:GetVariable("BtWarnColor", "255,159,10,255")
  local lowCol = SKIN:GetVariable("BtLowColor", "255,69,58,255")
  local barMaxW = tonumber(SKIN:GetVariable("BtBarMaxW", "124")) or 124
  local barX = tonumber(SKIN:GetVariable("BtBarX", "68")) or 68
  local lblConn = SKIN:GetVariable("LblConnected", "Conectado")
  local lblPair = SKIN:GetVariable("LblPaired", "Emparejado")
  local lblNone = SKIN:GetVariable("LblNoDevices", "Sin dispositivos BT")
  local lblFreeSlot = SKIN:GetVariable("LblFreeSlot", "Slot libre")

  local connCount, totalCount = 0, 0
  local devices = {}

  for line in string.gmatch(raw, "[^\r\n]+") do
    local c1, c2 = string.match(line, "^COUNT=(%d+)|(%d+)")
    if c1 then
      connCount = tonumber(c1) or 0
      totalCount = tonumber(c2) or 0
    else
      local idxStr, rest = string.match(line, "^DEV(%d+)=(.+)$")
      if idxStr and rest then
        local idx = tonumber(idxStr)
        local p = splitPipe(rest)
        devices[idx] = {
          name = p[1] or "Bluetooth",
          conn = tonumber(p[2]) or 0,
          batt = tonumber(p[3]) or -1,
          kind = p[4] or "DEV"
        }
      end
    end
  end

  SKIN:Bang("!SetOption", "MeterBtCount", "Text", string.format("%d/%d", connCount, totalCount))
  SKIN:Bang("!UpdateMeter", "MeterBtCount")

  for i = 1, 3 do
    local d = devices[i]
    local rowY = tonumber(SKIN:GetVariable("BtRowY" .. i, tostring(58 + (i - 1) * 46))) or (58 + (i - 1) * 46)
    if d then
      SKIN:Bang("!SetOption", "MeterDevName" .. i, "Text", d.name)
      local statusTxt = (d.conn == 1) and lblConn or lblPair
      local badgeTxt = (d.batt >= 0) and (d.batt .. "%") or ((d.conn == 1) and "ON" or "--")
      local ledCol = (d.conn == 1) and okCol or dimCol
      local fillPct = (d.batt >= 0) and d.batt or ((d.conn == 1) and 100 or 12)
      local fillW = math.max(8, math.floor((fillPct / 100) * barMaxW + 0.5))
      local barCol = accent
      if d.conn == 0 then
        barCol = dimCol
      elseif d.batt >= 0 and d.batt <= 20 then
        barCol = lowCol
      elseif d.batt >= 0 and d.batt <= 45 then
        barCol = warnCol
      elseif d.conn == 1 then
        barCol = okCol
      end

      SKIN:Bang("!SetOption", "MeterDevSub" .. i, "Text", statusTxt .. " - " .. d.kind)
      SKIN:Bang("!SetOption", "MeterDevBadge" .. i, "Text", badgeTxt)
      SKIN:Bang("!SetOption", "MeterDevBadge" .. i, "FontColor", (d.conn == 1) and barCol or dimCol)
      SKIN:Bang("!SetOption", "MeterDevLed" .. i, "Shape",
        string.format("Ellipse 5,5,4.5 | Fill Color %s | StrokeWidth 0", ledCol))
      SKIN:Bang("!SetOption", "MeterDevBar" .. i, "Shape",
        string.format("Rectangle %d,%d,%d,5,2.5 | Fill Color %s | StrokeWidth 0", barX, rowY + 26, barMaxW, trackCol))
      SKIN:Bang("!SetOption", "MeterDevBar" .. i, "Shape2",
        string.format("Rectangle %d,%d,%d,5,2.5 | Fill Color %s | StrokeWidth 0", barX, rowY + 26, fillW, barCol))
    else
      local emptyTitle = (i == 1 and totalCount == 0) and lblNone or "-"
      local emptySub = (i == 1 and totalCount == 0) and "Windows Bluetooth" or lblFreeSlot
      SKIN:Bang("!SetOption", "MeterDevName" .. i, "Text", emptyTitle)
      SKIN:Bang("!SetOption", "MeterDevSub" .. i, "Text", emptySub)
      SKIN:Bang("!SetOption", "MeterDevBadge" .. i, "Text", "--")
      SKIN:Bang("!SetOption", "MeterDevBadge" .. i, "FontColor", dimCol)
      SKIN:Bang("!SetOption", "MeterDevLed" .. i, "Shape",
        string.format("Ellipse 5,5,4.5 | Fill Color %s | StrokeWidth 0", trackCol))
      SKIN:Bang("!SetOption", "MeterDevBar" .. i, "Shape",
        string.format("Rectangle %d,%d,%d,5,2.5 | Fill Color %s | StrokeWidth 0", barX, rowY + 26, barMaxW, trackCol))
      SKIN:Bang("!SetOption", "MeterDevBar" .. i, "Shape2",
        string.format("Rectangle %d,%d,0,5,2.5 | Fill Color %s | StrokeWidth 0", barX, rowY + 26, trackCol))
    end
    SKIN:Bang("!UpdateMeter", "MeterDevName" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDevSub" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDevBadge" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDevLed" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDevBar" .. i)
  end

  SKIN:Bang("!Redraw")
end
