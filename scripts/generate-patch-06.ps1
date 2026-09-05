# PowerShell script to generate patches/06-launcher-widget.patch cleanly against upstream + patches 01-05
param (
    [string]$UpstreamUrl = "https://github.com/NuvioMedia/NuvioMobile.git",
    [string]$UpstreamBranch = "cmp-rewrite"
)

$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
$patchesDir = "$rootDir\patches"
$tempDir = "$env:TEMP\nuvio_gen_06_$(Get-Random)"

Write-Host "Creating temp working directory: $tempDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    $env:GIT_LFS_SKIP_SMUDGE = "1"
    Write-Host "Cloning upstream cmp-rewrite..." -ForegroundColor Yellow
    git clone --branch $UpstreamBranch $UpstreamUrl $tempDir --depth 50 --quiet

    Push-Location $tempDir

    # Apply patches 01 to 05
    $patches = @(
        "$patchesDir\01-branding-and-config.patch",
        "$patchesDir\02-app-updater.patch",
        "$patchesDir\03-live-tv.patch",
        "$patchesDir\04-plugin-hls-downloads.patch",
        "$patchesDir\05-bugfixes.patch"
    )

    foreach ($p in $patches) {
        Write-Host "Applying $(Split-Path $p -Leaf)..." -ForegroundColor Yellow
        git apply --3way "$p"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed applying $(Split-Path $p -Leaf)"
        }
    }

    # Commit state 01-05
    git config user.name "Nuvio Builder"
    git config user.email "builder@nuvio.local"
    git add -A
    git commit -m "Base 01-05 applied" --quiet

    Write-Host "Applying widget modifications on top of 01-05..." -ForegroundColor Yellow

    # Copy new widget files from NuvioMobile
    $sourceMobile = "$rootDir\NuvioMobile"

    # Widget Kotlin files
    New-Item -ItemType Directory -Path "composeApp\src\androidMain\kotlin\com\nuvio\app\widget" -Force | Out-Null
    Copy-Item "$sourceMobile\composeApp\src\androidMain\kotlin\com\nuvio\app\widget\*" -Destination "composeApp\src\androidMain\kotlin\com\nuvio\app\widget\" -Force

    # Widget XML Provider Info
    New-Item -ItemType Directory -Path "composeApp\src\androidMain\res\xml" -Force | Out-Null
    Copy-Item "$sourceMobile\composeApp\src\androidMain\res\xml\nuvio_app_widget_info.xml" -Destination "composeApp\src\androidMain\res\xml\" -Force
    Copy-Item "$sourceMobile\composeApp\src\androidMain\res\xml\nuvio_navbar_widget_info.xml" -Destination "composeApp\src\androidMain\res\xml\" -Force

    # Widget Drawables
    $drawables = @(
        "ic_widget_library.xml", "ic_widget_livetv.xml", "ic_widget_play.xml",
        "ic_widget_poster_placeholder.xml", "ic_widget_search.xml", "ic_widget_download.xml",
        "ic_widget_brand_logo.xml", "widget_background.xml", "widget_button_bg.xml",
        "widget_nav_button_bg.xml", "widget_card_bg.xml", "widget_progress_bar.xml"
    )
    foreach ($d in $drawables) {
        Copy-Item "$sourceMobile\composeApp\src\androidMain\res\drawable\$d" -Destination "composeApp\src\androidMain\res\drawable\" -Force
    }

    # Widget Layouts
    $layouts = @(
        "widget_nuvio_compact.xml", "widget_nuvio_large.xml", "widget_nuvio_medium.xml",
        "widget_nuvio_single.xml", "widget_nuvio_tall.xml", "widget_nuvio_navbar.xml",
        "widget_nuvio_navbar_compact.xml"
    )
    foreach ($l in $layouts) {
        Copy-Item "$sourceMobile\composeApp\src\androidMain\res\layout\$l" -Destination "composeApp\src\androidMain\res\layout\" -Force
    }

    # Widget Strings
    Copy-Item "$sourceMobile\composeApp\src\androidMain\res\values\strings.xml" -Destination "composeApp\src\androidMain\res\values\" -Force

    # Modify AndroidManifest.xml
    $manifestFile = "androidApp\src\main\AndroidManifest.xml"
    $manifestContent = Get-Content $manifestFile -Raw
    $receiverXml = @"
        <receiver
            android:name="com.nuvio.app.widget.NuvioAppWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/nuvio_app_widget_info" />
        </receiver>
        <receiver
            android:name="com.nuvio.app.widget.NuvioNavbarWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/nuvio_navbar_widget_info" />
        </receiver>
