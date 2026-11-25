param(
  [ValidateSet("Wallpaper", "Accent")]
  [string]$Source = "Wallpaper",
  [switch]$ApplyToActive
)

# MaterialYZen AutoSync.ps1
# Inspirado en slukedev/meterial-you (MIT), adaptado sin DLLs externos para Rainmeter.
# Extrae el color real del wallpaper (con detección monocromática para fondos grises/negros/blancos)
# o del acento de Windows 11, y genera Auto_Dark.inc y Auto_Light.inc.

Add-Type -AssemblyName System.Drawing

$scriptDir = $PSScriptRoot
$resDir = Split-Path -Parent $scriptDir
$palDir = Join-Path $resDir "Palettes"
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

function Rgba([double]$h, [double]$s, [double]$l, [int]$a = 255) {
  $c = HslToRgb $h $s $l
  return "$($c[0]),$($c[1]),$($c[2]),$a"
}

function Get-AccentSeed {
  try {
    $dwm = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -ErrorAction Stop
    $raw = $dwm.AccentColor
    if ($null -eq $raw) { throw "AccentColor missing" }
    $val = if ($raw -lt 0) { [BitConverter]::ToUInt32([BitConverter]::GetBytes([int]$raw), 0) } else { [uint32]$raw }
    $r = $val -band 0xFF
    $g = ($val -shr 8) -band 0xFF
    $b = ($val -shr 16) -band 0xFF
    $hsl = RgbToHsl $r $g $b
    return @{ h = $hsl[0]; s = $hsl[1]; monochrome = ($hsl[1] -lt 0.12) }
  } catch {
    return @{ h = 215.0; s = 0.55; monochrome = $false }
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
    $totalPx = 0
    $chromaPx = 0
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
            $buckets[$hueBin].score += $score
            $buckets[$hueBin].r += $px.R
            $buckets[$hueBin].g += $px.G
            $buckets[$hueBin].b += $px.B
            $buckets[$hueBin].n += 1
          } else {
            $buckets[$hueBin] = @{ score = $score; r = [double]$px.R; g = [double]$px.G; b = [double]$px.B; n = 1 }
          }
        }
      }
    }

    # Si menos del 8% del fondo tiene color real -> fondo gris/monocromatico (NO forzar azul)
    $chromaRatio = if ($totalPx -gt 0) { $chromaPx / [double]$totalPx } else { 0.0 }
    if ($chromaRatio -lt 0.08 -or $buckets.Count -eq 0) {
      return @{ h = 0.0; s = 0.0; monochrome = $true }
    }

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
  $normalized = [regex]::Replace($content, "\r?\n", "`r`n")
  $tmp = "$path.tmp"
  try {
    [System.IO.File]::WriteAllText($tmp, $normalized, $enc)
    Move-Item -LiteralPath $tmp -Destination $path -Force
  } finally {
    if (Test-Path -LiteralPath $tmp) {
      Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
  }
}

$seed = if ($Source -eq "Accent") { Get-AccentSeed } else { Get-WallpaperSeed }

