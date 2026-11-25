param(
    [ValidateSet("one-ui", "material-you")]
    [string]$Theme = "one-ui",
    [ValidateSet("vibrant", "dark")]
    [string]$Variant = "vibrant",
    [ValidateRange(0.90, 1.08)]
    [double]$Scale = 1.05,
    [switch]$Restore
)

# Aplicador seguro y reversible de iconos personalizados para Muelle (crafter-station/Muelle)
# - Crea copia de seguridad automatica en %LOCALAPPDATA%\Muelle\icons_backup la primera vez
# - Inyecta los PNG 256x256 en el formato WDI2 (BGRA top-down) preservando el header y mtime originales
# - Reinicia Muelle para aplicar los cambios en vivo

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $env:LOCALAPPDATA) {
    Write-Error "La variable de entorno LOCALAPPDATA no esta definida."
    exit 1
}
$muelleIcons = Join-Path $env:LOCALAPPDATA "Muelle\icons"
$backupDir = Join-Path $env:LOCALAPPDATA "Muelle\icons_backup"

if (-not (Test-Path -LiteralPath $muelleIcons)) {
    Write-Error "No se encontro la carpeta de iconos de Muelle en: $muelleIcons"
    exit 1
}

function Get-MuelleExePath {
    $proc = Get-Process -Name "muelle" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        try {
            if ($proc.Path -and (Test-Path -LiteralPath $proc.Path)) {
                return $proc.Path
            }
        } catch {}
    }
    $candidates = @()
    if ($env:LOCALAPPDATA) { $candidates += Join-Path $env:LOCALAPPDATA "Programs\Muelle\muelle.exe" }
    if ($env:ProgramFiles) { $candidates += Join-Path $env:ProgramFiles "Muelle\muelle.exe" }
    return ($candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1)
}

$script:MuelleExe = Get-MuelleExePath
$script:MuelleWasRunning = $false

function Stop-MuelleIfRunning {
    $procs = Get-Process -Name "muelle" -ErrorAction SilentlyContinue
    if ($procs) {
        $script:MuelleWasRunning = $true
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 600
    }
}

function Start-MuelleIfAvailable {
    if ($script:MuelleExe -and (Test-Path -LiteralPath $script:MuelleExe)) {
        Start-Process -FilePath $script:MuelleExe
        Write-Host "Muelle reiniciado con los iconos actualizados." -ForegroundColor Cyan
    } elseif ($script:MuelleWasRunning) {
        Write-Warning "No se encontro muelle.exe para reiniciarlo automaticamente; abre Muelle manualmente."
    }
}

if ($Restore) {
    if (-not (Test-Path -LiteralPath $backupDir)) {
        Write-Error "No existe copia de seguridad en: $backupDir"
        exit 1
    }
    $backupBins = Get-ChildItem -LiteralPath $backupDir -Filter "*.bin" -File -ErrorAction SilentlyContinue
    if (-not $backupBins) {
        Write-Error "La copia de seguridad en '$backupDir' no contiene archivos .bin."
        exit 1
    }
    Stop-MuelleIfRunning
    try {
        foreach ($b in $backupBins) {
            Copy-Item -LiteralPath $b.FullName -Destination (Join-Path $muelleIcons $b.Name) -Force
        }
        Write-Host "Iconos originales de Muelle restaurados ($($backupBins.Count) archivos)." -ForegroundColor Green
    } finally {
        Start-MuelleIfAvailable
    }
    exit 0
}

$variantFolder = switch ($Theme) {
    "one-ui"       { if ($Variant -eq "dark") { "oneui-dark" } else { "oneui-vibrant" } }
    "material-you" { "m3-pastel" }
}
$pngDir = Join-Path $repoRoot "themes\$Theme\icons\$variantFolder\png"
if (-not (Test-Path -LiteralPath $pngDir)) {
    Write-Error "No se encontraron iconos PNG en: $pngDir"
    exit 1
}

