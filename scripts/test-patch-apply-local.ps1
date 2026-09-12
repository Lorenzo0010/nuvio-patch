# PowerShell script to test applying all modular patches on top of local upstream 0.4.17 archive
param (
    [string]$PatchesDir = "$PSScriptRoot\..\patches",
    [string]$Archive = "C:\Users\loren\AppData\Local\Temp\tree_0417.tar"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Nuvio Patch Applicability Test (0.4.17)   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

if (-not (Test-Path $Archive)) {
    Write-Host "Creating archive from NuvioMobile/.git..." -ForegroundColor Yellow
    Push-Location "C:\"
    & "C:\Program Files\Git\cmd\git.exe" --git-dir="F:/GitHub/nuvio/NuvioMobile/.git" archive --format=tar --output=$Archive 74492b2621bcdc374c0fbeebdacf641f0d481c14
    Pop-Location
}

$testDir = "C:\Users\loren\AppData\Local\Temp\nuvio_patch_test_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

try {
    Push-Location $testDir
    tar -xf $Archive
    & "C:\Program Files\Git\cmd\git.exe" init --quiet
    & "C:\Program Files\Git\cmd\git.exe" add -A
    & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "upstream 0.4.17" --quiet

    $patchFiles = Get-ChildItem -Path $PatchesDir -Filter "*.patch" | Where-Object { $_.Name -match "^\d+-" } | Sort-Object Name

    Write-Host "Trovate $($patchFiles.Count) patch da testare:" -ForegroundColor Yellow
    foreach ($p in $patchFiles) {
        Write-Host "  - $($p.Name)" -ForegroundColor Gray
    }

    $failed = $false
    foreach ($patch in $patchFiles) {
        Write-Host "`nTest applicazione patch: $($patch.Name)..." -ForegroundColor Yellow
        & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change --3way "$($patch.FullName)"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Errore durante l'applicazione di '$($patch.Name)'!" -ForegroundColor Red
            $failed = $true
            break
        } else {
            Write-Host "✅ Applicata con successo: $($patch.Name)" -ForegroundColor Green
            & "C:\Program Files\Git\cmd\git.exe" add -A
            & "C:\Program Files\Git\cmd\git.exe" -c user.name="test" -c user.email="test@test.com" commit -m "$($patch.Name)" --quiet
        }
    }

    if (-not $failed) {
        Write-Host "`n🎉 Tutte le patch sono compatibili e applicabili su 0.4.17!" -ForegroundColor Green
    } else {
        exit 1
    }
} finally {
    Pop-Location
    Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
}
