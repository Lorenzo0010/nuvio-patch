# Script to regenerate patches/04-plugin-hls-downloads.patch based on latest NuvioMobile changes
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$NuvioMobileDir = "$PSScriptRoot\..\NuvioMobile"
)

$testDir = "$env:TEMP\nuvio_patch_04_gen_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

$files04 = @(
    "androidApp/build.gradle.kts",
    "androidApp/src/main/AndroidManifest.xml",
    "composeApp/build.gradle.kts",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/core/logging/InAppLogger.android.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/core/network/AndroidDnsProvider.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/core/share/SharePlatform.android.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.android.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsForegroundService.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.android.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsNotificationActionReceiver.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.android.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.android.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/Mp4ParserRemux.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.android.kt",
    "composeApp/src/commonMain/composeResources/values-it/strings.xml",
    "composeApp/src/commonMain/composeResources/values/strings.xml",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/AppShellComponents.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/MainAppContent.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/MainTabsDestination.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/core/logging/InAppLogWriter.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/core/logging/InAppLogger.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/core/share/SharePlatform.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/BottomSheet.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/DropdownChip.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/EpisodeCodeFormat.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/AutoStreamDownloader.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsHlsSelectionSheet.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsModels.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsRepository.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsScreen.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsSettingsRepository.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/HlsDownloadEngine.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/HlsPlaylist.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerScreenRuntimeState.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerScreenRuntimeUi.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsScreen.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/NetworkSettingsRepository.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/streams/StreamsScreen.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/core/logging/InAppLogger.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/core/share/SharePlatform.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsClock.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.desktop.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.desktop.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/core/logging/InAppLogger.ios.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/core/share/SharePlatform.ios.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.ios.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.ios.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.ios.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.ios.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.ios.kt",
    "gradle/libs.versions.toml"
)

try {
    Write-Host "Clonazione upstream ($UpstreamUrl, branch: $UpstreamBranch)..." -ForegroundColor Yellow
    $env:GIT_LFS_SKIP_SMUDGE = "1"
    # Clone con storia completa: git apply --3way sui file delle patch 05+ richiede
    # i blobs degli antenati, che un clone shallow non contiene.
    git clone --branch $UpstreamBranch $UpstreamUrl $testDir --quiet

    $pinSha = (Get-Content (Join-Path $PSScriptRoot "..\.last_built_upstream_sha") -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($pinSha) {
        Write-Host "Pinning upstream allo SHA: $pinSha (da .last_built_upstream_sha)..." -ForegroundColor Yellow
        Push-Location $testDir
        git checkout $pinSha --quiet
        if ($LASTEXITCODE -ne 0) {
            Pop-Location
            throw "Impossibile fare checkout dello SHA pinnato $pinSha"
        }
        Pop-Location
    }
    
    Push-Location $testDir

    for ($i = 1; $i -le 3; $i++) {
        $prefix = "{0:D2}-" -f $i
        $patchFile = Get-ChildItem -Path $PatchesDir -Filter "$prefix*.patch" | Select-Object -First 1
        Write-Host "Applicazione patch $($patchFile.Name)..." -ForegroundColor Yellow
        git apply --ignore-space-change --3way "$($patchFile.FullName)"
        if ($LASTEXITCODE -ne 0) {
            throw "Errore durante l'applicazione di $($patchFile.Name)"
        }
    }

    Write-Host "Copia file aggiornati da NuvioMobile..." -ForegroundColor Yellow
    foreach ($rel in $files04) {
        $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
        $dst = Join-Path $testDir ($rel -replace '/', '\')
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Copy-Item -Path $src -Destination $dst -Force
    }

    git add -N .
    $patch04Path = Join-Path $PatchesDir "04-plugin-hls-downloads.patch"
    Write-Host "Generazione git diff per 04-plugin-hls-downloads.patch..." -ForegroundColor Yellow
    git diff --binary "--output=$patch04Path" -- $files04
    Write-Host "Patch 04 aggiornata con successo! Dimensione: $((Get-Item $patch04Path).Length) bytes" -ForegroundColor Green

} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pulizia completata." -ForegroundColor Cyan
}
