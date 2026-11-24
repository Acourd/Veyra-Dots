# Veyra-Dots — Native Windows Bluetooth & Connected Devices Query (Zero external DLLs)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$btDevices = Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue |
  Where-Object { $_.InstanceId -match '^BTH(ENUM|LE)\\DEV_' -and $_.FriendlyName }

# Map battery percentages from any Bluetooth child/HF/LE device if exposed
$battMap = @{}
$allBth = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -match '^(BTHENUM|BTHLE|BTHHFENUM)\\' }
foreach ($b in $allBth) {
  $prop = Get-PnpDeviceProperty -InstanceId $b.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
  if ($prop -and $null -ne $prop.Data -and [int]$prop.Data -ge 0 -and [int]$prop.Data -le 100) {
    if ($b.InstanceId -match '([0-9A-Fa-f]{12})') {
      $battMap[$Matches[1].ToUpper()] = [int]$prop.Data
    }
    if ($b.FriendlyName) {
      $battMap[$b.FriendlyName.Trim()] = [int]$prop.Data
    }
  }
}

$seen = @{}
$results = @()

foreach ($d in $btDevices) {
  $name = ($d.FriendlyName -replace '\|', ' ').Trim()
  if (-not $name -or $seen.ContainsKey($name)) { continue }
  $seen[$name] = $true

  $connProp = Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName '{83DA6326-97A6-4088-9453-A1923F573B29} 15' -ErrorAction SilentlyContinue
  $isConn = 0
  if ($connProp -and $connProp.Data -eq $true) { $isConn = 1 }

  $batt = -1
  $bProp = Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
  if ($bProp -and $null -ne $bProp.Data) {
    $batt = [int]$bProp.Data
  } else {
    if ($d.InstanceId -match '([0-9A-Fa-f]{12})' -and $battMap.ContainsKey($Matches[1].ToUpper())) {
      $batt = $battMap[$Matches[1].ToUpper()]
    } elseif ($battMap.ContainsKey($name)) {
      $batt = $battMap[$name]
    }
  }

  $kind = 'DEV'
  if ($name -match '(?i)airpod|bud|head|ear|audio|nc\d|sony|bose|jbl|beat|havit|speaker|sound|wh-|wf-|pod|mic') {
    $kind = 'AUDIO'
  } elseif ($name -match '(?i)mouse|keyb|mx |track|pad|xbox|dualsense|controller|joy|pen|stylus') {
    $kind = 'INPUT'
  }

  $results += [PSCustomObject]@{
    Name = $name
    Conn = $isConn
    Batt = $batt
    Kind = $kind
  }
}

$sorted = $results | Sort-Object -Property @{Expression = 'Conn'; Descending = $true}, @{Expression = 'Name'; Descending = $false}
$connCount = @($sorted | Where-Object { $_.Conn -eq 1 }).Count
$totalCount = @($sorted).Count

$lines = @("COUNT=$connCount|$totalCount")
$idx = 1
foreach ($item in ($sorted | Select-Object -First 3)) {
  $lines += "DEV$idx=$($item.Name)|$($item.Conn)|$($item.Batt)|$($item.Kind)"
  $idx++
}

[Console]::Out.Write(($lines -join "`n"))
