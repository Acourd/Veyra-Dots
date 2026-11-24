# Veyra-Dots — Native Windows Multi-Drive Storage Array Query (Zero external DLLs)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$disks = Get-CimInstance Win32_LogicalDisk -ErrorAction SilentlyContinue |
  Where-Object { $_.DriveType -in 2, 3 -and $_.Size -gt 0 } |
  Sort-Object -Property DeviceID

$lines = @("COUNT=$(@($disks).Count)")
$idx = 1
foreach ($d in ($disks | Select-Object -First 4)) {
  $id = $d.DeviceID
  $label = if ($d.VolumeName) { ($d.VolumeName -replace '\|', ' ').Trim() } else { "Local Disk" }
  $kind = if ($d.DriveType -eq 2) { "USB" } else { "SSD" }
  $totalGB = [math]::Round($d.Size / 1GB, 0)
  $freeGB = [math]::Round($d.FreeSpace / 1GB, 0)
  $usedGB = [math]::Max(0, $totalGB - $freeGB)
  $pct = if ($d.Size -gt 0) { [math]::Round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 0) } else { 0 }
  $lines += "DRV$idx=$id|$label|$kind|$usedGB|$totalGB|$freeGB|$pct"
  $idx++
}

[Console]::Out.Write(($lines -join "`n"))
