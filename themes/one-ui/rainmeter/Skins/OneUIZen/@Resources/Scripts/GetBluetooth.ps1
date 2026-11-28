# Paired endpoints, with connection state as reported by Windows.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)

function Get-DeviceKey([string]$Address, [string]$Id) {
    $key = $Address -replace '[:-]', ''
    if ($key -match '^[0-9A-Fa-f]{12}$') { return $key.ToUpperInvariant() }
    if ($Id -match '(?i)(?:DEV_|[:#])([0-9A-F]{12})(?:\\|$)') { return $Matches[1].ToUpperInvariant() }
    return $Id
}

$results = @{}
$queried = $false
try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $info = [Windows.Devices.Enumeration.DeviceInformation,Windows.Devices.Enumeration,ContentType=WindowsRuntime]
    $list = [Windows.Devices.Enumeration.DeviceInformationCollection,Windows.Devices.Enumeration,ContentType=WindowsRuntime]
    $endpoint = [Windows.Devices.Enumeration.DeviceInformationKind,Windows.Devices.Enumeration,ContentType=WindowsRuntime]::AssociationEndpoint
    $classic = [Windows.Devices.Bluetooth.BluetoothDevice,Windows.Devices.Bluetooth,ContentType=WindowsRuntime]
    $lowEnergy = [Windows.Devices.Bluetooth.BluetoothLEDevice,Windows.Devices.Bluetooth,ContentType=WindowsRuntime]
    $asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
        $_.Name -eq 'AsTask' -and $_.IsGenericMethod -and $_.GetParameters().Length -eq 1
    } | Select-Object -First 1
    [string[]]$properties = 'System.Devices.Aep.IsConnected','System.Devices.Aep.DeviceAddress'
    foreach ($protocol in @($classic, $lowEnergy)) {
        try {
            $selector = $protocol::GetDeviceSelectorFromPairingState($true)
            $query = $info::FindAllAsync($selector, $properties, $endpoint)
            $task = $asTask.MakeGenericMethod($list).Invoke($null, @($query))
            if (!$task.Wait(3200)) { continue }
            $queried = $true
            foreach ($device in $task.Result) {
                $name = ($device.Name -replace '[\r\n|]', ' ').Trim()
                if (!$name) { continue }
                $address = [string]$device.Properties['System.Devices.Aep.DeviceAddress']
                $key = Get-DeviceKey -Address $address -Id $device.Id
                $state = $device.Properties['System.Devices.Aep.IsConnected']
                $connected = if ($null -eq $state) { -1 } elseif ($state) { 1 } else { 0 }
                if (!$results.ContainsKey($key) -or $connected -gt $results[$key].Connection) {
                    $results[$key] = @{ Name = $name; Connection = $connected; Battery = -1 }
                }
            }
        } catch { }
    }
} catch { }

try {
    $pnp = @(Get-PnpDevice -Class Bluetooth | Where-Object { $_.InstanceId -match '^BTH(?:ENUM|LE)\\DEV_' })
    $canFallback = !$queried
    $queried = $true
    foreach ($device in $pnp) {
        $key = Get-DeviceKey -Address '' -Id $device.InstanceId
        if (!$results.ContainsKey($key)) {
            $name = ($device.FriendlyName -replace '[\r\n|]', ' ').Trim()
            if (!$canFallback -or !$name) { continue }
            $results[$key] = @{ Name = $name; Connection = -1; Battery = -1 }
        }
        $property = Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
        $battery = -1
        if ($property -and [int]::TryParse([string]$property.Data, [ref]$battery) -and $battery -ge 0 -and $battery -le 100) {
            $results[$key].Battery = $battery
        }
    }
} catch { }

if (!$queried) { [Console]::Out.Write('STATUS=ERROR'); return }
$rows = @($results.Values | Sort-Object -Property @{Expression = {$_.Connection}; Descending = $true}, @{Expression = {$_.Name}})
$active = @($rows | Where-Object { $_.Connection -eq 1 }).Count
$unknown = @($rows | Where-Object { $_.Connection -lt 0 }).Count
$out = @("COUNT=$active|$($rows.Count)|$unknown")
for ($i = 0; $i -lt [Math]::Min(3, $rows.Count); $i++) {
    $row = $rows[$i]
    $out += "DEV$($i + 1)=$($row.Name)|$($row.Connection)|$($row.Battery)"
}
[Console]::Out.Write($out -join [Environment]::NewLine)
