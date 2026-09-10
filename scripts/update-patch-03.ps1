# Script to regenerate patches/03-live-tv.patch based on latest NuvioMobile changes
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$NuvioMobileDir = "$PSScriptRoot\..\NuvioMobile"
)

$testDir = "$env:TEMP\nuvio_patch_03_gen_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

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

try {
    Write-Host "Clonazione upstream ($UpstreamUrl, branch: $UpstreamBranch)..." -ForegroundColor Yellow
    $env:GIT_LFS_SKIP_SMUDGE = "1"
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

    for ($i = 1; $i -le 2; $i++) {
        $prefix = "{0:D2}-" -f $i
        $patchFile = Get-ChildItem -Path $PatchesDir -Filter "$prefix*.patch" | Select-Object -First 1
        Write-Host "Applicazione patch $($patchFile.Name)..." -ForegroundColor Yellow
        git apply --ignore-space-change --3way "$($patchFile.FullName)"
        if ($LASTEXITCODE -ne 0) {
            throw "Errore durante l'applicazione di $($patchFile.Name)"
        }
    }

    Write-Host "Copia file aggiornati da NuvioMobile..." -ForegroundColor Yellow
    foreach ($rel in $files03) {
        $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
        $dst = Join-Path $testDir ($rel -replace '/', '\')
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Copy-Item -Path $src -Destination $dst -Force
    }

    git add -N .
    $patch03Path = Join-Path $PatchesDir "03-live-tv.patch"
    Write-Host "Generazione git diff per 03-live-tv.patch..." -ForegroundColor Yellow
    git diff --binary "--output=$patch03Path" -- $files03
    Write-Host "Patch 03 aggiornata con successo! Dimensione: $((Get-Item $patch03Path).Length) bytes" -ForegroundColor Green

} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pulizia completata." -ForegroundColor Cyan
}