"@
    if (-not $manifestContent.Contains("com.nuvio.app.widget.NuvioAppWidgetProvider")) {
        $manifestContent = $manifestContent.Replace("    </application>", "$receiverXml`n    </application>")
        Set-Content -Path $manifestFile -Value $manifestContent -NoNewline
    }

    # Modify MainActivity.kt
    $mainActivityFile = "composeApp\src\androidMain\kotlin\com\nuvio/app\MainActivity.kt"
    $mainActivityContent = Get-Content $mainActivityFile -Raw
    $onResumeCode = @"
    override fun onResume() {
        super.onResume()
        com.nuvio.app.widget.NuvioAppWidgetProvider.notifyDataChanged(this)
    }

    override fun onNewIntent(intent: Intent) {
"@
    if (-not $mainActivityContent.Contains("NuvioAppWidgetProvider.notifyDataChanged")) {
        $mainActivityContent = $mainActivityContent.Replace("    override fun onNewIntent(intent: Intent) {", $onResumeCode)
        Set-Content -Path $mainActivityFile -Value $mainActivityContent -NoNewline
    }

    # Modify LiveTvStorage.android.kt
    $liveTvFile = "composeApp\src\androidMain\kotlin\com\nuvio\app\features\livetv\LiveTvStorage.android.kt"
    $liveTvContent = Get-Content $liveTvFile -Raw
    if (-not $liveTvContent.Contains("appContext = context.applicationContext")) {
        $target1 = "    private var preferences: SharedPreferences? = null`r`n`r`n    fun initialize(context: Context) {`r`n        preferences = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)"
        $target1_lf = "    private var preferences: SharedPreferences? = null`n`n    fun initialize(context: Context) {`n        preferences = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)"
        $replacement1 = "    private var preferences: SharedPreferences? = null`n    private var appContext: Context? = null`n`n    fun initialize(context: Context) {`n        appContext = context.applicationContext`n        preferences = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)"
        
        if ($liveTvContent.Contains($target1)) {
            $liveTvContent = $liveTvContent.Replace($target1, $replacement1)
        } elseif ($liveTvContent.Contains($target1_lf)) {
            $liveTvContent = $liveTvContent.Replace($target1_lf, $replacement1)
        } else {
            # Regex replacement fallback
            $liveTvContent = $liveTvContent -replace 'private var preferences: SharedPreferences\? = null\s+fun initialize\(context: Context\) \{', "private var preferences: SharedPreferences? = null`n    private var appContext: Context? = null`n`n    fun initialize(context: Context) {`n        appContext = context.applicationContext"
        }

        # in saveRecentChannel
        $liveTvContent = $liveTvContent.Replace("        }?.apply()`r`n    }`r`n}", "        }?.apply()`r`n`r`n        appContext?.let { ctx ->`r`n            com.nuvio.app.widget.NuvioAppWidgetProvider.notifyDataChanged(ctx)`r`n        }`r`n    }`r`n}")
        if (-not $liveTvContent.Contains("NuvioAppWidgetProvider.notifyDataChanged")) {
            $liveTvContent = $liveTvContent.Replace("        }?.apply()`n    }`n}", "        }?.apply()`n`n        appContext?.let { ctx ->`n            com.nuvio.app.widget.NuvioAppWidgetProvider.notifyDataChanged(ctx)`n        }`n    }`n}")
        }
        Set-Content -Path $liveTvFile -Value $liveTvContent -NoNewline
    }

    # Modify WatchProgressStorage.android.kt
    $watchFile = "composeApp\src\androidMain\kotlin\com\nuvio\app\features\watchprogress\WatchProgressStorage.android.kt"
    $watchContent = Get-Content $watchFile -Raw
    if (-not $watchContent.Contains("last_active_profile_id")) {
        $watchContent = $watchContent -replace 'private var preferences: SharedPreferences\? = null\s+fun initialize\(context: Context\) \{', "private var preferences: SharedPreferences? = null`n    private var appContext: Context? = null`n`n    fun initialize(context: Context) {`n        appContext = context.applicationContext"
        $watchContent = $watchContent.Replace('?.putString("${payloadKey}_$profileId", payload)', "?.putString(`"`${payloadKey}_`$profileId`", payload)`n            ?.putInt(`"last_active_profile_id`", profileId)")
        $watchContent = $watchContent.Replace('?.apply()', "?.apply()`n`n        appContext?.let { ctx ->`n            com.nuvio.app.widget.NuvioAppWidgetProvider.notifyDataChanged(ctx)`n        }")
        Set-Content -Path $watchFile -Value $watchContent -NoNewline
    }

    # Modify AppUrlBridge.kt
    $urlBridgeFile = "composeApp\src\commonMain\kotlin\com\nuvio\app\core\deeplink\AppUrlBridge.kt"
    $urlBridgeContent = Get-Content $urlBridgeFile -Raw
    if (-not $urlBridgeContent.Contains("data object Library : AppDeepLink")) {
        $urlBridgeContent = $urlBridgeContent.Replace("    data object Downloads : AppDeepLink", "    data object Downloads : AppDeepLink`n    data object Library : AppDeepLink`n    data object LiveTv : AppDeepLink`n    data object Search : AppDeepLink")
        $urlBridgeContent = $urlBridgeContent.Replace('"downloads" -> AppDeepLink.Downloads', "`"downloads`" -> AppDeepLink.Downloads`n        `"library`" -> AppDeepLink.Library`n        `"livetv`", `"live`", `"tv`" -> AppDeepLink.LiveTv`n        `"search`", `"discover`" -> AppDeepLink.Search")
        Set-Content -Path $urlBridgeFile -Value $urlBridgeContent -NoNewline
    }

    # Modify MainAppContent.kt
    $mainAppFile = "composeApp\src\commonMain\kotlin\com\nuvio\app\MainAppContent.kt"
    $mainAppContent = Get-Content $mainAppFile -Raw
    if (-not $mainAppContent.Contains("AppDeepLink.Library ->")) {
        $extraDeepLinks = @"
                    AppDeepLink.Library -> {
                        activateTab(AppScreenTab.Library)
                        AppDeepLinkRepository.markConsumed(deepLink)
                    }

                    AppDeepLink.Search -> {
                        activateTab(AppScreenTab.Search)
                        AppDeepLinkRepository.markConsumed(deepLink)
                    }

                    AppDeepLink.LiveTv -> {
                        AppScreenTab.entries.firstOrNull { it.name.equals("LiveTv", ignoreCase = true) }?.let { activateTab(it) }
                        AppDeepLinkRepository.markConsumed(deepLink)
                    }
"@
        $mainAppContent = $mainAppContent.Replace("                        AppDeepLinkRepository.markConsumed(deepLink)`r`n                    }`r`n`r`n                    null -> Unit", "                        AppDeepLinkRepository.markConsumed(deepLink)`r`n                    }`r`n`r`n$extraDeepLinks`r`n`r`n                    null -> Unit")
        if (-not $mainAppContent.Contains("AppDeepLink.Library ->")) {
            $mainAppContent = $mainAppContent.Replace("                        AppDeepLinkRepository.markConsumed(deepLink)`n                    }`n`n                    null -> Unit", "                        AppDeepLinkRepository.markConsumed(deepLink)`n                    }`n`n$extraDeepLinks`n`n                    null -> Unit")
        }
        Set-Content -Path $mainAppFile -Value $mainAppContent -NoNewline
    }

    Write-Host "Staging all changes and generating git diff..." -ForegroundColor Yellow
    git add -A
    $diffOutput = git diff --cached --binary
    
    $outPatch = "$patchesDir\06-launcher-widget.patch"
    [IO.File]::WriteAllText($outPatch, ($diffOutput -join "`n") + "`n", [Text.Encoding]::UTF8)
    Write-Host "Generated clean patch at $outPatch" -ForegroundColor Green

    # Test applying the newly generated patch
    Write-Host "Testing patch with git apply --check..." -ForegroundColor Yellow
    git reset --hard HEAD --quiet
    git apply --check "$outPatch"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Patch 06 check passed cleanly!" -ForegroundColor Green
    } else {
        Write-Error "❌ Patch 06 check failed!"
    }

} finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cleaned up temp directory." -ForegroundColor Cyan
}
