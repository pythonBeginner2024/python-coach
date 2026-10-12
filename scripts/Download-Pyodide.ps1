$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"   # accélère fortement Invoke-WebRequest sous PowerShell 5
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Version = "0.26.4"
$AssetDir = Join-Path $PSScriptRoot "..\app\src\main\assets\pyodide"
$WorkDir = Join-Path $env:TEMP "python-coach-pyodide-$Version"
$Archive = Join-Path $WorkDir "pyodide-$Version.tar.bz2"
$Url = "https://github.com/pyodide/pyodide/releases/download/$Version/pyodide-$Version.tar.bz2"

Write-Host "Python Coach - préparation de la distribution COMPLÈTE de Pyodide $Version (le script Download-Pyodide-Light.ps1 suffit pour cette application)" -ForegroundColor Cyan
Write-Host "Le téléchargement peut dépasser 200 Mo. Prévois de l'espace disque."
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

if (-not (Test-Path $Archive)) {
    Write-Host "Téléchargement de la distribution officielle..."
    Invoke-WebRequest -Uri $Url -OutFile $Archive -UseBasicParsing
} else {
    Write-Host "Archive déjà téléchargée : $Archive"
}

$ExtractDir = Join-Path $WorkDir "extracted"
if (Test-Path $ExtractDir) { Remove-Item -Recurse -Force $ExtractDir }
New-Item -ItemType Directory -Force -Path $ExtractDir | Out-Null

Write-Host "Extraction de l'archive..."
# Windows 10/11 includes tar.exe on most installations.
& tar.exe -xjf $Archive -C $ExtractDir
if ($LASTEXITCODE -ne 0) {
    throw "Échec de l'extraction. Vérifie que tar.exe est disponible et que l'archive est complète."
}

$candidates = Get-ChildItem -Path $ExtractDir -Filter "pyodide.js" -File -Recurse |
    Where-Object {
        (Test-Path (Join-Path $_.DirectoryName "pyodide.asm.js")) -and
        (Test-Path (Join-Path $_.DirectoryName "pyodide.asm.wasm")) -and
        (Test-Path (Join-Path $_.DirectoryName "pyodide-lock.json")) -and
        (Test-Path (Join-Path $_.DirectoryName "python_stdlib.zip"))
    }

if (-not $candidates -or $candidates.Count -eq 0) {
    throw "Impossible de repérer le dossier de distribution Pyodide complet dans l'archive. Aucun fichier de l'application n'a été remplacé."
}

$SourceDir = $candidates[0].DirectoryName
Write-Host "Distribution trouvée : $SourceDir"

if (Test-Path $AssetDir) {
    Get-ChildItem -Path $AssetDir -Force |
        Where-Object { $_.Name -ne "README_PLACEHOLDER.txt" } |
        Remove-Item -Recurse -Force
} else {
    New-Item -ItemType Directory -Force -Path $AssetDir | Out-Null
}

Get-ChildItem -Path $SourceDir -Force | Copy-Item -Destination $AssetDir -Recurse -Force
$placeholder = Join-Path $AssetDir "README_PLACEHOLDER.txt"
if (Test-Path $placeholder) { Remove-Item $placeholder -Force }

$required = @("pyodide.js", "pyodide.asm.js", "pyodide.asm.wasm", "pyodide-lock.json", "python_stdlib.zip")
foreach ($name in $required) {
    if (-not (Test-Path (Join-Path $AssetDir $name))) {
        throw "Fichier requis absent après copie : $name"
    }
}

$sizeMB = [math]::Round(((Get-ChildItem $AssetDir -File -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB), 1)
Write-Host "Terminé. Fichiers Pyodide copiés dans : $AssetDir" -ForegroundColor Green
Write-Host "Taille des fichiers embarqués : environ $sizeMB Mo"
Write-Host "Étape suivante : ouvrir le projet dans Android Studio, synchroniser Gradle, puis lancer l'application."
Write-Host "Note : cette préparation ne compile pas l'APK et ne garantit pas encore un fonctionnement hors ligne; il faudra tester l'application."
