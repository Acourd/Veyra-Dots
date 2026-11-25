param(
    [ValidateSet("one-ui", "material-you")]
    [string]$Theme = "material-you",
    [ValidateSet("vibrant", "dark")]
    [string]$Variant = "dark",
    [ValidateSet("All", "Desktop", "Taskbar")]
    [string]$Scope = "All",
    [switch]$RestartExplorer,
    [switch]$Restore
)

# Aplicador seguro y reversible de iconos (.ico) para el Escritorio y la Barra de Tareas nativa de Windows 11
# - Guarda respaldo automatico de IconLocation original en %LOCALAPPDATA%\VeyraDots\windows-icons-backup.json
# - Copia los .ico a %LOCALAPPDATA%\VeyraDots\icons\ para que los accesos directos nunca pierdan su icono si mueves el repo
# - Actualiza accesos directos .lnk del Escritorio del usuario y/o de la Barra de Tareas fijada (TaskBar)
# - Usa -Restore para revertir todo al estado original

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$stateDir = Join-Path $env:LOCALAPPDATA "VeyraDots"
$backupFile = Join-Path $stateDir "windows-icons-backup.json"
$desktopDir = [Environment]::GetFolderPath("Desktop")
$taskbarDir = Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

$wsh = New-Object -ComObject WScript.Shell

function Refresh-ShellIcons {
    $ie4u = Join-Path $env:WINDIR "System32\ie4uinit.exe"
    if (Test-Path $ie4u) {
        & $ie4u -show | Out-Null
    }
    if ($RestartExplorer) {
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 700
        Start-Process "explorer.exe"
        Write-Host "Explorador de Windows reiniciado para refrescar la barra de tareas." -ForegroundColor Cyan
    } else {
        Write-Host "Cache de iconos refrescada. Si la barra de tareas aun muestra algun icono anterior, ejecuta con -RestartExplorer o cierra sesion." -ForegroundColor DarkGray
    }
}

if ($Restore) {
    if (-not (Test-Path $backupFile)) {
        Write-Error "No existe copia de seguridad previa en: $backupFile"
        exit 1
    }
    $saved = Get-Content -Path $backupFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $restored = 0
    foreach ($prop in $saved.PSObject.Properties) {
        $lnkPath = $prop.Name
        $origIcon = [string]$prop.Value
        if (Test-Path $lnkPath) {
            try {
                $sc = $wsh.CreateShortcut($lnkPath)
                $sc.IconLocation = $origIcon
                $sc.Save()
                Write-Host "  [RESTAURADO] $(Split-Path -Leaf $lnkPath)" -ForegroundColor Green
                $restored++
            } catch {
                Write-Warning "No se pudo restaurar '$lnkPath': $_"
            }
        }
    }
    Write-Host "Restaurados $restored accesos directos a sus iconos originales." -ForegroundColor Cyan
    Refresh-ShellIcons
    exit 0
}

$variantFolder = switch ($Theme) {
    "one-ui"       { if ($Variant -eq "dark") { "oneui-dark" } else { "oneui-vibrant" } }
    "material-you" { "m3-pastel" }
}
$srcIcoDir = Join-Path $repoRoot "themes\$Theme\icons\$variantFolder\ico"
if (-not (Test-Path $srcIcoDir)) {
    Write-Error "No se encontraron iconos .ico en: $srcIcoDir"
    exit 1
}

# Copiar los .ico a una ruta estable en %LOCALAPPDATA%\VeyraDots\icons\
$stableIcoDir = Join-Path $stateDir "icons\$variantFolder"
New-Item -ItemType Directory -Path $stableIcoDir -Force | Out-Null
Copy-Item (Join-Path $srcIcoDir "*.ico") $stableIcoDir -Force

# Cargar o inicializar mapa de respaldo
$backupMap = @{}
if (Test-Path $backupFile) {
    $existing = Get-Content -Path $backupFile -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($prop in $existing.PSObject.Properties) {
        $backupMap[$prop.Name] = [string]$prop.Value
    }
}