if ($seed.monochrome) {
  $h = 220.0
  $darkInc = @"
[Variables]
; Paleta: Auto ($Source — Monocromatico/Gris) — Modo Oscuro
PaletteName=Auto
ModeLabel=Oscuro
OppositeMode=Light
ActiveSwatchX=272

Surface=24,24,27,238
SurfaceContainer=39,39,42,245
Primary=228,228,231,255
OnPrimary=24,24,27,255
PrimaryContainer=63,63,70,255
OnPrimaryContainer=244,244,245,255
Secondary=161,161,170,255
Outline=113,113,122,220
OutlineVariant=63,63,70,180
OnSurface=244,244,245,255
OnSurfaceVariant=161,161,170,255
"@

  $lightInc = @"
[Variables]
; Paleta: Auto ($Source — Monocromatico/Gris) — Modo Claro
PaletteName=Auto
ModeLabel=Claro
OppositeMode=Dark
ActiveSwatchX=272

Surface=250,250,250,242
SurfaceContainer=235,235,238,248
Primary=39,39,42,255
OnPrimary=250,250,250,255
PrimaryContainer=218,218,223,255
OnPrimaryContainer=24,24,27,255
Secondary=82,82,91,255
Outline=138,138,148,220
OutlineVariant=200,200,208,180
OnSurface=24,24,27,255
OnSurfaceVariant=82,82,91,255
"@
} else {
  $h = $seed.h
  $s = [Math]::Max(0.26, [Math]::Min(0.72, $seed.s))

  $darkInc = @"
[Variables]
; Paleta: Auto ($Source) — Modo Oscuro (generada dinamicamente)
PaletteName=Auto
ModeLabel=Oscuro
OppositeMode=Light
ActiveSwatchX=272

Surface=$(Rgba $h ($s * 0.32) 0.10 238)
SurfaceContainer=$(Rgba $h ($s * 0.34) 0.16 245)
Primary=$(Rgba $h ($s * 0.92) 0.78 255)
OnPrimary=$(Rgba $h ($s * 0.85) 0.18 255)
PrimaryContainer=$(Rgba $h ($s * 0.65) 0.28 255)
OnPrimaryContainer=$(Rgba $h ($s * 0.90) 0.90 255)
Secondary=$(Rgba $h ($s * 0.38) 0.76 255)
Outline=$(Rgba $h ($s * 0.48) 0.56 225)
OutlineVariant=$(Rgba $h ($s * 0.34) 0.30 185)
OnSurface=$(Rgba $h ($s * 0.22) 0.92 255)
OnSurfaceVariant=$(Rgba $h ($s * 0.24) 0.72 255)
"@

  $lightInc = @"
[Variables]
; Paleta: Auto ($Source) — Modo Claro (generada dinamicamente)
PaletteName=Auto
ModeLabel=Claro
OppositeMode=Dark
ActiveSwatchX=272

Surface=$(Rgba $h ($s * 0.45) 0.97 244)
SurfaceContainer=$(Rgba $h ($s * 0.42) 0.92 248)
Primary=$(Rgba $h ($s * 0.78) 0.36 255)
OnPrimary=255,255,255,255
PrimaryContainer=$(Rgba $h ($s * 0.78) 0.89 255)
OnPrimaryContainer=$(Rgba $h ($s * 0.82) 0.18 255)
Secondary=$(Rgba $h ($s * 0.34) 0.38 255)
Outline=$(Rgba $h ($s * 0.46) 0.54 225)
OutlineVariant=$(Rgba $h ($s * 0.36) 0.82 190)
OnSurface=$(Rgba $h ($s * 0.28) 0.12 255)
OnSurfaceVariant=$(Rgba $h ($s * 0.24) 0.34 255)
"@
}

Write-Utf16Ini (Join-Path $palDir "Auto_Dark.inc") $darkInc
Write-Utf16Ini (Join-Path $palDir "Auto_Light.inc") $lightInc

if ($ApplyToActive -and (Test-Path -LiteralPath $varsFile -PathType Leaf)) {
  $varsText = [System.IO.File]::ReadAllText($varsFile)
  $varsText = [regex]::Replace($varsText, "(?m)^ThemeColor=[^\r\n]*", "ThemeColor=Auto")
  if ($Source -eq "Accent") {
    try {
      $lightTheme = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -ErrorAction Stop).AppsUseLightTheme
      $mode = if ($lightTheme -eq 1) { "Light" } else { "Dark" }
      $varsText = [regex]::Replace($varsText, "(?m)^ThemeMode=[^\r\n]*", "ThemeMode=$mode")
    } catch {}
  }
  Write-Utf16Ini $varsFile $varsText
}

$tag = if ($seed.monochrome) { "MONOCHROME" } else { "H=$([int]$h)" }
Write-Output "AUTO_SYNC_OK ($Source -> $tag)"
