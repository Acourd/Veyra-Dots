param([string]$Query, [switch]$PreviewUrl)
$ErrorActionPreference = 'Stop'
if (!$PSBoundParameters.ContainsKey('Query')) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $Query = [Microsoft.VisualBasic.Interaction]::InputBox('Escribe una consulta / Enter a query', 'NothingZen / Web')
}
if ([string]::IsNullOrWhiteSpace($Query)) { return }
$url = 'https://www.google.com/search?q=' + [Uri]::EscapeDataString($Query.Trim())
if ($PreviewUrl) { Write-Output $url; return }
Start-Process -FilePath $url
