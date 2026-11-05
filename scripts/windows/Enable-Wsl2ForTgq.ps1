#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string] $Distribution = 'Ubuntu'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modernWslPath = Join-Path $env:ProgramFiles 'WSL\wsl.exe'
if (Test-Path -LiteralPath $modernWslPath) {
    $wslExecutable = $modernWslPath
}
else {
    $wslCommand = Get-Command 'wsl.exe' -ErrorAction Stop
    $wslExecutable = $wslCommand.Source
}

Write-Host 'Activation des composants Windows nécessaires à WSL 2...' -ForegroundColor Cyan

$restartNeeded = $false
foreach ($featureName in @('Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform')) {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName
    if ($feature.State -ne 'Enabled') {
        $result = Enable-WindowsOptionalFeature `
            -Online `
            -FeatureName $featureName `
            -All `
            -NoRestart
        $restartNeeded = $restartNeeded -or $result.RestartNeeded
    }
}

$wslService = Get-Service -Name 'WslService' -ErrorAction SilentlyContinue
if ($null -eq $wslService) {
    $wslService = Get-Service -Name 'LxssManager' -ErrorAction SilentlyContinue
}
if ($null -ne $wslService -and $wslService.StartType -eq 'Disabled') {
    Set-Service -Name $wslService.Name -StartupType Manual
}

if ($restartNeeded) {
    Write-Host 'Un redémarrage Windows est requis. Aucun redémarrage automatique ne sera effectué.' -ForegroundColor Yellow
    Write-Host 'Après redémarrage, relancer ce même script en administrateur.' -ForegroundColor Yellow
    exit 2
}

if ($null -ne $wslService -and $wslService.Status -ne 'Running') {
    Start-Service -Name $wslService.Name
}

Write-Host 'Mise à jour de WSL et sélection de WSL 2 par défaut...' -ForegroundColor Cyan
& $wslExecutable --update
if ($LASTEXITCODE -ne 0) {
    throw 'La mise à jour de WSL a échoué.'
}

& $wslExecutable --set-default-version 2
if ($LASTEXITCODE -ne 0) {
    throw 'Impossible de définir WSL 2 comme version par défaut.'
}

$installedDistributions = @(& $wslExecutable --list --quiet 2>$null) |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }

if ($installedDistributions -notcontains $Distribution) {
    Write-Host "Installation de la distribution $Distribution..." -ForegroundColor Cyan
    & $wslExecutable --install --distribution $Distribution
    if ($LASTEXITCODE -ne 0) {
        throw "L'installation de $Distribution a échoué."
    }
}
else {
    Write-Host "La distribution $Distribution est déjà installée." -ForegroundColor Green
}

& $wslExecutable --set-version $Distribution 2
if ($LASTEXITCODE -ne 0) {
    throw "Impossible de placer $Distribution en WSL 2."
}

Write-Host "`nWSL 2 est préparé. Ouvrez $Distribution et créez le compte Linux demandé." -ForegroundColor Green
Write-Host "Ensuite, suivez DOCKER_WSL_SETUP.md. Aucun redémarrage automatique n’a été effectué." -ForegroundColor Green

