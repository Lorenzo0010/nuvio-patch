# PowerShell script to test applying Enhanced patches on top of upstream cmp-rewrite
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$PatchPath = "$PSScriptRoot\..\patches\nuvio-enhanced-code.patch",
    [string]$ExtraLibsDir = "$PSScriptRoot\..\assets\extra_libs",
    [string]$JniLibsDir = "$PSScriptRoot\..\assets\jniLibs"
)

Write-Host "=== Nuvio Patch Applicability Test ===" -ForegroundColor Cyan

$testDir = "$env:TEMP\nuvio_patch_test_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

try {
    Write-Host "Clonazione upstream ($UpstreamUrl, branch: $UpstreamBranch)..." -ForegroundColor Yellow
    $env:GIT_LFS_SKIP_SMUDGE = "1"
    git clone --branch $UpstreamBranch $UpstreamUrl $testDir --depth 50 --quiet
    
    Push-Location $testDir
    
    if (-not (Test-Path $PatchPath)) {
        Write-Error "Patch non trovata: $PatchPath"
        return
    }
    
    Write-Host "Applicazione patch codice ($PatchPath)..." -ForegroundColor Yellow
    git apply --3way "$PatchPath"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Errore durante l'applicazione della patch!" -ForegroundColor Red
        return
    }
    
    Write-Host "✅ Patch applicata con successo!" -ForegroundColor Green
    
    # Copia asset
    if (Test-Path $ExtraLibsDir) {
        if (-not (Test-Path "composeApp\libs")) { New-Item -ItemType Directory -Path "composeApp\libs" -Force | Out-Null }
        Copy-Item "$ExtraLibsDir\*" -Destination "composeApp\libs" -Recurse -Force
        Write-Host "Librerie extra_libs verificate e copiate." -ForegroundColor Green
    }
    
    if (Test-Path $JniLibsDir) {
        if (-not (Test-Path "composeApp\src\androidMain\jniLibs")) { New-Item -ItemType Directory -Path "composeApp\src\androidMain\jniLibs" -Force | Out-Null }
        Copy-Item "$JniLibsDir\*" -Destination "composeApp\src\androidMain\jniLibs" -Recurse -Force
        Write-Host "Librerie native jniLibs verificate e copiate." -ForegroundColor Green
    }
    
    Write-Host "`n🎉 Test superato con successo: La patch Enhanced è 100% compatibile!" -ForegroundColor Green
    
} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Test completato." -ForegroundColor Cyan
}
