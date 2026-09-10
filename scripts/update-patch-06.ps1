# Script to regenerate patches/06-plugin-crypto.patch based on latest NuvioMobile changes
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$NuvioMobileDir = "$PSScriptRoot\..\NuvioMobile"
)

$testDir = "$env:TEMP\nuvio_patch_06_gen_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

$files06 = @(
    "composeApp/src/fullCommonMain/kotlin/com/nuvio/app/features/plugins/runtime/js/JsBindings.kt"
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

    for ($i = 1; $i -le 5; $i++) {
        $prefix = "{0:D2}-" -f $i
        $patchFile = Get-ChildItem -Path $PatchesDir -Filter "$prefix*.patch" | Select-Object -First 1
        Write-Host "Applicazione patch $($patchFile.Name)..." -ForegroundColor Yellow
        git apply --ignore-space-change --3way "$($patchFile.FullName)"
        if ($LASTEXITCODE -ne 0) {
            throw "Errore durante l'applicazione di $($patchFile.Name)"
        }
    }

    Write-Host "Copia file aggiornati da NuvioMobile..." -ForegroundColor Yellow
    foreach ($rel in $files06) {
        $src = Join-Path $NuvioMobileDir ($rel -replace '/', '\')
        $dst = Join-Path $testDir ($rel -replace '/', '\')
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Copy-Item -Path $src -Destination $dst -Force
    }

    git add -N .
    $patch06Path = Join-Path $PatchesDir "06-plugin-crypto.patch"
    Write-Host "Generazione git diff per 06-plugin-crypto.patch..." -ForegroundColor Yellow
    git diff --binary "--output=$patch06Path" -- $files06
    Write-Host "Patch 06 aggiornata con successo! Dimensione: $((Get-Item $patch06Path).Length) bytes" -ForegroundColor Green

} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pulizia completata." -ForegroundColor Cyan
}
