$ErrorActionPreference = "Stop"

$extraLibsDir = "F:\GitHub\nuvio\assets\extra_libs"
$targetLibs = "F:\GitHub\nuvio\NuvioMobile\composeApp\libs"
if (-not (Test-Path $targetLibs)) { New-Item -ItemType Directory -Path $targetLibs -Force | Out-Null }
Copy-Item "$extraLibsDir\*" $targetLibs -Force

$jniLibsDir = "F:\GitHub\nuvio\assets\jniLibs"
$targetJni = "F:\GitHub\nuvio\NuvioMobile\composeApp\src\androidMain\jniLibs"
if (-not (Test-Path $targetJni)) { New-Item -ItemType Directory -Path $targetJni -Force | Out-Null }
Copy-Item "$jniLibsDir\*" $targetJni -Recurse -Force

Write-Host "Assets copied successfully."
