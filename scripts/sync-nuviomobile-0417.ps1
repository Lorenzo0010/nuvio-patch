$ErrorActionPreference = "Stop"

$target = "F:\GitHub\nuvio\NuvioMobile"
$patchesDir = "F:\GitHub\nuvio\patches"

# Backup local.properties
$lp = Get-Content "$target\local.properties"

Push-Location $target
& "C:\Program Files\Git\cmd\git.exe" checkout -f 74492b2621bcdc374c0fbeebdacf641f0d481c14
& "C:\Program Files\Git\cmd\git.exe" clean -fd
Pop-Location

# Restore local.properties
Set-Content "$target\local.properties" -Value $lp

# Copy assets
powershell -ExecutionPolicy Bypass -File "F:\GitHub\nuvio\scripts\copy-assets.ps1"

# Apply patches in order
Push-Location $target
$patches = Get-ChildItem "$patchesDir\*.patch" | Sort-Object Name
foreach ($p in $patches) {
    Write-Host "Applying patch: $($p.Name)"
    & "C:\Program Files\Git\cmd\git.exe" apply --ignore-space-change --3way "$($p.FullName)"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED to apply: $($p.Name)" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "SUCCESS: $($p.Name)" -ForegroundColor Green
    }
}
Pop-Location
Write-Host "NuvioMobile is now at 0.4.17 + all 5 patches!" -ForegroundColor Green