# Reglas de mapeo por nombre de acceso directo (.lnk)
$NameMap = @(
    @{ pattern = "Explorador|File Explorer";            slug = "explorer" },
    @{ pattern = "Descargas|Downloads";                 slug = "downloads" },
    @{ pattern = "Helium";                              slug = "helium" },
    @{ pattern = "Claude";                              slug = "claude" },
    @{ pattern = "ChatGPT";                             slug = "chatgpt" },
    @{ pattern = "Gemini";                              slug = "gemini" },
    @{ pattern = "Perplexity";                          slug = "perplexity" },
    @{ pattern = "Antigravity";                         slug = "antigravity" },
    @{ pattern = "Rainmeter";                           slug = "rainmeter" },
    @{ pattern = "Configuraci|Settings";                slug = "settings" },
    @{ pattern = "Bloc de notas|Notepad";               slug = "notepad" },
    @{ pattern = "7-Zip";                               slug = "7-zip" },
    @{ pattern = "Hone";                                slug = "hone" },
    @{ pattern = "Discord";                             slug = "discord" },
    @{ pattern = "Edge";                                slug = "edge" },
    @{ pattern = "Chrome";                              slug = "chrome" },
    @{ pattern = "Gmail";                               slug = "gmail" },
    @{ pattern = "GitHub";                              slug = "github" },
    @{ pattern = "Linear";                              slug = "linear" },
    @{ pattern = "Steam";                               slug = "steam" },
    @{ pattern = "OBS";                                 slug = "obs-studio" },
    @{ pattern = "Visual Studio Code|VS Code|VSCode";   slug = "vscode" },
    @{ pattern = "Spotify";                             slug = "spotify" },
    @{ pattern = "Obsidian";                            slug = "obsidian" },
    @{ pattern = "Docker";                              slug = "docker" },
    @{ pattern = "FxSound";                             slug = "fxsound" },
    @{ pattern = "Malwarebytes";                        slug = "malwarebytes" },
    @{ pattern = "Mem Reduct";                          slug = "mem-reduct" },
    @{ pattern = "ExitLag";                             slug = "exitlag" },
    @{ pattern = "Valorant";                            slug = "valorant" },
    @{ pattern = "Riot";                                slug = "riot-client" },
    @{ pattern = "Epic Games";                          slug = "epic-games" },
    @{ pattern = "Fortnite";                            slug = "fortnite" },
    @{ pattern = "KovaaK|Kovack";                       slug = "kovaaks" },
    @{ pattern = "\bR\.E\.P\.O\b|\bREPO\b";             slug = "repo" },
    @{ pattern = "Thunderstore";                        slug = "thunderstore" },
    @{ pattern = "Git Bash";                            slug = "git" },
    @{ pattern = "Terminal|Windows Terminal|PowerShell";slug = "terminal" }
)

$targetDirs = @()
if ($Scope -in @("All", "Desktop") -and (Test-Path $desktopDir)) { $targetDirs += $desktopDir }
if ($Scope -in @("All", "Taskbar") -and (Test-Path $taskbarDir)) { $targetDirs += $taskbarDir }

$applied = 0
foreach ($dir in $targetDirs) {
    $label = if ($dir -eq $desktopDir) { "Desktop" } else { "Taskbar" }
    $links = Get-ChildItem -Path $dir -Filter "*.lnk" -File -ErrorAction SilentlyContinue
    foreach ($lnk in $links) {
        $baseName = $lnk.BaseName
        $slug = $null
        foreach ($rule in $NameMap) {
            if ($baseName -match $rule.pattern) {
                $slug = $rule.slug
                break
            }
        }
        if (-not $slug) { continue }

        $icoPath = Join-Path $stableIcoDir "$slug.ico"
        if (-not (Test-Path $icoPath)) { continue }

        try {
            $sc = $wsh.CreateShortcut($lnk.FullName)
            if (-not $backupMap.ContainsKey($lnk.FullName)) {
                $backupMap[$lnk.FullName] = [string]$sc.IconLocation
            }
            $sc.IconLocation = "$icoPath,0"
            $sc.Save()
            Write-Host "  [$label] $baseName -> $slug.ico" -ForegroundColor Green
            $applied++
        } catch {
            Write-Warning "No se pudo actualizar '$($lnk.FullName)': $_"
        }
    }
}

$backupMap | ConvertTo-Json -Depth 3 | Set-Content -Path $backupFile -Encoding UTF8
Write-Host "Aplicados $applied iconos ($Theme / $variantFolder · Scope: $Scope)." -ForegroundColor Cyan
Refresh-ShellIcons
