$ErrorActionPreference = 'Stop'

$packageName = $env:ChocolateyPackageName

# Remove the shim
Uninstall-BinFile -Name 'emojify'

Write-Host "Emojify-Go has been uninstalled successfully."
