# Veyra-Dots — Native Windows Multi-Drive Storage Array Query (Zero external DLLs)
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

try {
  $disks = @([System.IO.DriveInfo]::GetDrives() |
    Where-Object {
      try {
        ($_.DriveType -eq [System.IO.DriveType]::Fixed -or $_.DriveType -eq [System.IO.DriveType]::Removable) -and
        $_.IsReady -and $_.TotalSize -gt 0
      } catch { $false }
    } | Sort-Object -Property Name)

  $entries = @()
  foreach ($d in ($disks | Select-Object -First 4)) {
    try {
      $id = $d.Name.TrimEnd('\')
      $rawLabel = $d.VolumeLabel
      $label = if ($rawLabel) { ($rawLabel -replace '[\r\n|]', ' ').Trim() } else { "Local Disk" }
      if (-not $label) { $label = "Local Disk" }
      $kind = if ($d.DriveType -eq [System.IO.DriveType]::Removable) { "USB" } else { "SSD" }
      $totalGB = [math]::Round($d.TotalSize / 1GB, 0)
      $freeGB = [math]::Round($d.AvailableFreeSpace / 1GB, 0)
      $usedGB = [math]::Max(0, $totalGB - $freeGB)
      $pct = [math]::Max(0, [math]::Min(100, [math]::Round((($d.TotalSize - $d.AvailableFreeSpace) / [double]$d.TotalSize) * 100, 0)))
      $entries += "$id|$label|$kind|$usedGB|$totalGB|$freeGB|$pct"
    } catch {}
  }

  $totalCount = if ($disks.Count -gt 4) { $disks.Count } else { $entries.Count }
  $lines = @("COUNT=$totalCount")
  for ($i = 0; $i -lt $entries.Count; $i++) {
    $lines += "DRV$($i + 1)=$($entries[$i])"
  }

  [Console]::Out.Write(($lines -join "`n"))
} catch {
  [Console]::Out.Write("COUNT=0")
}
