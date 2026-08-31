# PowerShell script to test applying all modular patches on top of upstream cmp-rewrite
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$ExtraLibsDir = "$PSScriptRoot\..\assets\extra_libs",
    [string]$JniLibsDir = "$PSScriptRoot\..\assets\jniLibs"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Nuvio Patch Applicability Test (PS)   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$testDir = "$env:TEMP\nuvio_patch_test_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

try {
    Write-Host "Clonazione upstream ($UpstreamUrl, branch: $UpstreamBranch)..." -ForegroundColor Yellow
    $env:GIT_LFS_SKIP_SMUDGE = "1"
    git clone --branch $UpstreamBranch $UpstreamUrl $testDir --depth 50 --quiet
    
    Push-Location $testDir

    $patchFiles = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Where-Object { $_.Name -match "^\d+-" } | Sort-Object Name
    if ($patchFiles.Count -eq 0) {
        $patchFiles = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Sort-Object Name
    }

    if ($patchFiles.Count -eq 0) {
        Write-Error "Nessun file .patch trovato in $PatchesDir!"
        return
    }

    Write-Host "Trovate $($patchFiles.Count) patch da testare:" -ForegroundColor Yellow
    foreach ($p in $patchFiles) {
        Write-Host "  - $($p.Name)" -ForegroundColor Gray
    }

    $failed = $false
    foreach ($patch in $patchFiles) {
        Write-Host "`nTest applicazione patch: $($patch.Name)..." -ForegroundColor Yellow
        git apply --3way "$($patch.FullName)"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Errore durante l'applicazione di '$($patch.Name)'!" -ForegroundColor Red
            $failed = $true
            break
        } else {
            Write-Host "✅ Patch '$($patch.Name)' applicata con successo!" -ForegroundColor Green
        }
    }

    if ($failed) {
        Write-Host "`n❌ Test fallito: Una o più patch non sono compatibili con l'upstream attuale." -ForegroundColor Red
        return
    }

    # Copia asset
    if (Test-Path $ExtraLibsDir) {
        if (-not (Test-Path "composeApp\libs")) { New-Item -ItemType Directory -Path "composeApp\libs" -Force | Out-Null }
        Copy-Item "$ExtraLibsDir\*" -Destination "composeApp\libs" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Librerie extra_libs verificate e copiate." -ForegroundColor Green
    }

    if (Test-Path $JniLibsDir) {
        if (-not (Test-Path "composeApp\src\androidMain\jniLibs")) { New-Item -ItemType Directory -Path "composeApp\src\androidMain\jniLibs" -Force | Out-Null }
        Copy-Item "$JniLibsDir\*" -Destination "composeApp\src\androidMain\jniLibs" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Librerie native jniLibs verificate e copiate." -ForegroundColor Green
    }

    Write-Host "`n🎉 TEST SUPERATO: Tutte le patch sono 100% compatibili con l'upstream!" -ForegroundColor Green

} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Pulizia cartella di test completata." -ForegroundColor Cyan
}
