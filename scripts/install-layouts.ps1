param(
  [ValidateSet("all", "Veyra_OneUI", "Veyra_Nothing", "Veyra_Glass", "Veyra_MacOS", "Veyra_MaterialYou")]
  [string]$Layout = "all",

  [string]$Load = ""
)

# Instalador oficial de Diseños (Layouts) listos para usar de Veyra-Dots en Rainmeter.
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$srcLayoutsRoot = Join-Path $repoRoot "layouts"

if (-not (Test-Path -LiteralPath $srcLayoutsRoot)) {
  Write-Error "No se encontró la carpeta de layouts en: $srcLayoutsRoot"
  exit 1
}

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

$dstSkins = (Get-RainmeterSkinsPath).TrimEnd("\") + "\"
$dstLayoutsRoot = Join-Path $env:APPDATA "Rainmeter\Layouts"
New-Item -ItemType Directory -Path $dstLayoutsRoot -Force | Out-Null

$layoutNames = if ($Layout -eq "all") {
  @("Veyra_OneUI", "Veyra_Nothing", "Veyra_Glass", "Veyra_MacOS", "Veyra_MaterialYou")
} else {
  @($Layout)
}

$utf16LeBom = New-Object System.Text.UnicodeEncoding($false, $true)

foreach ($name in $layoutNames) {
  $srcIni = Join-Path (Join-Path $srcLayoutsRoot $name) "Rainmeter.ini"
  if (-not (Test-Path -LiteralPath $srcIni -PathType Leaf)) {
    Write-Warning "Layout no encontrado, omitido: $srcIni"
    continue
  }

  $targetDir = Join-Path $dstLayoutsRoot $name
  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
  $targetIni = Join-Path $targetDir "Rainmeter.ini"

  $content = [System.IO.File]::ReadAllText($srcIni)
  $content = [regex]::Replace($content, '(?m)^SkinPath=.*$', "SkinPath=$dstSkins")
  [System.IO.File]::WriteAllText($targetIni, $content, $utf16LeBom)
  Write-Host "Layout '$name' instalado en $targetDir" -ForegroundColor Green
}

$rm = $null
$runningRm = Get-Process -Name "Rainmeter" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($runningRm -and $runningRm.Path -and (Test-Path -LiteralPath $runningRm.Path)) {
  $rm = $runningRm.Path
}
if (-not $rm) {
  $candidates = @()
  if ($env:ProgramFiles) { $candidates += Join-Path $env:ProgramFiles "Rainmeter\Rainmeter.exe" }
  if (${env:ProgramFiles(x86)}) { $candidates += Join-Path ${env:ProgramFiles(x86)} "Rainmeter\Rainmeter.exe" }
  $rm = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

if ($rm) {
  & $rm "[!RefreshApp]"
  if ($Load) {
    Start-Sleep -Milliseconds 600
    & $rm "[!LoadLayout $Load]"
    Write-Host "Layout '$Load' cargado en Rainmeter." -ForegroundColor Cyan
  } else {
    Write-Host "Layouts listos. Cárgalos desde Administrar Rainmeter -> Diseños (Veyra_*)." -ForegroundColor Cyan
  }
} else {
  Write-Host "Rainmeter no detectado. Instala las skins y abre Administrar Rainmeter -> Diseños." -ForegroundColor Yellow
}
