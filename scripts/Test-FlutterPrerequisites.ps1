[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$requiredCommands = @('git', 'code', 'flutter', 'dart', 'adb')
$missing = @()

Write-Host 'Pré-vérification Flutter — ThanksGiving Quote'
Write-Host ''

foreach ($commandName in $requiredCommands) {
  $command = Get-Command $commandName -ErrorAction SilentlyContinue
  if ($null -eq $command) {
    Write-Host "[MANQUANT] $commandName"
    $missing += $commandName
  }
  else {
    Write-Host "[OK]       $commandName : $($command.Source)"
  }
}

$sdkRoot = Join-Path $env:USERPROFILE 'develop\flutter'
if (Test-Path -LiteralPath $sdkRoot) {
  Write-Host "[OK]       Dossier SDK attendu : $sdkRoot"
}
else {
  Write-Host "[MANQUANT] Dossier SDK attendu : $sdkRoot"
}

if (Get-Command flutter -ErrorAction SilentlyContinue) {
  Write-Host ''
  Write-Host 'Résultat de flutter doctor :'
  flutter doctor
}
else {
  Write-Host ''
  Write-Host 'Étape suivante : installez Flutter stable, ajoutez son dossier bin au Path, puis relancez ce script.'
}

if ($missing.Count -gt 0) {
  exit 1
}