# Reglas de mapeo: patron sobre el nombre WDI2 -> slug PNG
$NameMap = @(
    @{ pattern = "Explorador|File Explorer|File Picker"; slug = "explorer" },
    @{ pattern = "Descargas|Downloads";                  slug = "downloads" },
    @{ pattern = "Helium";                               slug = "helium" },
    @{ pattern = "Claude";                               slug = "claude" },
    @{ pattern = "Antigravity";                          slug = "antigravity" },
    @{ pattern = "Rainmeter";                            slug = "rainmeter" },
    @{ pattern = "Configuraci|Settings";                 slug = "settings" },
    @{ pattern = "Bloc de notas|Notepad";                slug = "notepad" },
    @{ pattern = "7-Zip";                                slug = "7-zip" },
    @{ pattern = "\bHone\b";                             slug = "hone" },
    @{ pattern = "Discord";                              slug = "discord" },
    @{ pattern = "\bEdge\b";                             slug = "edge" },
    @{ pattern = "Chrome";                               slug = "chrome" },
    @{ pattern = "Linear";                               slug = "linear" },
    @{ pattern = "Steam";                                slug = "steam" },
    @{ pattern = "\bOBS\b";                              slug = "obs-studio" },
    @{ pattern = "Visual Studio Code|VS Code";           slug = "vscode" },
    @{ pattern = "Spotify";                              slug = "spotify" },
    @{ pattern = "Obsidian";                             slug = "obsidian" },
    @{ pattern = "Docker";                               slug = "docker" },
    @{ pattern = "FxSound";                              slug = "fxsound" },
    @{ pattern = "Malwarebytes";                         slug = "malwarebytes" },
    @{ pattern = "ExitLag";                              slug = "exitlag" },
    @{ pattern = "Valorant";                             slug = "valorant" },
    @{ pattern = "\bRiot\b";                             slug = "riot-client" },
    @{ pattern = "Epic Games";                           slug = "epic-games" },
    @{ pattern = "Fortnite";                             slug = "fortnite" },
    @{ pattern = "KovaaK";                               slug = "kovaaks" },
    @{ pattern = "\bR\.E\.P\.O\b|\bREPO\b";              slug = "repo" },
    @{ pattern = "Thunderstore";                         slug = "thunderstore" },
    @{ pattern = "ChatGPT";                              slug = "chatgpt" },
    @{ pattern = "Gemini";                               slug = "gemini" },
    @{ pattern = "Perplexity";                           slug = "perplexity" },
    @{ pattern = "Gmail";                                slug = "gmail" },
    @{ pattern = "GitHub";                               slug = "github" },
    @{ pattern = "Mem Reduct";                           slug = "mem-reduct" },
    @{ pattern = "Git Bash|Terminal|Windows Terminal";   slug = "terminal" },
    @{ pattern = "\bGit\b";                              slug = "git" }
)

function Write-PngIntoWdi2([string]$binPath, [string]$pngPath) {
    $orig = [System.IO.File]::ReadAllBytes($binPath)
    if ($orig.Length -lt 28) { return $false }
    $magic = [System.Text.Encoding]::ASCII.GetString($orig, 0, 4)
    if ($magic -ne "WDI2") { return $false }

    $w = [BitConverter]::ToUInt32($orig, 12)
    $h = [BitConverter]::ToUInt32($orig, 16)
    $nLen = [BitConverter]::ToUInt32($orig, 20)
    if ($w -eq 0 -or $h -eq 0 -or $w -gt 4096 -or $h -gt 4096) { return $false }
    [int64]$pxOff = 24 + [int64]$nLen
    [int64]$expectedLen = $pxOff + ([int64]$w * [int64]$h * 4)
    if ([int64]$orig.Length -ne $expectedLen) { return $false }

    $src = $null
    $resized = $null
    $g = $null
    $bd = $null
    try {
        $src = [System.Drawing.Bitmap]::FromFile($pngPath)
        $resized = New-Object System.Drawing.Bitmap([int]$w, [int]$h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($resized)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $dw = [int][Math]::Round($w * $Scale)
        $dh = [int][Math]::Round($h * $Scale)
        $ox = [int][Math]::Round(($w - $dw) / 2.0)
        $oy = [int][Math]::Round(($h - $dh) / 2.0)
        $g.DrawImage($src, $ox, $oy, $dw, $dh)
        $g.Dispose(); $g = $null
        $src.Dispose(); $src = $null

        $rect = New-Object System.Drawing.Rectangle(0, 0, [int]$w, [int]$h)
        $bd = $resized.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $pxBytes = New-Object byte[] ([int]($w * $h * 4))
        [System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $pxBytes, 0, $pxBytes.Length)
    } finally {
        if ($bd -and $resized) { $resized.UnlockBits($bd) }
        if ($g) { $g.Dispose() }
        if ($src) { $src.Dispose() }
        if ($resized) { $resized.Dispose() }
    }

    $out = New-Object byte[] $orig.Length
    [Array]::Copy($orig, 0, $out, 0, [int]$pxOff)
    [Array]::Copy($pxBytes, 0, $out, [int]$pxOff, $pxBytes.Length)

    $tmpPath = "$binPath.tmp"
    try {
        [System.IO.File]::WriteAllBytes($tmpPath, $out)
        $moved = $false
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                Move-Item -LiteralPath $tmpPath -Destination $binPath -Force
                $moved = $true
                break
            } catch {
                if ($attempt -eq 3) { throw }
                Start-Sleep -Milliseconds (150 * $attempt)
            }
        }
        return $moved
    } finally {
        if (Test-Path -LiteralPath $tmpPath) {
            Remove-Item -LiteralPath $tmpPath -Force -ErrorAction SilentlyContinue
        }
    }
}

