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

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$muelleIcons = Join-Path $env:LOCALAPPDATA "Muelle\icons"
$backupDir = Join-Path $env:LOCALAPPDATA "Muelle\icons_backup"
$muelleExe = Join-Path $env:LOCALAPPDATA "Programs\Muelle\muelle.exe"

if (-not (Test-Path $muelleIcons)) {
    Write-Error "No se encontro la carpeta de iconos de Muelle en: $muelleIcons"
    exit 1
}

function Restart-Muelle {
    $procs = Get-Process -Name "muelle" -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 600
    }
    if (Test-Path $muelleExe) {
        Start-Process -FilePath $muelleExe
        Write-Host "Muelle reiniciado con los iconos actualizados." -ForegroundColor Cyan
    }
}

if ($Restore) {
    if (-not (Test-Path $backupDir)) {
        Write-Error "No existe copia de seguridad en: $backupDir"
        exit 1
    }
    Copy-Item (Join-Path $backupDir "*.bin") $muelleIcons -Force
    Restart-Muelle
    Write-Host "Iconos originales de Muelle restaurados." -ForegroundColor Green
    exit 0
}

# Crear backup automatico la primera vez
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-Item (Join-Path $muelleIcons "*.bin") $backupDir -Force
    Write-Host "Respaldo original guardado en: $backupDir" -ForegroundColor DarkGray
}

$variantFolder = switch ($Theme) {
    "one-ui"       { if ($Variant -eq "dark") { "oneui-dark" } else { "oneui-vibrant" } }
    "material-you" { "m3-pastel" }
}
$pngDir = Join-Path $repoRoot "themes\$Theme\icons\$variantFolder\png"
if (-not (Test-Path $pngDir)) {
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
    @{ pattern = "Hone";                                 slug = "hone" },
    @{ pattern = "Discord";                              slug = "discord" },
    @{ pattern = "Edge";                                 slug = "edge" },
    @{ pattern = "Chrome";                               slug = "chrome" },
    @{ pattern = "Linear";                               slug = "linear" },
    @{ pattern = "Steam";                                slug = "steam" },
    @{ pattern = "OBS";                                  slug = "obs-studio" },
    @{ pattern = "Visual Studio Code|VS Code";           slug = "vscode" },
    @{ pattern = "Spotify";                              slug = "spotify" },
    @{ pattern = "Obsidian";                             slug = "obsidian" },
    @{ pattern = "Docker";                               slug = "docker" },
    @{ pattern = "FxSound";                              slug = "fxsound" },
    @{ pattern = "Malwarebytes";                         slug = "malwarebytes" },
    @{ pattern = "ExitLag";                              slug = "exitlag" },
    @{ pattern = "Valorant";                             slug = "valorant" },
    @{ pattern = "Riot";                                 slug = "riot-client" },
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
    $pxOff = 24 + $nLen
    if ($orig.Length -ne ($pxOff + $w * $h * 4)) { return $false }

    $src = $null
    $resized = $null
    $g = $null
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
        $pxBytes = New-Object byte[] ($w * $h * 4)
        [System.Runtime.InteropServices.Marshal]::Copy($bd.Scan0, $pxBytes, 0, $pxBytes.Length)
        $resized.UnlockBits($bd)
    } finally {
        if ($g) { $g.Dispose() }
        if ($src) { $src.Dispose() }
        if ($resized) { $resized.Dispose() }
    }

    $out = New-Object byte[] $orig.Length
    [Array]::Copy($orig, 0, $out, 0, $pxOff)
    [Array]::Copy($pxBytes, 0, $out, $pxOff, $pxBytes.Length)
    [System.IO.File]::WriteAllBytes($binPath, $out)
    return $true
}

$applied = 0
$bins = Get-ChildItem $muelleIcons -Filter "*-256.bin"
foreach ($bin in $bins) {
    $bytes = [System.IO.File]::ReadAllBytes($bin.FullName)
    if ($bytes.Length -lt 28) { continue }
    $magic = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
    if ($magic -ne "WDI2") { continue }
    $nLen = [BitConverter]::ToUInt32($bytes, 20)
    if ((24 + $nLen) -gt $bytes.Length) { continue }
    $name = [System.Text.Encoding]::UTF8.GetString($bytes, 24, $nLen)

    $slug = $null
    if ($name -match "Papelera|Recycle Bin") {
        # Distinguir Papelera vacia vs llena usando siempre el respaldo original (inmune a cambios repetidos de variante)
        $refPath = Join-Path $backupDir $bin.Name
        $refBytes = if (Test-Path $refPath) { [System.IO.File]::ReadAllBytes($refPath) } else { $bytes }
        $pxOff = 24 + $nLen
        $centerAlpha = $refBytes[$pxOff + (128 * 256 + 128) * 4 + 3]
        $slug = if ($centerAlpha -gt 200) { "trash-full" } else { "trash-empty" }
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
        if (Test-Path $pngPath) {
            if (Write-PngIntoWdi2 $bin.FullName $pngPath) {
                Write-Host "  [OK] $name -> $slug.png" -ForegroundColor Green
                $applied++
            }
        }
    }
}

Write-Host "Aplicados $applied iconos ($Theme / $Variant) en Muelle." -ForegroundColor Cyan
Restart-Muelle
