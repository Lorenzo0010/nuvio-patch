# PowerShell Script to extract Enhanced patches and native assets from albyalex96/NuvioMobile
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite",
    [string]$ForkUrl = "https://github.com/albyalex96/NuvioMobile.git",
    [string]$ForkBranch = "app/enhanced",
    [string]$OutputDir = "$PSScriptRoot\..\patches",
    [string]$ExtraLibsDir = "$PSScriptRoot\..\assets\extra_libs",
    [string]$JniLibsDir = "$PSScriptRoot\..\assets\jniLibs"
)

Write-Host "=== Nuvio Enhanced Patch Extractor ===" -ForegroundColor Cyan

$tempDir = "$env:TEMP\nuvio_patch_extract_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    $env:GIT_LFS_SKIP_SMUDGE = "1"
    Write-Host "Clonazione fork Enhanced ($ForkBranch)..." -ForegroundColor Yellow
    git clone --branch $ForkBranch $ForkUrl $tempDir --quiet
    
    Push-Location $tempDir
    
    Write-Host "Configurazione remote upstream ($UpstreamUrl)..." -ForegroundColor Yellow
    git remote add upstream $UpstreamUrl
    git fetch upstream $UpstreamBranch --depth 100 --quiet
    
    $baseCommit = git merge-base "upstream/$UpstreamBranch" HEAD
    Write-Host "Base commit comune: $baseCommit" -ForegroundColor Green
    
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    } else {
        Remove-Item "$OutputDir\*.patch" -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Copia delle librerie binarie e native..." -ForegroundColor Yellow
    if (Test-Path "composeApp\libs") {
        if (-not (Test-Path $ExtraLibsDir)) { New-Item -ItemType Directory -Path $ExtraLibsDir -Force | Out-Null }
        Copy-Item "composeApp\libs\*" -Destination $ExtraLibsDir -Recurse -Force
        Write-Host "Librerie .aar/.jar copiate in $ExtraLibsDir" -ForegroundColor Green
    }
    
    if (Test-Path "composeApp\src\androidMain\jniLibs") {
        if (-not (Test-Path $JniLibsDir)) { New-Item -ItemType Directory -Path $JniLibsDir -Force | Out-Null }
        Copy-Item "composeApp\src\androidMain\jniLibs\*" -Destination $JniLibsDir -Recurse -Force
        Write-Host "Librerie native .so copiate in $JniLibsDir" -ForegroundColor Green
    }
    
    Write-Host "Generazione patch unificata del codice..." -ForegroundColor Yellow
    $patchPath = Join-Path $OutputDir "nuvio-enhanced-code.patch"
    git diff --binary --output="$patchPath" "upstream/$UpstreamBranch..HEAD" -- ":(exclude)composeApp/src/androidMain/jniLibs" ":(exclude)composeApp/libs" ":(exclude)composeApp/src/desktopMain/native" ":(exclude)*.dll"
    
    $patchItem = Get-Item $patchPath
    Write-Host "Patch generata con successo: $($patchItem.Name) ($([math]::Round($patchItem.Length/1MB, 2)) MB)" -ForegroundColor Green
    
} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Operazione completata." -ForegroundColor Cyan
}
