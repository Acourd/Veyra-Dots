param(
  [ValidateSet("material-you", "one-ui", "macos", "all")]
  [string]$Theme = "material-you"
)

# Instalador rápido de skins Rainmeter para cualquier tema en themes/<Theme>/rainmeter/Skins/ (o -Theme all)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$dstSkins = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Rainmeter\Skins"

if (-not (Test-Path $dstSkins)) {
  New-Item -ItemType Directory -Path $dstSkins -Force | Out-Null
}

$themesToInstall = if ($Theme -eq "all") { @("material-you", "one-ui", "macos") } else { @($Theme) }

foreach ($t in $themesToInstall) {
  $srcSkins = Join-Path $repoRoot "themes\$t\rainmeter\Skins"
  if (-not (Test-Path $srcSkins)) {
    Write-Error "No se encontraron skins de Rainmeter para el tema '$t' en: $srcSkins"
    exit 1
  }

  Get-ChildItem -Path $srcSkins -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($srcSkins.Length).TrimStart("\")
    $target = Join-Path $dstSkins $rel
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path $targetDir)) {
      New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    # Si es una fuente (.ttf/.otf) bloqueada en memoria por Rainmeter con el mismo tamaño, omitir sin error
    if (($_.Extension -in ".ttf", ".otf") -and (Test-Path $target) -and ((Get-Item $target).Length -eq $_.Length)) {
      return
    }
    Copy-Item -Path $_.FullName -Destination $target -Force
  }

  Write-Host "Tema '$t' instalado en $dstSkins" -ForegroundColor Green
}

$rm = @(
  (Join-Path $env:ProgramFiles "Rainmeter\Rainmeter.exe"),
  (Join-Path ${env:ProgramFiles(x86)} "Rainmeter\Rainmeter.exe")
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($rm) {
  & $rm "[!RefreshApp]"
  Write-Host "Rainmeter refrescado correctamente." -ForegroundColor Cyan
}
