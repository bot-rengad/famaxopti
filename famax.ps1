# FaMaxOpti - Launcher 1-ligne style Chris Titus
# Usage chez le client (PowerShell) :
#   irm https://raw.githubusercontent.com/bot-rengad/famaxopti/main/famax.ps1 | iex
#
# A PERSONNALISER : mets ton lien direct vers l'exe ci-dessous (ligne $ExeUrl)

$ExeUrl = "https://github.com/bot-rengad/famaxopti/releases/latest/download/FaMaxOpti-Portable.exe"
$LauncherUrl = "https://raw.githubusercontent.com/bot-rengad/famaxopti/main/famax.ps1"

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {

# 0. Banniere FMX (style Chris Titus)
$banner = @'
FFFFFFFFFFFFFFFFFFFFFF   MMMMMMMM               MMMMMMMM
F::::::::::::::::::::F   M:::::::M             M:::::::M
F::::::::::::::::::::F   M::::::::M           M::::::::M
FF::::::FFFFFFFFF::::F   M:::::::::M         M:::::::::M
  F:::::F       FFFFFF   M::::::::::M       M::::::::::M
  F:::::F                M:::::::::::M     M:::::::::::M
  F::::::FFFFFFFFFF      M:::::::M::::M   M::::M:::::::M  xxxxxxx      xxxxxxx
  F:::::::::::::::F      M::::::M M:::M   M:::M M::::::M   x:::::x    x:::::x
  F:::::::::::::::F      M::::::M  M:::M M:::M  M::::::M    x:::::x  x:::::x
  F::::::FFFFFFFFFF      M::::::M   M:::M:::M   M::::::M     x:::::xx:::::x
  F:::::F                M::::::M    M:::::M    M::::::M      x::::::::::x
  F:::::F                M::::::M     MMMMM     M::::::M       x::::::::x
FF:::::::FF              M::::::M               M::::::M       x::::::::x
F::::::::FF              M::::::M               M::::::M      x::::::::::x
F::::::::FF              M::::::M               M::::::M     x:::::xx:::::x
FFFFFFFFFFF              MMMMMMMM               MMMMMMMM    x:::::x  x:::::x
                                                           x:::::x    x:::::x
                                                          xxxxxxx      xxxxxxx
'@
Write-Host $banner -ForegroundColor Red
Write-Host "  FaMaxOpti - Panel d'optimisation" -ForegroundColor White
Write-Host "  discord.gg/fmx" -ForegroundColor DarkGray
Write-Host ""

# 1. Auto-elevation admin (comme Chris Titus qui exige admin)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevation administrateur..." -ForegroundColor Yellow
    # -NoExit pour que la fenetre bleue RESTE ouverte si erreur
    $cmd = "irm '$LauncherUrl' | iex"
    Start-Process powershell.exe -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-NoExit","-Command",$cmd -Verb RunAs
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
    # debloque l'exe (sinon SmartScreen peut le bloquer en silence)
    Unblock-File -Path $exe -ErrorAction SilentlyContinue
    Write-Host "Telecharge OK." -ForegroundColor Green
} else {
    Write-Host "FaMaxOpti deja en cache, lancement direct." -ForegroundColor Green
}

# 4. Lance le panel (l'exe demande deja admin via son manifeste)
Write-Host "Ouverture du panel FaMaxOpti..." -ForegroundColor Cyan
Start-Process -FilePath $exe
Write-Host "Panel lance. Tu peux fermer cette fenetre." -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host ("ERREUR : " + $_.Exception.Message) -ForegroundColor Red
    Write-Host ""
    Read-Host "Appuie sur Entree pour fermer"
}
