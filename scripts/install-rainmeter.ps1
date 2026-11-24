param(
  [string]$Theme = "material-you"
)

# Instalador rápido de skins Rainmeter para cualquier tema en themes/<Theme>/rainmeter/Skins/

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$srcSkins = Join-Path $repoRoot "themes\$Theme\rainmeter\Skins"
$dstSkins = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Rainmeter\Skins"

if (-not (Test-Path $srcSkins)) {
  Write-Error "No se encontraron skins de Rainmeter para el tema '$Theme' en: $srcSkins"
  exit 1
}

if (-not (Test-Path $dstSkins)) {
  New-Item -ItemType Directory -Path $dstSkins -Force | Out-Null
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

Write-Host "Tema '$Theme' instalado en $dstSkins" -ForegroundColor Green

$rm = "C:\Program Files\Rainmeter\Rainmeter.exe"
if (Test-Path $rm) {
  & $rm "[!RefreshApp]"
  Write-Host "Rainmeter refrescado correctamente." -ForegroundColor Cyan
}
