$ErrorActionPreference = "Stop"

$buildApkDir = "F:\GitHub\nuvio\NuvioMobile\androidApp\build\outputs\apk\full\release"
$releasesDir = "F:\GitHub\nuvio\releases"
$version = "0.4.17.1"

Copy-Item "$buildApkDir\androidApp-full-universal-release.apk" "$releasesDir\nuvio_plus_${version}_universal.apk" -Force
Copy-Item "$buildApkDir\androidApp-full-arm64-v8a-release.apk"  "$releasesDir\nuvio_plus_${version}_arm64-v8a.apk" -Force
Copy-Item "$buildApkDir\androidApp-full-armeabi-v7a-release.apk" "$releasesDir\nuvio_plus_${version}_armeabi-v7a.apk" -Force
Copy-Item "$buildApkDir\androidApp-full-x86_64-release.apk"     "$releasesDir\nuvio_plus_${version}_x86_64.apk" -Force
Copy-Item "$buildApkDir\androidApp-full-x86-release.apk"        "$releasesDir\nuvio_plus_${version}_x86.apk" -Force

Get-ChildItem "$releasesDir\nuvio_plus_${version}_*.apk" | Select-Object Name, Length
