# Veyra-Dots — Native Windows Bluetooth & Connected Devices Query (Zero external DLLs)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function ConvertTo-BatteryPct($val) {
  if ($null -eq $val) { return -1 }
  $parsed = 0
  if ([int]::TryParse([string]$val, [ref]$parsed) -and $parsed -ge 0 -and $parsed -le 100) {
    return $parsed
  }
  return -1
}

try {
  $btDevices = @(Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue |
    Where-Object { $_.InstanceId -match '^BTH(ENUM|LE)\\DEV_' -and $_.FriendlyName })

  # Map battery percentages from active Bluetooth child/HF/LE devices if exposed
  $battMap = @{}
  $allBth = @(Get-PnpDevice -ErrorAction SilentlyContinue |
    Where-Object { $_.Status -eq 'OK' -and $_.InstanceId -match '^(BTHENUM|BTHLE|BTHHFENUM)\\' })
  foreach ($b in $allBth) {
    $prop = Get-PnpDeviceProperty -InstanceId $b.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
    $pct = if ($prop) { ConvertTo-BatteryPct $prop.Data } else { -1 }
    if ($pct -ge 0) {
      if ($b.InstanceId -match '([0-9A-Fa-f]{12})') {
        $battMap[$Matches[1].ToUpper()] = $pct
      }
      if ($b.FriendlyName) {
        $cleanKey = ($b.FriendlyName -replace '[\r\n|]', ' ').Trim()
        if ($cleanKey) { $battMap[$cleanKey] = $pct }
      }
    }
  }

  $byName = @{}
  foreach ($d in $btDevices) {
    $name = ($d.FriendlyName -replace '[\r\n|]', ' ').Trim()
    if (-not $name) { continue }

    $connProp = Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName '{83DA6326-97A6-4088-9453-A1923F573B29} 15' -ErrorAction SilentlyContinue
    $isConn = if ($connProp -and $connProp.Data -eq $true) { 1 } else { 0 }

    $batt = -1
    $bProp = Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
    if ($bProp) {
      $batt = ConvertTo-BatteryPct $bProp.Data
    }
    if ($batt -lt 0) {
      if ($d.InstanceId -match '([0-9A-Fa-f]{12})' -and $battMap.ContainsKey($Matches[1].ToUpper())) {
        $batt = $battMap[$Matches[1].ToUpper()]
      } elseif ($battMap.ContainsKey($name)) {
        $batt = $battMap[$name]
      }
    }

    if ($byName.ContainsKey($name)) {
      if ($isConn -gt $byName[$name].Conn) { $byName[$name].Conn = $isConn }
      if ($byName[$name].Batt -lt 0 -and $batt -ge 0) { $byName[$name].Batt = $batt }
      continue
    }

    $kind = 'DEV'
    if ($name -match '(?i)airpod|bud|head|ear|audio|nc\d|sony|bose|jbl|beat|havit|speaker|sound|wh-|wf-|pod|mic') {
      $kind = 'AUDIO'
    } elseif ($name -match '(?i)mouse|keyb|mx |track|pad|xbox|dualsense|controller|joy|pen|stylus') {
      $kind = 'INPUT'
    }

    $byName[$name] = [PSCustomObject]@{
      Name = $name
      Conn = $isConn
      Batt = $batt
      Kind = $kind
    }
  }

  $sorted = @($byName.Values | Sort-Object -Property @{Expression = 'Conn'; Descending = $true}, @{Expression = 'Name'; Descending = $false})
  $connCount = @($sorted | Where-Object { $_.Conn -eq 1 }).Count
  $totalCount = $sorted.Count

  $lines = @("COUNT=$connCount|$totalCount")
  $idx = 1
  foreach ($item in ($sorted | Select-Object -First 3)) {
    $lines += "DEV$idx=$($item.Name)|$($item.Conn)|$($item.Batt)|$($item.Kind)"
    $idx++
  }

  [Console]::Out.Write(($lines -join "`n"))
} catch {
  [Console]::Out.Write("COUNT=0|0")
}
