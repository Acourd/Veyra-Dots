param(
  [ValidateSet("Wallpaper", "Accent")]
  [string]$Source = "Wallpaper",
  [switch]$ApplyToActive
)

# OneUIZen AutoSync.ps1
# Extrae el acento vibrante de tu fondo de pantalla (con detección monocromática para fondos grises)
# o del acento de Windows 11, y genera @Resources\Accents\Auto.inc.

Add-Type -AssemblyName System.Drawing

$scriptDir = $PSScriptRoot
$resDir = Split-Path -Parent $scriptDir
$accDir = Join-Path $resDir "Accents"
$varsFile = Join-Path $resDir "Variables.inc"

function RgbToHsl([int]$r, [int]$g, [int]$b) {
  $rf = $r / 255.0; $gf = $g / 255.0; $bf = $b / 255.0
  $max = [Math]::Max($rf, [Math]::Max($gf, $bf))
  $min = [Math]::Min($rf, [Math]::Min($gf, $bf))
  $l = ($max + $min) / 2.0
  $d = $max - $min
  if ($d -eq 0) { return @(0.0, 0.0, $l) }
  $s = if ($l -gt 0.5) { $d / (2.0 - $max - $min) } else { $d / ($max + $min) }
  if ($max -eq $rf) { $h = (($gf - $bf) / $d) + $(if ($gf -lt $bf) { 6.0 } else { 0.0 }) }
  elseif ($max -eq $gf) { $h = (($bf - $rf) / $d) + 2.0 }
  else { $h = (($rf - $gf) / $d) + 4.0 }
  $h = ($h / 6.0) * 360.0
  return @($h, $s, $l)
}

function HslToRgb([double]$h, [double]$s, [double]$l) {
  $h = (($h % 360) + 360) % 360
  $s = [Math]::Max(0.0, [Math]::Min(1.0, $s))
  $l = [Math]::Max(0.0, [Math]::Min(1.0, $l))
  $c = (1.0 - [Math]::Abs(2.0 * $l - 1.0)) * $s
  $x = $c * (1.0 - [Math]::Abs((($h / 60.0) % 2.0) - 1.0))
  $m = $l - $c / 2.0
  if ($h -lt 60) { $r1=$c; $g1=$x; $b1=0 }
  elseif ($h -lt 120) { $r1=$x; $g1=$c; $b1=0 }
  elseif ($h -lt 180) { $r1=0; $g1=$c; $b1=$x }
  elseif ($h -lt 240) { $r1=0; $g1=$x; $b1=$c }
  elseif ($h -lt 300) { $r1=$x; $g1=0; $b1=$c }
  else { $r1=$c; $g1=0; $b1=$x }
  return @(
    [Math]::Max(0, [Math]::Min(255, [int][Math]::Round(($r1 + $m) * 255))),
    [Math]::Max(0, [Math]::Min(255, [int][Math]::Round(($g1 + $m) * 255))),
    [Math]::Max(0, [Math]::Min(255, [int][Math]::Round(($b1 + $m) * 255)))
  )
}

function Get-AccentSeed {
  try {
    $dwm = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -ErrorAction Stop
    $raw = $dwm.AccentColor
    if ($null -eq $raw) { throw "AccentColor missing" }
    $val = if ($raw -lt 0) { [BitConverter]::ToUInt32([BitConverter]::GetBytes([int]$raw), 0) } else { [uint32]$raw }
    $hsl = RgbToHsl ($val -band 0xFF) (($val -shr 8) -band 0xFF) (($val -shr 16) -band 0xFF)
    return @{ h = $hsl[0]; s = $hsl[1]; monochrome = ($hsl[1] -lt 0.12) }
  } catch {
    return @{ h = 217.0; s = 0.85; monochrome = $false }
  }
}

