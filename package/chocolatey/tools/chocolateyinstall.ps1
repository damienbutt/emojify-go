$ErrorActionPreference = 'Stop'

$packageName = $env:ChocolateyPackageName
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64 = 'https://github.com/damienbutt/emojify-go/releases/download/v0.0.0/emojify-go_0.0.0_windows_amd64.zip'
$checksum64 = '0000000000000000000000000000000000000000000000000000000000000000'

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url64bit       = $url64
    checksum64     = $checksum64
    checksumType64 = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

# Create a shim for the executable
$exePath = Join-Path $toolsDir 'emojify.exe'
if (Test-Path $exePath) {
    Install-BinFile -Name 'emojify' -Path $exePath
}
