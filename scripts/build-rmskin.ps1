# Generador oficial de paquetes .rmskin (1-clic) para Veyra-Dots
# Construye MaterialYZen-v2.rmskin, OneUIZen-v2.rmskin y MacOSZen-v2.rmskin en releases/
# Formato oficial Rainmeter SkinInstaller: ZIP estandar (RMSKIN.ini + Skins/<Suite>/...) + footer binario de 16 bytes.

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repoRoot = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $repoRoot "releases"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$suites = @(
    @{
        theme = "material-you"
        suite = "MaterialYZen"
        file  = "MaterialYZen-v2.rmskin"
        load  = "MaterialYZen\ThemeSwitcher\ThemeSwitcher.ini"
    },
    @{
        theme = "one-ui"
        suite = "OneUIZen"
        file  = "OneUIZen-v2.rmskin"
        load  = "OneUIZen\ThemeSwitcher\OneUISwitcher.ini"
    },
    @{
        theme = "macos"
        suite = "MacOSZen"
        file  = "MacOSZen-v2.rmskin"
        load  = "MacOSZen\ThemeSwitcher\MacOSSwitcher.ini"
    }
)

$ignoredNames = @("thumbs.db", ".ds_store", "desktop.ini")

foreach ($s in $suites) {
    $skinsDir = Join-Path $repoRoot "themes\$($s.theme)\rainmeter\Skins"
    $srcRoot = Join-Path $skinsDir $s.suite
    if (-not (Test-Path -LiteralPath $srcRoot)) {
        Write-Error "No se encontro la suite: $srcRoot"
        exit 1
    }

    $loadFile = Join-Path $skinsDir $s.load
    if (-not (Test-Path -LiteralPath $loadFile)) {
        Write-Error "El skin declarado en Load= no existe: $loadFile"
        exit 1
    }

    $rmskinPath = Join-Path $outDir $s.file
    $tmpRmskin = "$rmskinPath.tmp"
    $tmpZip = Join-Path $env:TEMP "$($s.suite)_$([Guid]::NewGuid().ToString('N')).zip"

    try {
        $zip = [System.IO.Compression.ZipFile]::Open($tmpZip, [System.IO.Compression.ZipArchiveMode]::Create)
        try {
            # 1. Manifest RMSKIN.ini at archive root
            $manifest = @"
[rmskin]
Name=$($s.suite)
Author=Veyra-Dots
Version=2.0.0
LoadType=Skin
Load=$($s.load)
MinimumRainmeter=4.5.0
MinimumWindows=10.0
"@ -replace "`r?`n", "`r`n"

            $iniEntry = $zip.CreateEntry("RMSKIN.ini", [System.IO.Compression.CompressionLevel]::Optimal)
            $sw = New-Object System.IO.StreamWriter($iniEntry.Open(), [System.Text.Encoding]::ASCII)
            try {
                $sw.Write($manifest)
            } finally {
                $sw.Dispose()
            }

            # 2. All files under Skins/<Suite>/...
            $srcPrefixLen = $srcRoot.TrimEnd("\").Length
            $files = Get-ChildItem -LiteralPath $srcRoot -Recurse -File | Where-Object {
                ($ignoredNames -notcontains $_.Name.ToLowerInvariant()) -and ($_.Extension.ToLowerInvariant() -ne ".bak")
            }
            foreach ($f in $files) {
                $rel = $f.FullName.Substring($srcPrefixLen).TrimStart("\").Replace("\", "/")
                $entryName = "Skins/$($s.suite)/$rel"
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zip, $f.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
        } finally {
            $zip.Dispose()
        }

        # 3. Append official 16-byte Rainmeter PackageFooter: [int64 LE zipSize][byte 0x00][7-byte "RMSKIN\0"]
        $zipBytes = [System.IO.File]::ReadAllBytes($tmpZip)
        $zipSize = [int64]$zipBytes.Length
        $sizeBytes = [BitConverter]::GetBytes($zipSize)
        if (-not [BitConverter]::IsLittleEndian) {
            [Array]::Reverse($sizeBytes)
        }
        $flagByte = [byte[]]@(0x00)
        $magicBytes = [System.Text.Encoding]::ASCII.GetBytes("RMSKIN") + [byte]0x00

        $fs = [System.IO.File]::Create($tmpRmskin)
        try {
            $fs.Write($zipBytes, 0, $zipBytes.Length)
            $fs.Write($sizeBytes, 0, $sizeBytes.Length)
            $fs.Write($flagByte, 0, 1)
            $fs.Write($magicBytes, 0, $magicBytes.Length)
        } finally {
            $fs.Dispose()
        }

        Move-Item -LiteralPath $tmpRmskin -Destination $rmskinPath -Force
        $kb = [Math]::Round((Get-Item -LiteralPath $rmskinPath).Length / 1024.0, 1)
        Write-Host "  [OK] $($s.file) ($kb KB, $($files.Count) archivos)" -ForegroundColor Green
    } finally {
        if (Test-Path -LiteralPath $tmpZip) { Remove-Item -LiteralPath $tmpZip -Force -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $tmpRmskin) { Remove-Item -LiteralPath $tmpRmskin -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host "PASS: 3 paquetes .rmskin generados en $outDir" -ForegroundColor Cyan
