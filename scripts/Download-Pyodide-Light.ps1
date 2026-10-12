# Python Coach - téléchargement LÉGER de Pyodide (recommandé)
# Récupère uniquement les 5 fichiers du noyau (environ 10 à 15 Mo au total) depuis le CDN officiel.
# Python Coach n'utilise que la bibliothèque standard de Python (print, json, math, time...),
# fournie par python_stdlib.zip : les paquets volumineux (numpy, pandas...) ne sont pas nécessaires.
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"   # accélère fortement Invoke-WebRequest sous PowerShell 5
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Version = "0.26.4"
$BaseUrl = "https://cdn.jsdelivr.net/pyodide/v$Version/full/"
$AssetDir = Join-Path $PSScriptRoot "..\app\src\main\assets\pyodide"
$Files = @("pyodide.js", "pyodide.asm.js", "pyodide.asm.wasm", "pyodide-lock.json", "python_stdlib.zip")
# Tailles minimales plausibles (octets) pour détecter un téléchargement vide ou une page d'erreur
$MinSize = @{ "pyodide.js" = 10000; "pyodide.asm.js" = 50000; "pyodide.asm.wasm" = 3000000; "pyodide-lock.json" = 10000; "python_stdlib.zip" = 1000000 }

Write-Host "Python Coach - téléchargement léger de Pyodide $Version" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $AssetDir | Out-Null

foreach ($name in $Files) {
    $target = Join-Path $AssetDir $name
    Write-Host "Téléchargement : $name ..."
    Invoke-WebRequest -Uri ($BaseUrl + $name) -OutFile $target -UseBasicParsing
    $size = (Get-Item $target).Length
    if ($size -lt $MinSize[$name]) {
        Remove-Item $target -Force
        throw "Fichier $name trop petit ($size octets) : téléchargement incomplet ou bloqué. Réessaie."
    }
    Write-Host ("   OK ({0:N1} Mo)" -f ($size / 1MB))
}

$placeholder = Join-Path $AssetDir "README_PLACEHOLDER.txt"
if (Test-Path $placeholder) { Remove-Item $placeholder -Force }

$total = (Get-ChildItem $AssetDir -File -Recurse | Measure-Object -Property Length -Sum).Sum
Write-Host ("Terminé. Taille totale : {0:N1} Mo" -f ($total / 1MB)) -ForegroundColor Green
Write-Host "Étape suivante : .\scripts\Check-Pyodide.ps1, puis ouvrir le projet dans Android Studio."
