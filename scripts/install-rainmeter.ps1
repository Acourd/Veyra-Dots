param(
  [ValidateSet("material-you", "one-ui", "macos", "glass", "nothing", "all")]
  [string]$Theme = "material-you"
)

# Instalador rápido de skins Rainmeter para cualquier tema en themes/<Theme>/rainmeter/Skins/ (o -Theme all)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RainmeterSkinsPath {
  if ($env:APPDATA) {
    $rmIni = Join-Path $env:APPDATA "Rainmeter\Rainmeter.ini"
    if (Test-Path -LiteralPath $rmIni -PathType Leaf) {
      try {
        $match = Select-String -LiteralPath $rmIni -Pattern '^\s*SkinPath\s*=\s*(.+?)\s*$' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) {
          $custom = [Environment]::ExpandEnvironmentVariables($match.Matches[0].Groups[1].Value.Trim().Trim('"'))
          if ($custom) { return $custom }
        }
      } catch {}
    }
  }
  $docs = [Environment]::GetFolderPath("MyDocuments")
  if (-not $docs -and $env:USERPROFILE) { $docs = Join-Path $env:USERPROFILE "Documents" }
  return Join-Path $docs "Rainmeter\Skins"
}

$dstSkins = Get-RainmeterSkinsPath

if (-not (Test-Path -LiteralPath $dstSkins)) {
  New-Item -ItemType Directory -Path $dstSkins -Force | Out-Null
}

$themesToInstall = if ($Theme -eq "all") { @("material-you", "one-ui", "macos", "glass", "nothing") } else { @($Theme) }

foreach ($t in $themesToInstall) {
  $srcSkins = Join-Path $repoRoot "themes\$t\rainmeter\Skins"
  if (-not (Test-Path -LiteralPath $srcSkins)) {
    Write-Error "No se encontraron skins de Rainmeter para el tema '$t' en: $srcSkins"
    exit 1
  }

  $ignoredNames = @("thumbs.db", ".ds_store", "desktop.ini")
  $srcPrefixLen = $srcSkins.TrimEnd("\").Length
  Get-ChildItem -LiteralPath $srcSkins -Recurse -File | Where-Object {
    ($ignoredNames -notcontains $_.Name.ToLowerInvariant()) -and ($_.Extension.ToLowerInvariant() -ne ".bak")
  } | ForEach-Object {
    $rel = $_.FullName.Substring($srcPrefixLen).TrimStart("\")
    $target = Join-Path $dstSkins $rel
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $targetDir)) {
      New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    $isFont = $_.Extension.ToLowerInvariant() -in ".ttf", ".otf"
    # Si es una fuente (.ttf/.otf) bloqueada en memoria por Rainmeter con el mismo tamaño, omitir sin error
    if ($isFont -and (Test-Path -LiteralPath $target) -and ((Get-Item -LiteralPath $target).Length -eq $_.Length)) {
      return
    }
    try {
      Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    } catch {
      if ($isFont) {
        Write-Warning "Fuente en uso por Rainmeter, omitida: $($_.Name)"
      } else {
        throw
      }
    }
  }

  Write-Host "Tema '$t' instalado en $dstSkins" -ForegroundColor Green
}

$rm = $null
$runningRm = Get-Process -Name "Rainmeter" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($runningRm) {
  try {
    if ($runningRm.Path -and (Test-Path -LiteralPath $runningRm.Path)) {
      $rm = $runningRm.Path
    }
  } catch {}
}
if (-not $rm) {
  $candidates = @()
  if ($env:ProgramFiles) { $candidates += Join-Path $env:ProgramFiles "Rainmeter\Rainmeter.exe" }
  if (${env:ProgramFiles(x86)}) { $candidates += Join-Path ${env:ProgramFiles(x86)} "Rainmeter\Rainmeter.exe" }
  $rm = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

if ($rm) {
  & $rm "[!RefreshApp]"
  Write-Host "Rainmeter refrescado correctamente." -ForegroundColor Cyan
} else {
  Write-Host "Rainmeter no detectado. Instala Rainmeter y carga las skins desde: $dstSkins" -ForegroundColor Yellow
}