$applied = 0
Stop-MuelleIfRunning
try {
    # Backup incremental por archivo: guarda cada .bin original la primera vez sin sobrescribir respaldos previos
    if (-not (Test-Path -LiteralPath $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    $newBackups = 0
    Get-ChildItem -LiteralPath $muelleIcons -Filter "*.bin" -File -ErrorAction SilentlyContinue | ForEach-Object {
        $dstBak = Join-Path $backupDir $_.Name
        if (-not (Test-Path -LiteralPath $dstBak)) {
            Copy-Item -LiteralPath $_.FullName -Destination $dstBak -Force
            $newBackups++
        }
    }
    if ($newBackups -gt 0) {
        Write-Host "Respaldo original actualizado en: $backupDir (+$newBackups archivos)" -ForegroundColor DarkGray
    }

    $bins = Get-ChildItem -LiteralPath $muelleIcons -Filter "*-256.bin" -File -ErrorAction SilentlyContinue
    foreach ($bin in $bins) {
        $bytes = [System.IO.File]::ReadAllBytes($bin.FullName)
        if ($bytes.Length -lt 28) { continue }
        $magic = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
        if ($magic -ne "WDI2") { continue }
        $nLen = [BitConverter]::ToUInt32($bytes, 20)
        if ((24 + [int64]$nLen) -gt $bytes.Length) { continue }
        $name = [System.Text.Encoding]::UTF8.GetString($bytes, 24, [int]$nLen)

        $slug = $null
        if ($name -match "Papelera|Recycle Bin") {
            # Distinguir Papelera vacia vs llena usando siempre el respaldo original (inmune a cambios repetidos de variante)
            $refPath = Join-Path $backupDir $bin.Name
            $refBytes = if (Test-Path -LiteralPath $refPath) { [System.IO.File]::ReadAllBytes($refPath) } else { $bytes }
            $slug = "trash-empty"
            if ($refBytes.Length -ge 28 -and ([System.Text.Encoding]::ASCII.GetString($refBytes, 0, 4) -eq "WDI2")) {
                $rw = [BitConverter]::ToUInt32($refBytes, 12)
                $rh = [BitConverter]::ToUInt32($refBytes, 16)
                $rnLen = [BitConverter]::ToUInt32($refBytes, 20)
                if ($rw -gt 0 -and $rh -gt 0 -and $rw -le 4096 -and $rh -le 4096) {
                    [int64]$rPxOff = 24 + [int64]$rnLen
                    [int64]$cx = [int]($rw / 2)
                    [int64]$cy = [int]($rh / 2)
                    [int64]$alphaIdx = $rPxOff + ($cy * [int64]$rw + $cx) * 4 + 3
                    if ($alphaIdx -lt $refBytes.Length -and $refBytes[$alphaIdx] -gt 200) {
                        $slug = "trash-full"
                    }
                }
            }
        } else {
            foreach ($rule in $NameMap) {
                if ($name -match $rule.pattern) {
                    $slug = $rule.slug
                    break
                }
            }
        }

        if ($slug) {
            $pngPath = Join-Path $pngDir "$slug.png"
            if (Test-Path -LiteralPath $pngPath) {
                if (Write-PngIntoWdi2 $bin.FullName $pngPath) {
                    Write-Host "  [OK] $name -> $slug.png" -ForegroundColor Green
                    $applied++
                }
            }
        }
    }
    Write-Host "Aplicados $applied iconos ($Theme / $variantFolder) en Muelle." -ForegroundColor Cyan
} finally {
    Start-MuelleIfAvailable
}
