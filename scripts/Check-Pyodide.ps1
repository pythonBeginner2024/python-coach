$ErrorActionPreference = "Stop"
$AssetDir = Join-Path $PSScriptRoot "..\app\src\main\assets\pyodide"
$MinSize = [ordered]@{ "pyodide.js" = 10000; "pyodide.asm.js" = 50000; "pyodide.asm.wasm" = 3000000; "pyodide-lock.json" = 10000; "python_stdlib.zip" = 1000000 }
$problems = @()
foreach ($name in $MinSize.Keys) {
    $path = Join-Path $AssetDir $name
    if (-not (Test-Path $path)) { $problems += "$name : ABSENT"; continue }
    $size = (Get-Item $path).Length
    if ($size -lt $MinSize[$name]) { $problems += "$name : trop petit ($size octets)" }
    else { Write-Host ("OK  {0}  ({1:N1} Mo)" -f $name, ($size / 1MB)) }
}
if (Test-Path (Join-Path $AssetDir "README_PLACEHOLDER.txt")) { Write-Host "Note : README_PLACEHOLDER.txt est encore présent (sans conséquence)." -ForegroundColor Yellow }
if ($problems.Count -gt 0) {
    Write-Host "Pyodide incomplet :" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host " - $_" }
    Write-Host "Lance .\scripts\Download-Pyodide-Light.ps1" -ForegroundColor Red
    exit 1
}
$sizeMB = [math]::Round(((Get-ChildItem $AssetDir -File -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB), 1)
Write-Host "Les 5 fichiers principaux de Pyodide sont présents. Taille totale du dossier : $sizeMB Mo" -ForegroundColor Green
