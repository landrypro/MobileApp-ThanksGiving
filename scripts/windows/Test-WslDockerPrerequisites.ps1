[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [ValidateSet('OK', 'ATTENTION', 'BLOQUANT')] [string] $Status,
        [Parameter(Mandatory)] [string] $Detail
    )

    $checks.Add([pscustomobject]@{
        Controle = $Name
        Statut   = $Status
        Detail   = $Detail
    })
}

$windowsIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$windowsPrincipal = [Security.Principal.WindowsPrincipal]::new($windowsIdentity)
$isAdministrator = $windowsPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

$wslCommand = Get-Command 'wsl.exe' -ErrorAction SilentlyContinue
if ($null -eq $wslCommand) {
    Add-Check -Name 'Commande WSL' -Status 'BLOQUANT' -Detail 'wsl.exe est introuvable.'
}
else {
    Add-Check -Name 'Commande WSL' -Status 'OK' -Detail $wslCommand.Source
}

$wslService = Get-Service -Name 'WslService' -ErrorAction SilentlyContinue
if ($null -eq $wslService) {
    $wslService = Get-Service -Name 'LxssManager' -ErrorAction SilentlyContinue
}

if ($null -eq $wslService) {
    Add-Check -Name 'Service WSL' -Status 'BLOQUANT' -Detail 'WslService/LxssManager est introuvable.'
}
elseif ($wslService.StartType -eq 'Disabled') {
    Add-Check -Name 'Service WSL' -Status 'BLOQUANT' -Detail "$($wslService.Name) est désactivé."
}
else {
    Add-Check -Name 'Service WSL' -Status 'OK' -Detail "$($wslService.Name) : $($wslService.Status), démarrage $($wslService.StartType)."
}

if ($isAdministrator) {
    foreach ($featureName in @('Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform')) {
        try {
            $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName
            $status = if ($feature.State -eq 'Enabled') { 'OK' } else { 'BLOQUANT' }
            Add-Check -Name $featureName -Status $status -Detail "État : $($feature.State)."
        }
        catch {
            Add-Check -Name $featureName -Status 'ATTENTION' -Detail $_.Exception.Message
        }
    }
}
else {
    Add-Check -Name 'Fonctionnalités Windows' -Status 'ATTENTION' -Detail 'Relancer en administrateur pour contrôler les fonctionnalités optionnelles.'
}

if ($null -ne $wslCommand -and $null -ne $wslService -and $wslService.StartType -ne 'Disabled') {
    try {
        $versionOutput = (& wsl.exe --version 2>&1 | Out-String) -replace "`0", ''
        $versionOutput = $versionOutput.Trim()
        if ($LASTEXITCODE -eq 0) {
            Add-Check -Name 'Version WSL' -Status 'OK' -Detail $versionOutput
        }
        else {
            Add-Check -Name 'Version WSL' -Status 'BLOQUANT' -Detail 'La version WSL installée ne prend pas en charge --version. Exécuter wsl.exe --update.'
        }
    }
    catch {
        Add-Check -Name 'Version WSL' -Status 'BLOQUANT' -Detail $_.Exception.Message
    }

    try {
        $distributionOutput = (& wsl.exe --list --verbose 2>&1 | Out-String) -replace "`0", ''
        $distributionOutput = $distributionOutput.Trim()
        if ($LASTEXITCODE -eq 0 -and $distributionOutput) {
            Add-Check -Name 'Distribution Linux' -Status 'OK' -Detail $distributionOutput
        }
        else {
            Add-Check -Name 'Distribution Linux' -Status 'BLOQUANT' -Detail 'Aucune distribution WSL 2 utilisable.'
        }
    }
    catch {
        Add-Check -Name 'Distribution Linux' -Status 'BLOQUANT' -Detail $_.Exception.Message
    }
}

$checks | Format-Table -AutoSize -Wrap

$blockingChecks = @($checks | Where-Object Statut -eq 'BLOQUANT')
if ($blockingChecks.Count -gt 0) {
    Write-Host "`nDiagnostic : $($blockingChecks.Count) blocage(s). Exécuter Enable-Wsl2ForTgq.ps1 en administrateur." -ForegroundColor Red
    exit 1
}

Write-Host "`nDiagnostic : prérequis Windows satisfaits." -ForegroundColor Green

