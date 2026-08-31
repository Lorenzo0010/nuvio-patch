# PowerShell script to apply all modular patches sequentially
param (
    [string]$TargetDir = (Get-Location).Path,
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$ExtraLibsDir = "$PSScriptRoot\..\assets\extra_libs",
    [string]$JniLibsDir = "$PSScriptRoot\..\assets\jniLibs"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Nuvio Modular Patch Applicator (PS)   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Target Directory: $TargetDir" -ForegroundColor Gray
Write-Host "Patches Directory: $PatchesDir" -ForegroundColor Gray

if (-not (Test-Path $TargetDir)) {
    Write-Error "Target directory does not exist: $TargetDir"
    exit 1
}

$patchFiles = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Where-Object { $_.Name -match "^\d+-" } | Sort-Object Name

if ($patchFiles.Count -eq 0) {
    # Fallback to any patch files if not numbered
    $patchFiles = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Sort-Object Name
}

if ($patchFiles.Count -eq 0) {
    Write-Error "No .patch files found in $PatchesDir!"
    exit 1
}

Write-Host "`nTrovate $($patchFiles.Count) patch da applicare:" -ForegroundColor Yellow
foreach ($p in $patchFiles) {
    Write-Host "  - $($p.Name)" -ForegroundColor Gray
}

Push-Location $TargetDir
try {
    $hasError = $false
    foreach ($patch in $patchFiles) {
        Write-Host "`nApplicazione patch: $($patch.Name)..." -ForegroundColor Yellow
        $patchFullPath = $patch.FullName
        
        # Test applicability
        git apply --check --3way "$patchFullPath" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  Attenzione: git apply --check ha segnalato potenziali conflitti. Tentativo con fallback 3-way..." -ForegroundColor DarkYellow
        }

        git apply --3way "$patchFullPath"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ ERRORE: Fallita applicazione della patch '$($patch.Name)'!" -ForegroundColor Red
            Write-Host "Suggerimento: Verifica i conflitti nei file interessati dalla patch." -ForegroundColor Yellow
            $hasError = $true
            break
        } else {
            Write-Host "✅ Patch '$($patch.Name)' applicata con successo!" -ForegroundColor Green
        }
    }

    if ($hasError) {
        Write-Error "`nProcesso interrotto a causa di errori nell'applicazione delle patch."
        exit 1
    }

    # Copia asset opzionali
    if (Test-Path $ExtraLibsDir) {
        if (-not (Test-Path "composeApp\libs")) { New-Item -ItemType Directory -Path "composeApp\libs" -Force | Out-Null }
        Copy-Item "$ExtraLibsDir\*" -Destination "composeApp\libs" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "📦 Librerie extra_libs verificate e copiate." -ForegroundColor Green
    }

    if (Test-Path $JniLibsDir) {
        if (-not (Test-Path "composeApp\src\androidMain\jniLibs")) { New-Item -ItemType Directory -Path "composeApp\src\androidMain\jniLibs" -Force | Out-Null }
        Copy-Item "$JniLibsDir\*" -Destination "composeApp\src\androidMain\jniLibs" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "📦 Librerie native jniLibs verificate e copiate." -ForegroundColor Green
    }

    Write-Host "`n🎉 Tutte le patch sono state applicate con successo!" -ForegroundColor Green
} finally {
    Pop-Location
}
