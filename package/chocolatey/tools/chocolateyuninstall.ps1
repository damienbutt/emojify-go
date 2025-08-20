$ErrorActionPreference = 'Stop'

$packageName = $env:ChocolateyPackageName

# Remove the shim
Uninstall-BinFile -Name 'emojify'

# Remove man page
$manFile = Join-Path $env:ChocolateyInstall 'share\man\man1\emojify.1'
if (Test-Path $manFile) {
    Remove-Item -Path $manFile -Force
}

Write-Host "Emojify-Go has been uninstalled successfully."
