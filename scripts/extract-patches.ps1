# PowerShell Script to extract modular Enhanced patches from a modified Nuvio directory or branch
param (
    [string]$SourceDir = (Get-Location).Path,
    [string]$UpstreamRef = "HEAD~1",
    [string]$OutputDir = "$PSScriptRoot\..\patches",
    [string]$ExtraLibsDir = "$PSScriptRoot\..\assets\extra_libs",
    [string]$JniLibsDir = "$PSScriptRoot\..\assets\jniLibs"
)

Write-Host "=== Nuvio Modular Patch Extractor ===" -ForegroundColor Cyan

Push-Location $SourceDir
try {
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }

    Write-Host "Estrazione 01-branding-and-config.patch..." -ForegroundColor Yellow
    $patch1 = Join-Path $OutputDir "01-branding-and-config.patch"
    git diff --binary --output="$patch1" $UpstreamRef -- "androidApp/build.gradle.kts" "composeApp/build.gradle.kts" "androidApp/src/main/res/values/strings.xml" "*strings.xml"

    Write-Host "Estrazione 02-app-updater.patch..." -ForegroundColor Yellow
    $patch2 = Join-Path $OutputDir "02-app-updater.patch"
    git diff --binary --output="$patch2" $UpstreamRef -- "*AppUpdater.kt*"

    Write-Host "Estrazione 03-live-tv.patch..." -ForegroundColor Yellow
    $patch3 = Join-Path $OutputDir "03-live-tv.patch"
    git diff --binary --output="$patch3" $UpstreamRef -- "*livetv*" "*LiveTv*" "composeApp/src/commonMain/kotlin/com/nuvio/app/AppScreenTab.kt" "composeApp/src/commonMain/kotlin/com/nuvio/app/AppShellComponents.kt" "composeApp/src/commonMain/composeResources/values/strings.xml"

    Write-Host "Copia asset..." -ForegroundColor Yellow
    if (Test-Path "composeApp\libs") {
        if (-not (Test-Path $ExtraLibsDir)) { New-Item -ItemType Directory -Path $ExtraLibsDir -Force | Out-Null }
        Copy-Item "composeApp\libs\*" -Destination $ExtraLibsDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "composeApp\src\androidMain\jniLibs") {
        if (-not (Test-Path $JniLibsDir)) { New-Item -ItemType Directory -Path $JniLibsDir -Force | Out-Null }
        Copy-Item "composeApp\src\androidMain\jniLibs\*" -Destination $JniLibsDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "🎉 Patch modulari estratte con successo in $OutputDir" -ForegroundColor Green
} finally {
    Pop-Location
}
