-- Veyra-Dots - StorageVault.lua
-- Parsea salida de GetDrives.ps1 (via RunCommand) y actualiza hasta 4 unidades fisicas/USB con barras de capacidad y alerta semantica.

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
  local m = SKIN:GetMeasure("MeasureDriveCmd")
  local raw = m and m:GetStringValue() or ""

  local accent = SKIN:GetVariable("VaultAccent", SKIN:GetVariable("Primary", SKIN:GetVariable("Accent", "59,130,246,255")))
  local okCol = SKIN:GetVariable("VaultOkColor", accent)
  local warnCol = SKIN:GetVariable("VaultWarnColor", "249,115,22,255")
  local critCol = SKIN:GetVariable("VaultCritColor", "244,63,94,255")
  local trackCol = SKIN:GetVariable("VaultTrackColor", SKIN:GetVariable("Track", SKIN:GetVariable("SurfaceContainer", "42,46,58,255")))
  local dimCol = SKIN:GetVariable("OnSurfaceVariant", SKIN:GetVariable("OnSurfaceMuted", "152,152,157,255"))
  local barX = tonumber(SKIN:GetVariable("VaultBarX", "24")) or 24
  local barW = tonumber(SKIN:GetVariable("VaultBarW", "288")) or 288
  local lblFree = SKIN:GetVariable("LblFree", "libre")

  local count = 0
  local drives = {}

  for line in string.gmatch(raw, "[^\r\n]+") do
    local c = string.match(line, "^COUNT=(%d+)")
    if c then
      count = tonumber(c) or 0
    else
      local idxStr, rest = string.match(line, "^DRV(%d+)=(.+)$")
      if idxStr and rest then
        local idx = tonumber(idxStr)
        local p = splitPipe(rest)
        drives[idx] = {
          id = p[1] or "C:",
          label = p[2] or "Local Disk",
          kind = p[3] or "SSD",
          used = tonumber(p[4]) or 0,
          total = tonumber(p[5]) or 0,
          free = tonumber(p[6]) or 0,
          pct = tonumber(p[7]) or 0
        }
      end
    end
  end

  SKIN:Bang("!SetOption", "MeterDriveCount", "Text", tostring(count) .. "x")
  SKIN:Bang("!UpdateMeter", "MeterDriveCount")

  for i = 1, 4 do
    local d = drives[i]
    local rowY = tonumber(SKIN:GetVariable("VaultRowY" .. i, tostring(58 + (i - 1) * 44))) or (58 + (i - 1) * 44)
    if d then
      local fillW = math.max(10, math.floor((math.min(100, math.max(0, d.pct)) / 100) * barW + 0.5))
      local col = okCol
      if d.pct >= 90 then
        col = critCol
      elseif d.pct >= 75 then
        col = warnCol
      end

      SKIN:Bang("!SetOption", "MeterDrvTitle" .. i, "Text", string.format("%s  %s - %s", d.id, d.label, d.kind))
      SKIN:Bang("!SetOption", "MeterDrvInfo" .. i, "Text", string.format("%d/%d GB - %d GB %s", d.used, d.total, d.free, lblFree))
      SKIN:Bang("!SetOption", "MeterDrvPct" .. i, "Text", d.pct .. "%")
      SKIN:Bang("!SetOption", "MeterDrvPct" .. i, "FontColor", col)
      SKIN:Bang("!SetOption", "MeterDrvHit" .. i, "LeftMouseUpAction", '["' .. d.id .. '\\"]')
      SKIN:Bang("!SetOption", "MeterDrvBar" .. i, "Shape",
        string.format("Rectangle %d,%d,%d,8,4 | Fill Color %s | StrokeWidth 0", barX, rowY + 22, barW, trackCol))
      SKIN:Bang("!SetOption", "MeterDrvBar" .. i, "Shape2",
        string.format("Rectangle %d,%d,%d,8,4 | Fill Color %s | StrokeWidth 0", barX, rowY + 22, fillW, col))
    else
      SKIN:Bang("!SetOption", "MeterDrvTitle" .. i, "Text", "Slot " .. i .. " - --")
      SKIN:Bang("!SetOption", "MeterDrvInfo" .. i, "Text", "USB / NVMe")
      SKIN:Bang("!SetOption", "MeterDrvPct" .. i, "Text", "--")
      SKIN:Bang("!SetOption", "MeterDrvPct" .. i, "FontColor", dimCol)
      SKIN:Bang("!SetOption", "MeterDrvHit" .. i, "LeftMouseUpAction", "")
      SKIN:Bang("!SetOption", "MeterDrvBar" .. i, "Shape",
        string.format("Rectangle %d,%d,%d,8,4 | Fill Color %s | StrokeWidth 0", barX, rowY + 22, barW, trackCol))
      SKIN:Bang("!SetOption", "MeterDrvBar" .. i, "Shape2",
        string.format("Rectangle %d,%d,0,8,4 | Fill Color %s | StrokeWidth 0", barX, rowY + 22, trackCol))
    end
    SKIN:Bang("!UpdateMeter", "MeterDrvTitle" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDrvInfo" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDrvPct" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDrvHit" .. i)
    SKIN:Bang("!UpdateMeter", "MeterDrvBar" .. i)
  end

  SKIN:Bang("!Redraw")
end
