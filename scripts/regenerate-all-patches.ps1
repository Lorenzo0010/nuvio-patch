param (
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$NuvioMobileDir = "$PSScriptRoot\..\NuvioMobile"
)

$archivePath = "C:\Users\loren\AppData\Local\Temp\tree_0417.tar"
if (-not (Test-Path $archivePath)) {
    Write-Host "Creating archive from NuvioMobile/.git..." -ForegroundColor Yellow
    Push-Location "C:\"
    & "C:\Program Files\Git\cmd\git.exe" --git-dir="F:/GitHub/nuvio/NuvioMobile/.git" archive --format=tar --output=$archivePath 74492b2621bcdc374c0fbeebdacf641f0d481c14
    Pop-Location
}

function Regenerate-Patch03 {
    $testDir = "C:\Users\loren\AppData\Local\Temp\nuvio_patch_03_gen"
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    try {
        tar -xf $archivePath
        & "C:\Program Files\Git\cmd\git.exe" init --quiet
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "upstream 0.4.17" --quiet
        
        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\01-branding-and-config.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "01" --quiet

        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\02-app-updater.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "02" --quiet

        $files03 = @(
            "composeApp/src/androidMain/kotlin/com/nuvio/app/MainActivity.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/livetv/LiveTvClock.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/livetv/LiveTvStorage.android.kt",
            "composeApp/src/commonMain/composeResources/values-it/strings.xml",
            "composeApp/src/commonMain/composeResources/values/strings.xml",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/AppScreenTab.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/AppShellComponents.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/MainAppContent.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/MainTabsDestination.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/livetv/LiveTvFilterBar.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/livetv/LiveTvModels.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/livetv/LiveTvRepository.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/livetv/LiveTvScreen.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/livetv/LiveTvStorage.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/LiveTvChannelsPanel.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/LiveTvPlayerActions.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerControls.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerScreenRuntimeState.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerScreenRuntimeUi.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/livetv/LiveTvClock.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/livetv/LiveTvStorage.desktop.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/livetv/LiveTvClock.ios.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/livetv/LiveTvStorage.ios.kt"
        )

        foreach ($rel in $files03) {
            $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
            $dst = Join-Path $testDir ($rel -replace '/', '\')
            $dstParent = Split-Path $dst -Parent
            if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
            Copy-Item -Path $src -Destination $dst -Force
        }

        & "C:\Program Files\Git\cmd\git.exe" add -N .
        $patch03Path = Join-Path $PatchesDir "03-live-tv.patch"
        & "C:\Program Files\Git\cmd\git.exe" diff --binary "--output=$patch03Path" -- $files03
        Write-Host "Patch 03 updated: $((Get-Item $patch03Path).Length) bytes" -ForegroundColor Green
    } finally {
        Pop-Location
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Regenerate-Patch04 {
    $testDir = "C:\Users\loren\AppData\Local\Temp\nuvio_patch_04_gen"
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    try {
        tar -xf $archivePath
        & "C:\Program Files\Git\cmd\git.exe" init --quiet
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "upstream 0.4.17" --quiet
        
        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\01-branding-and-config.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "01" --quiet

        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\02-app-updater.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "02" --quiet

        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\03-live-tv.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "03" --quiet

        $files04 = @(
            "androidApp/build.gradle.kts",
            "androidApp/src/main/AndroidManifest.xml",
            "composeApp/build.gradle.kts",
            "composeApp/src/androidMain/AndroidManifest.xml",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/core/logging/InAppLogger.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/core/network/AndroidDnsProvider.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/core/share/SharePlatform.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsForegroundService.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsNotificationActionReceiver.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/Mp4ParserRemux.kt",
            "composeApp/src/commonMain/composeResources/values-it/strings.xml",
            "composeApp/src/commonMain/composeResources/values/strings.xml",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/AppShellComponents.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/MainAppContent.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/MainTabsDestination.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/core/logging/InAppLogger.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/core/share/SharePlatform.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/BottomSheet.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/DropdownChip.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsHlsSelectionSheet.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsModels.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsRepository.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/HlsDownloadEngine.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/HlsPlaylist.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/NetworkSettingsRepository.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/streams/StreamsScreen.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/core/logging/InAppLogger.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/core/share/SharePlatform.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsClock.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.desktop.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/core/logging/InAppLogger.ios.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/core/share/SharePlatform.ios.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.ios.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.ios.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.ios.kt",
            "gradle/libs.versions.toml"
        )

        foreach ($rel in $files04) {
            $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
            if (-not (Test-Path $src)) {
                Remove-Item -Path (Join-Path $testDir ($rel -replace '/', '\')) -Force -ErrorAction SilentlyContinue
                continue
            }
            $dst = Join-Path $testDir ($rel -replace '/', '\')
            $dstParent = Split-Path $dst -Parent
            if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
            Copy-Item -Path $src -Destination $dst -Force
        }

        & "C:\Program Files\Git\cmd\git.exe" add -N .
        $patch04Path = Join-Path $PatchesDir "04-hls-downloads.patch"
        & "C:\Program Files\Git\cmd\git.exe" diff --binary "--output=$patch04Path" -- $files04
        Write-Host "Patch 04 updated: $((Get-Item $patch04Path).Length) bytes" -ForegroundColor Green
    } finally {
        Pop-Location
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Regenerate-Patch05 {
    $testDir = "C:\Users\loren\AppData\Local\Temp\nuvio_patch_05_gen"
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
    Push-Location $testDir
    try {
        tar -xf $archivePath
        & "C:\Program Files\Git\cmd\git.exe" init --quiet
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "upstream 0.4.17" --quiet
        
        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\01-branding-and-config.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "01" --quiet

        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\02-app-updater.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "02" --quiet

        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\03-live-tv.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "03" --quiet

        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change "$PatchesDir\04-hls-downloads.patch"
        & "C:\Program Files\Git\cmd\git.exe" add -A
        & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "04" --quiet

        $files05 = @(
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.android.kt",
            "composeApp/src/androidMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.android.kt",
            "composeApp/src/commonMain/composeResources/values-it/strings.xml",
            "composeApp/src/commonMain/composeResources/values/strings.xml",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsScreen.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsSettingsRepository.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.kt",
            "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsScreen.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.desktop.kt",
            "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.desktop.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.ios.kt",
            "composeApp/src/iosMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.ios.kt",
            "iosApp/Configuration/Version.xcconfig"
        )

        foreach ($rel in $files05) {
            $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
            $dst = Join-Path $testDir ($rel -replace '/', '\')
            $dstParent = Split-Path $dst -Parent
            if (-not (Test-Path $dstParent)) { New-Item -ItemType Directory -Path $dstParent -Force | Out-Null }
            Copy-Item -Path $src -Destination $dst -Force
        }

        & "C:\Program Files\Git\cmd\git.exe" add -N .
        $patch05Path = Join-Path $PatchesDir "05-download-folder.patch"
        & "C:\Program Files\Git\cmd\git.exe" diff --binary "--output=$patch05Path" -- $files05
        Write-Host "Patch 05 updated: $((Get-Item $patch05Path).Length) bytes" -ForegroundColor Green
    } finally {
        Pop-Location
        Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "=== Regenerating Patch 03 ===" -ForegroundColor Cyan
Regenerate-Patch03
Write-Host "=== Regenerating Patch 04 ===" -ForegroundColor Cyan
Regenerate-Patch04
Write-Host "=== Regenerating Patch 05 ===" -ForegroundColor Cyan
Regenerate-Patch05
