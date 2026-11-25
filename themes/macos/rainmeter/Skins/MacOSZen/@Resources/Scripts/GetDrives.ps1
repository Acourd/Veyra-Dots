# Veyra-Dots — Native Windows Multi-Drive Storage Array Query (Zero external DLLs)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

try {
  $disks = @([System.IO.DriveInfo]::GetDrives() |
    Where-Object {
      ($_.DriveType -eq [System.IO.DriveType]::Fixed -or $_.DriveType -eq [System.IO.DriveType]::Removable) -and
      $_.IsReady -and $_.TotalSize -gt 0
    } | Sort-Object -Property Name)

  $lines = @("COUNT=$($disks.Count)")
  $idx = 1
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
      $lines += "DRV$idx=$id|$label|$kind|$usedGB|$totalGB|$freeGB|$pct"
      $idx++
    } catch {}
  }

  [Console]::Out.Write(($lines -join "`n"))
} catch {
  [Console]::Out.Write("COUNT=0")
}
