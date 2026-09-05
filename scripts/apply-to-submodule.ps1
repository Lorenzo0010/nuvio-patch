# Apply all patches in patches/ to NuvioMobile submodule
$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$patchesDir = "$rootDir\patches"
$submoduleDir = "$rootDir\NuvioMobile"

Push-Location $submoduleDir
try {
    $patchFiles = Get-ChildItem -Path $patchesDir -Filter "*.patch" | Sort-Object Name
    foreach ($patch in $patchFiles) {
        Write-Host "Applying $($patch.Name)..." -ForegroundColor Yellow
        git apply --3way "$($patch.FullName)"
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed applying $($patch.Name)"
            exit 1
        }
    }
    Write-Host "All patches applied successfully!" -ForegroundColor Green

    # Copy extra_libs
    if (Test-Path "$rootDir\assets\extra_libs") {
        if (-not (Test-Path "composeApp\libs")) { New-Item -ItemType Directory -Path "composeApp\libs" -Force | Out-Null }
        Copy-Item "$rootDir\assets\extra_libs\*" -Destination "composeApp\libs" -Recurse -Force
        Write-Host "Copied extra_libs." -ForegroundColor Green
    }

    # Copy jniLibs
    if (Test-Path "$rootDir\assets\jniLibs") {
        if (-not (Test-Path "composeApp\src\androidMain\jniLibs")) { New-Item -ItemType Directory -Path "composeApp\src\androidMain\jniLibs" -Force | Out-Null }
        Copy-Item "$rootDir\assets\jniLibs\*" -Destination "composeApp\src\androidMain\jniLibs" -Recurse -Force
        Write-Host "Copied jniLibs." -ForegroundColor Green
    }
} finally {
    Pop-Location
}