function Get-WallpaperSeed {
  $bmp = $null
  $ms = $null
  try {
    $candidates = @()
    try {
      $wp = (Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallPaper -ErrorAction Stop).WallPaper
      if ($wp -and (Test-Path -LiteralPath $wp -PathType Leaf)) { $candidates += $wp }
    } catch {}
    if ($env:APPDATA) {
      $tc = Join-Path $env:APPDATA "Microsoft\Windows\Themes\TranscodedWallpaper"
      if ((Test-Path -LiteralPath $tc -PathType Leaf) -and ($candidates -notcontains $tc)) { $candidates += $tc }
    }
    if ($candidates.Count -eq 0) { return Get-AccentSeed }

    foreach ($cand in $candidates) {
      try {
        $imgBytes = [System.IO.File]::ReadAllBytes($cand)
        $ms = New-Object System.IO.MemoryStream(,$imgBytes)
        $bmp = [System.Drawing.Bitmap]::FromStream($ms)
        break
      } catch {
        if ($bmp) { $bmp.Dispose(); $bmp = $null }
        if ($ms) { $ms.Dispose(); $ms = $null }
      }
    }
    if (-not $bmp) { return Get-AccentSeed }
    $buckets = @{}
    $totalPx = 0; $chromaPx = 0
    $stepX = [Math]::Max(1, [int]($bmp.Width / 48))
    $stepY = [Math]::Max(1, [int]($bmp.Height / 48))
    for ($x = 0; $x -lt $bmp.Width; $x += $stepX) {
      for ($y = 0; $y -lt $bmp.Height; $y += $stepY) {
        $px = $bmp.GetPixel($x, $y)
        $totalPx++
        $hsl = RgbToHsl $px.R $px.G $px.B
        if ($hsl[1] -ge 0.16 -and $hsl[2] -ge 0.10 -and $hsl[2] -le 0.90) {
          $chromaPx++
          $hueBin = [int]([Math]::Floor($hsl[0] / 12.0) * 12)
          $score = 1.0 + ($hsl[1] * 2.5)
          if ($buckets.ContainsKey($hueBin)) {
            $buckets[$hueBin].score += $score; $buckets[$hueBin].r += $px.R; $buckets[$hueBin].g += $px.G; $buckets[$hueBin].b += $px.B; $buckets[$hueBin].n += 1
          } else {
            $buckets[$hueBin] = @{ score = $score; r = [double]$px.R; g = [double]$px.G; b = [double]$px.B; n = 1 }
          }
        }
      }
    }
    $ratio = if ($totalPx -gt 0) { $chromaPx / [double]$totalPx } else { 0.0 }
    if ($ratio -lt 0.08 -or $buckets.Count -eq 0) { return @{ h = 0.0; s = 0.0; monochrome = $true } }
    $best = $buckets.Values | Sort-Object -Property score -Descending | Select-Object -First 1
    $avgHsl = RgbToHsl ([int]($best.r / $best.n)) ([int]($best.g / $best.n)) ([int]($best.b / $best.n))
    return @{ h = $avgHsl[0]; s = $avgHsl[1]; monochrome = $false }
  } catch {
    return Get-AccentSeed
  } finally {
    if ($bmp) { $bmp.Dispose() }
    if ($ms) { $ms.Dispose() }
  }
}

function Write-Utf16Ini([string]$path, [string]$content) {
  $dir = Split-Path -Parent $path
  if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $enc = New-Object System.Text.UnicodeEncoding($false, $true)
  $tmp = "$path.tmp"
  try {
    [System.IO.File]::WriteAllText($tmp, ([regex]::Replace($content, "\r?\n", "`r`n")), $enc)
    Move-Item -LiteralPath $tmp -Destination $path -Force
  } finally {
    if (Test-Path -LiteralPath $tmp) {
      Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
  }
}

$seed = if ($Source -eq "Accent") { Get-AccentSeed } else { Get-WallpaperSeed }

if ($seed.monochrome) {
  $autoInc = @"
[Variables]
; Acento Auto (Monocromatico/Gris)
Accent=113,118,128,255
AccentSoft=113,118,128,48
ActiveDotX=254
"@
} else {
  $h = $seed.h
  $s = [Math]::Max(0.55, [Math]::Min(0.88, $seed.s))
  $rgb = HslToRgb $h $s 0.54
  $autoInc = @"
[Variables]
; Acento Auto ($Source -> H=$([int]$h))
Accent=$($rgb[0]),$($rgb[1]),$($rgb[2]),255
AccentSoft=$($rgb[0]),$($rgb[1]),$($rgb[2]),48
ActiveDotX=254
"@
}

Write-Utf16Ini (Join-Path $accDir "Auto.inc") $autoInc

if ($ApplyToActive -and (Test-Path -LiteralPath $varsFile -PathType Leaf)) {
  $varsText = [System.IO.File]::ReadAllText($varsFile)
  $varsText = [regex]::Replace($varsText, "(?m)^AccentName=[^\r\n]*", "AccentName=Auto")
  Write-Utf16Ini $varsFile $varsText
}

Write-Output "ONEUI_AUTO_OK ($Source)"
