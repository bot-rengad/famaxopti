# FaMaxOpti - Launcher 1-ligne style Chris Titus
# Usage chez le client (PowerShell) :
#   irm https://raw.githubusercontent.com/TONUSER/FaMaxOpti/main/famax.ps1 | iex
#
# A PERSONNALISER : mets ton lien direct vers l'exe ci-dessous (ligne $ExeUrl)

$ExeUrl = "https://github.com/bot-rengad/famaxopti/releases/latest/download/FaMaxOpti-Portable.exe"
$LauncherUrl = "https://raw.githubusercontent.com/bot-rengad/famaxopti/main/famax.ps1"

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. Auto-elevation admin (comme Chris Titus qui exige admin)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevation administrateur..." -ForegroundColor Yellow
    $cmd = "irm '$LauncherUrl' | iex"
    Start-Process powershell.exe -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-Command",$cmd -Verb RunAs
    exit
}

# 2. Dossier cache
$dir = "$env:TEMP\FaMaxOpti"
$exe = "$dir\FaMaxOpti-Portable.exe"
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

# 3. Telecharge si absent (cache 7 jours pour aller vite chez le client suivant)
$needDownload = $true
if (Test-Path -LiteralPath $exe) {
    $age = (Get-Date) - (Get-Item -LiteralPath $exe).LastWriteTime
    if ($age.TotalDays -lt 7) { $needDownload = $false }
}
if ($needDownload) {
    Write-Host "Telechargement FaMaxOpti (83 Mo)..." -ForegroundColor Cyan
    # barre de progression rapide
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $ExeUrl -OutFile "$exe.tmp" -UseBasicParsing
    Move-Item -LiteralPath "$exe.tmp" -Destination $exe -Force
    Write-Host "Telecharge OK." -ForegroundColor Green
} else {
    Write-Host "FaMaxOpti deja en cache, lancement direct." -ForegroundColor Green
}

# 4. Lance le panel (l'exe demande deja admin via son manifeste)
Write-Host "Ouverture du panel FaMaxOpti..." -ForegroundColor Cyan
Start-Process -FilePath $exe
