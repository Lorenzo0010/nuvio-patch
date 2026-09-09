# Script to regenerate patches/07-stream-prefetch.patch based on latest NuvioMobile changes
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$NuvioMobileDir = "$PSScriptRoot\..\NuvioMobile"
)

$testDir = "$env:TEMP\nuvio_patch_07_gen_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

$files07 = @(
    "composeApp/src/commonMain/composeResources/values-it/strings.xml",
    "composeApp/src/commonMain/composeResources/values/strings.xml",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/details/MetaDetailsScreen.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/details/MetaScreenSettingsRepository.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/details/components/DetailActionButtons.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/details/components/DetailSeriesContent.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/AutoStreamDownloader.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadDeleteConfirmationDialog.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsScreen.kt",
    "composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.android.kt",
    "composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.desktop.kt",
    "composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.ios.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/PatchesPlusSettingsPage.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/SettingsModels.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/SettingsRootPage.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/SettingsScreen.kt",
    "composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/SettingsSearch.kt",
    "iosApp/Configuration/Version.xcconfig"
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

    for ($i = 1; $i -le 6; $i++) {
        $prefix = "{0:D2}-" -f $i
        $patchFile = Get-ChildItem -Path $PatchesDir -Filter "$prefix*.patch" | Select-Object -First 1
        Write-Host "Applicazione patch $($patchFile.Name)..." -ForegroundColor Yellow
        git apply --ignore-space-change --3way "$($patchFile.FullName)"
        if ($LASTEXITCODE -ne 0) {
            throw "Errore durante l'applicazione di $($patchFile.Name)"
        }
    }

    Write-Host "Copia file aggiornati da NuvioMobile..." -ForegroundColor Yellow
    foreach ($rel in $files07) {
        $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
        $dst = Join-Path $testDir ($rel -replace '/', '\')
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Copy-Item -Path $src -Destination $dst -Force
    }

    git add -N .
    $patch07Path = Join-Path $PatchesDir "07-stream-prefetch.patch"
    Write-Host "Generazione git diff per 07-stream-prefetch.patch..." -ForegroundColor Yellow
    
    # Generate unified diff directly without PowerShell stdout piping corruption
    git diff --binary "--output=$patch07Path" -- $files07
    Write-Host "Patch 07 aggiornata con successo! Dimensione: $((Get-Item $patch07Path).Length) bytes" -ForegroundColor Green

} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pulizia completata." -ForegroundColor Cyan
}
