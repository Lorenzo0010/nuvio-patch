# Briefing Agente: Porting Patch Plus → Upstream 0.4.15

> **Data**: 2026-09-09
> **Repo**: `F:\GitHub\nuvio` (fork `Lorenzo0010/nuvio-patch`)
> **Working copy upstream**: `F:\GitHub\nuvio\NuvioMobile\`
> **Upstream URL**: `https://github.com/NuvioMedia/NuvioMobile.git`
> **Tag target**: `0.4.15` (SHA `83c409c401ad98b22eeb8a979859adddfa3eb8f4`)
> **SHA attuale (0.4.14)**: `e37794282b968812d059f8c77a9ea8a1eaa3b758`

---

## Obiettivo

Portare le patch Plus dal baseline **0.4.14** al nuovo baseline **0.4.15**, rispettando il principio:

> **La base 0.4.15 deve restare intatta. Le patch aggiungono funzionalita senza rimuovere ne rielaborare funzioni gia presenti nell upstream.**

Questo significa:
- I **5 nuovi file** che l upstream 0.4.15 ha introdotto per il sistema di download background (`AndroidDownloadScheduler`, `AndroidDownloadStore`, `AndroidDownloadTransfer`, `DownloadsTransferJobService`, `DownloadsTransferWorker`) devono essere **mantenuti** — non eliminati.
- I file Plus esistenti nella working copy (`DownloadsForegroundService.kt`, `HlsDownloadEngine.kt`, ecc.) devono essere **aggiunti come file nuovi** sopra all upstream 0.4.15 senza conflitto.
- Dove l upstream 0.4.15 ha modificato un file che le patch Plus integrano (es. `DownloadsRepository.kt`, `DownloadsNotificationActionReceiver.kt`), la logica Plus viene **aggiunta** alla versione 0.4.15 — non sovrascritta.

---

## FASE 0 — Preparazione della nuova working copy 0.4.15

```powershell
$workDir = "F:\GitHub\nuvio\NuvioMobile"
if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force }
git clone --branch 0.4.15 https://github.com/NuvioMedia/NuvioMobile.git $workDir
"83c409c401ad98b22eeb8a979859adddfa3eb8f4" | Set-Content "F:\GitHub\nuvio\.last_built_upstream_sha"
Push-Location $workDir
git apply --ignore-space-change --3way "F:\GitHub\nuvio\patches\01-branding-and-config.patch"
git apply --ignore-space-change --3way "F:\GitHub\nuvio\patches\02-app-updater.patch"
git apply --ignore-space-change --3way "F:\GitHub\nuvio\patches\03-live-tv.patch"
git apply --ignore-space-change --3way "F:\GitHub\nuvio\patches\05-bugfixes.patch"
git apply --ignore-space-change --3way "F:\GitHub\nuvio\patches\06-launcher-widget.patch"
Pop-Location
```

NOTA: Le patch 01-06 potrebbero avere conflitti minori dovuti alle modifiche 0.4.15. Risolverli mantenendo il contenuto upstream 0.4.15 come base e aggiungendo le modifiche Plus sopra.

## FASE 1 — Copia assets binari

```powershell
Copy-Item "F:\GitHub\nuvio\assets\extra_libs\*" "$workDir\composeApp\libs\" -Force
Copy-Item "F:\GitHub\nuvio\assets\jniLibs\*" "$workDir\composeApp\src\androidMain\jniLibs\" -Recurse -Force
```

---

## FASE 2 — Integrazione File Plus nel Baseline 0.4.15

### Regola fondamentale

- FILE NUOVO (non esiste in 0.4.15): copiarlo direttamente da NuvioMobile/, nessun conflitto.
- FILE MODIFICATO (esiste in 0.4.15 e lo modifica): partire dalla versione 0.4.15 e aggiungere la logica Plus incrementalmente.

### 2A — File NUOVI (solo Plus, non presenti in 0.4.15)

Questi file vanno copiati da `NuvioMobile/` working copy senza modifiche. Nessun conflitto con l upstream.

File Plus-only (gia nella working copy, da includere nella patch 04 aggiornata):

- `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsForegroundService.kt`
  Foreground service Plus: notifica download attivo, WakeLock, swap primario, retain/release thread-safe via Handler(mainLooper).

- `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/Mp4ParserRemux.kt`
  Remux MP4 con MediaMuxer (fMP4 to MP4, SPS/PPS extraction, track copy, validazione moov atom).

- `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.android.kt`
  Salvataggio file su Android + gestione directory downloads interni.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/HlsDownloadEngine.kt`
  Engine HLS: download parallelo segmenti, decrypt AES-128-CBC, riassemblaggio ordinato, stima dimensione da bitrate, supporto fMP4.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/HlsPlaylist.kt`
  Parser HLS: master playlist, varianti, media playlist, segmenti, cifratura, byterange.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsHlsSelectionSheet.kt`
  Sheet UI per selezione qualita/audio/sottotitoli HLS prima del download.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/AutoStreamDownloader.kt`
  Auto-download stream: prefetch URL, accodamento automatico al completamento stream.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.kt`
  Interfaccia common (expect) per salvataggio file.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadDeleteConfirmationDialog.kt`
  Dialog conferma eliminazione download.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsSettingsRepository.kt`
  Repository settings download (max paralleli, WiFi only, ecc.).

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.kt`
  Storage expect comune.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.kt`
  Pagina impostazioni download.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsScreen.kt`
  Schermata impostazioni download.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/features/settings/NetworkSettingsRepository.kt`
  Repository impostazioni rete.

- `composeApp/src/commonMain/kotlin/com/nuvio/app/core/logging/InAppLogWriter.kt`
- `composeApp/src/commonMain/kotlin/com/nuvio/app/core/logging/InAppLogger.kt`
- `composeApp/src/commonMain/kotlin/com/nuvio/app/core/share/SharePlatform.kt`
- `composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/BottomSheet.kt`
- `composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/DropdownChip.kt`
- `composeApp/src/commonMain/kotlin/com/nuvio/app/core/ui/EpisodeCodeFormat.kt`
- `composeApp/src/androidMain/kotlin/com/nuvio/app/core/logging/InAppLogger.android.kt`
- `composeApp/src/androidMain/kotlin/com/nuvio/app/core/network/AndroidDnsProvider.kt`
- `composeApp/src/androidMain/kotlin/com/nuvio/app/core/share/SharePlatform.android.kt`
- `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.android.kt`
- `composeApp/src/androidMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.android.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/core/logging/InAppLogger.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/core/share/SharePlatform.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsClock.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.desktop.kt`
- `composeApp/src/desktopMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.desktop.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/core/logging/InAppLogger.ios.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/core/share/SharePlatform.ios.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadFileSaver.ios.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.ios.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.ios.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/features/downloads/DownloadsStorage.ios.kt`
- `composeApp/src/iosMain/kotlin/com/nuvio/app/features/settings/DownloadsSettingsPage.ios.kt`

Azione: verificare che tutti questi file esistano in NuvioMobile/. Sono gia li dalla working copy Plus basata su 0.4.14. Includerli nella lista $files04 dello script update-patch-04.ps1.

---

### 2B — File MODIFICATI da 0.4.15 che richiedono merge manuale

#### FILE: `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.android.kt`

STATO: In 0.4.15 questo file e stato completamente riscritto per delegare ad AndroidDownloadScheduler.
AZIONE: NON sovrascrivere. Lasciare la versione 0.4.15 intatta.
RIMUOVERE dalla lista $files04 dello script update-patch-04.ps1.

Il DownloadsForegroundService Plus continua ad esistere come servizio ausiliario per i download HLS (che usano ancora OkHttp diretto). I download HTTP diretti usano il nuovo AndroidDownloadScheduler di 0.4.15.

#### FILE: `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsNotificationActionReceiver.kt`

STATO: In 0.4.15 aggiunge ricerca transfer da AndroidDownloadScheduler.store + fileName nell Intent.
AZIONE: NON sovrascrivere. Lasciare la versione 0.4.15 intatta.
RIMUOVERE dalla lista $files04.

#### FILE: `composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsLiveStatusPlatform.android.kt`

STATO 0.4.15: aggiunge notifyTransfer(item) public, rende notificationId() internal, aggiunge fileName a buildActionPendingIntent.
STATO Plus: aveva removeNotification(downloadId), onItemsChanged(items), buildNotification modificato.

AZIONE MERGE (partire dalla versione 0.4.15, aggiungere):
1. Dopo la funzione notifyTransfer(item: DownloadItem), aggiungere:
   ```kotlin
   internal fun removeNotification(downloadId: String) {
       val context = appContext ?: return
       runCatching {
           NotificationManagerCompat.from(context).apply {
               cancel(notificationId(downloadId))
               cancel(notificationId("inactive:$downloadId"))
           }
       }
   }
   ```
2. Verificare che onItemsChanged(items: List<DownloadItem>) esista — se mancante aggiungere:
   ```kotlin
   fun onItemsChanged(items: List<DownloadItem>) {
       items.forEach { item -> notifyTransfer(item) }
       // rimuovi notifiche per item non piu presenti
       val activeIds = items.map { it.id }.toSet()
       // cleanup stale notification IDs qui
   }
   ```
3. Mantenere tutte le funzioni 0.4.15 intatte.

#### FILE: `composeApp/src/androidMain/AndroidManifest.xml`

STATO 0.4.14: <manifest /> vuoto.
STATO 0.4.15: aggiunge permessi RUN_USER_INITIATED_JOBS, RECEIVE_BOOT_COMPLETED, FOREGROUND_SERVICE, FOREGROUND_SERVICE_DATA_SYNC + DownloadsTransferJobService + SystemForegroundService.
STATO Plus: aveva DownloadsForegroundService dichiarato.

AZIONE MERGE — il file risultante deve essere:
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.RUN_USER_INITIATED_JOBS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <application>
        <!-- Servizi upstream 0.4.15 (mantenere intatti) -->
        <service
            android:name="com.nuvio.app.features.downloads.DownloadsTransferJobService"
            android:permission="android.permission.BIND_JOB_SERVICE"
            android:exported="false" />
        <service
            android:name="androidx.work.impl.foreground.SystemForegroundService"
            android:foregroundServiceType="dataSync"
            tools:node="merge" />
        <!-- Servizio Plus per download HLS (aggiungere) -->
        <service
            android:name="com.nuvio.app.features.downloads.DownloadsForegroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />
    </application>
</manifest>
```

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsRepository.kt`

STATO 0.4.15: aggiunge reattachBackgroundDownload(downloadId), isSupportedDownloadUrl() blocca .m3u8.
STATO Plus: aggiunge HlsNeedsSelection result, startHlsDownload(), enqueueAutoStream(), buildHlsFileName(), isHlsUrl() check, isSupportedDownloadUrl() che restituisce true per .m3u8.

AZIONE MERGE:
1. Partire dalla versione Plus (NuvioMobile/composeApp/.../DownloadsRepository.kt) come base
   (contiene gia tutta la logica HLS Plus).
2. Aggiungere dopo i metodi Plus il metodo reattachBackgroundDownload di 0.4.15:
   ```kotlin
   fun reattachBackgroundDownload(downloadId: String) {
       // Riprende monitoraggio di un download schedulato da background (0.4.15)
       val item = _uiState.value.items.firstOrNull { it.id == downloadId } ?: return
       if (item.status != DownloadStatus.Downloading) return
       startDownloadItem(item)
   }
   ```
3. Verificare che isSupportedDownloadUrl() nella versione Plus NON blocchi .m3u8.
   Se la versione 0.4.15 lo blocca, ignorarla — la versione Plus e corretta.

FONTE CANONICA: `F:\GitHub\nuvio\NuvioMobile\composeApp\src\commonMain\kotlin\com\nuvio\app\features\downloads\DownloadsRepository.kt`

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsModels.kt`

STATO 0.4.15: DownloadItem base, DownloadEnqueueResult senza HlsNeedsSelection.
STATO Plus: DownloadItem esteso con campi HLS (isHls, hlsAudioUrl, hlsSubtitleUrl, hlsAudioUrls, hlsSubtitleUrls, hlsAudioLocalFileUri, hlsSubtitleLocalFileUri, hlsWarningMessage, isPlaceholder, phaseMessage, trackProgress), aggiunge HlsDownloadSelection, HlsStreamMetadata, TrackProgressState, DownloadEnqueueResult.HlsNeedsSelection.

AZIONE: Usare la versione Plus (NuvioMobile/composeApp/.../DownloadsModels.kt) direttamente.
E gia piu completa di quella 0.4.15.
Tutti i campi HLS hanno valori default per retrocompatibilita con item serializzati senza quei campi.

FONTE CANONICA: `F:\GitHub\nuvio\NuvioMobile\composeApp\src\commonMain\kotlin\com\nuvio\app\features\downloads\DownloadsModels.kt`

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.kt` (expect)

STATO 0.4.15: expect object con start(request, onProgress, onSuccess, onFailure, onPaused).
STATO Plus: stessa firma.
AZIONE: Usare la versione Plus. Nessun cambiamento necessario.

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/downloads/DownloadsScreen.kt`

STATO 0.4.15: aggiunge PlaybackAvailability check per il pulsante play.
STATO Plus: aggiunge sezioni track multipli, progress HLS per track, badge HLS, azioni extra.

AZIONE: Usare la versione Plus (NuvioMobile) come base. Verificare se 0.4.15 aggiunge
un check PlaybackAvailability.isAvailable(item) sul pulsante play — se si, aggiungere
anche nella versione Plus. NON rimuovere la logica Plus.

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/streams/StreamsScreen.kt`

STATO 0.4.15: aggiunge PlaybackAvailability (disable play when no source).
STATO Plus: aggiunge bottone download, menu selezione tracce HLS, integrazione AutoStreamDownloader.

AZIONE: Usare la versione Plus (NuvioMobile) come base. Aggiungere sopra il bottone play
il check PlaybackAvailability di 0.4.15:
```kotlin
// Prima del bottone play, aggiungere:
val isPlayable = PlaybackAvailability.isAvailable(stream)
// Usare isPlayable per abilitare/disabilitare il pulsante play
```

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerScreenRuntimeState.kt`

STATO 0.4.15: aggiunge nuovi campi state.
STATO Plus: aggiunge isDownloadable, downloadStatus nel runtime state.

AZIONE: Usare versione Plus. Verificare che i nuovi campi 0.4.15 non manchino.

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/features/player/PlayerScreenRuntimeUi.kt`

AZIONE: Usare versione Plus. Verificare che logica PlaybackAvailability 0.4.15 sia applicata.

#### FILE: `composeApp/build.gradle.kts`

AZIONE:
1. Partire dalla versione Plus (NuvioMobile/composeApp/build.gradle.kts).
2. Controllare se 0.4.15 ha aggiunto dipendenze nuove:
   - `androidx.work:work-runtime-ktx` (WorkManager per DownloadsTransferWorker)
   - Aggiornamenti versioni Compose/Kotlin/AndroidX
3. Aggiungere le dipendenze WorkManager se mancanti nella versione Plus.
4. Non rimuovere dipendenze Plus (mp4parser, okhttp, libs custom).

Comando verifica:
```powershell
# Clona temporaneo 0.4.15 per confronto
$tmp = "$env:TEMP\nuvio_0415_check_$(Get-Random)"
git clone --depth=1 --branch 0.4.15 https://github.com/NuvioMedia/NuvioMobile.git $tmp
# Confronta build.gradle.kts
Compare-Object (Get-Content "$tmp\composeApp\build.gradle.kts") (Get-Content "F:\GitHub\nuvio\NuvioMobile\composeApp\build.gradle.kts")
Remove-Item $tmp -Recurse -Force
```

#### FILE: `androidApp/build.gradle.kts`

AZIONE: Stessa logica di composeApp/build.gradle.kts.
Verificare aggiornamento versione app e aggiornare MARKETING_VERSION a 0.4.15.

#### FILE: `gradle/libs.versions.toml`

AZIONE: Partire dalla versione Plus. Aggiungere le entries 0.4.15 mancanti.
Non rimuovere entries Plus.

#### FILE: `composeApp/src/commonMain/composeResources/values/strings.xml`

STATO 0.4.15: aggiunge stringhe per russo, modifica alcune stringhe.
STATO Plus: aggiunge stringhe HLS download, selezione tracce, coda, prefetch.

AZIONE:
1. Partire dalla versione 0.4.15.
2. Aggiungere tutte le chiavi Plus mancanti (cercare key usate in
   DownloadsHlsSelectionSheet.kt, DownloadsScreen.kt, AutoStreamDownloader.kt,
   DownloadsForegroundService.kt, DownloadDeleteConfirmationDialog.kt).
3. Non rimuovere stringhe 0.4.15.

#### FILE: `composeApp/src/commonMain/composeResources/values-it/strings.xml`

AZIONE: Stessa logica di values/strings.xml.

#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/AppShellComponents.kt`
#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/MainAppContent.kt`
#### FILE: `composeApp/src/commonMain/kotlin/com/nuvio/app/MainTabsDestination.kt`

AZIONE: Usare la versione Plus come base. Verificare che le modifiche routing 0.4.15
(nuovo PlaybackAvailability, nuove destination) siano integrate.

---

## FASE 3 — Aggiornamento Script `update-patch-04.ps1`

Modificare `F:\GitHub\nuvio\scripts\update-patch-04.ps1`:

### Rimuovere da $files04 (lasciare intatti in 0.4.15):
```
"composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsPlatformDownloader.android.kt"
"composeApp/src/androidMain/kotlin/com/nuvio/app/features/downloads/DownloadsNotificationActionReceiver.kt"
```

### Svuotare completamente $files04Deleted:
```powershell
$files04Deleted = @()
```
I 5 file upstream 0.4.15 (AndroidDownloadScheduler, AndroidDownloadStore,
AndroidDownloadTransfer, DownloadsTransferJobService, DownloadsTransferWorker)
NON vengono piu eliminati dalla patch 04. Coesistono con il sistema HLS Plus.

### Cambiare $UpstreamBranch a tag 0.4.15:
Il pinning avviene gia tramite .last_built_upstream_sha. Assicurarsi che
.last_built_upstream_sha contenga: 83c409c401ad98b22eeb8a979859adddfa3eb8f4

---

## FASE 4 — Rigenera Patch 04

```powershell
cd F:\GitHub\nuvio
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-04.ps1
```

---

## FASE 5 — Aggiorna Versione e Rigenera Patch 07

Aggiornare `F:\GitHub\nuvio\NuvioMobile\iosApp\Configuration\Version.xcconfig`:
```
MARKETING_VERSION = 0.4.15.1
CURRENT_PROJECT_VERSION = <versionCode incrementale rispetto all ultimo build>
```

Poi:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-07.ps1
```

---

## FASE 6 — Test Applicabilita Patch

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-patch-apply.ps1
```

Tutte e 7 le patch devono applicarsi senza errori sul baseline 0.4.15.
Se una patch fallisce, analizzare il file in conflitto, risolverlo nella
working copy NuvioMobile/, rigenerare la patch corrispondente.

---

## FASE 7 — Build e Verifica

```powershell
cd F:\GitHub\nuvio\NuvioMobile
.\gradlew.bat :androidApp:assembleFullRelease
```

Verificare in `androidApp\build\outputs\apk\full\release\output-metadata.json`:
- applicationId = com.nuvio.app.plus
- versionName = 0.4.15.1
- Firma = keystore persistente SHA-256: BF:46:A0:35:B7:46:8E:77:E2:2D:2D:1F:CE:3A:C9:43:14:E9:EB:D1:AD:35:03:EB:75:C0:06:89:1C:54:46:B7

---

## FASE 8 — Rinomina APK e Release

```powershell
$ver = "0.4.15.1"
$base = "F:\GitHub\nuvio\NuvioMobile\androidApp\build\outputs\apk\full\release"
$dest = "F:\GitHub\nuvio\releases"
Copy-Item "$base\androidApp-full-universal-release.apk"   "$dest\nuvio_plus_${ver}_universal.apk"
Copy-Item "$base\androidApp-full-arm64-v8a-release.apk"  "$dest\nuvio_plus_${ver}_arm64-v8a.apk"
Copy-Item "$base\androidApp-full-armeabi-v7a-release.apk" "$dest\nuvio_plus_${ver}_armeabi-v7a.apk"
Copy-Item "$base\androidApp-full-x86_64-release.apk"     "$dest\nuvio_plus_${ver}_x86_64.apk"
Copy-Item "$base\androidApp-full-x86-release.apk"        "$dest\nuvio_plus_${ver}_x86.apk"
```

Aggiornare `F:\GitHub\nuvio\releases\release_notes.md` con sezione 0.4.15.1.

Commit e push:
```powershell
cd F:\GitHub\nuvio
git add patches/ scripts/ .last_built_upstream_sha releases/release_notes.md
git commit -m "feat(downloads): porting Plus su upstream 0.4.15 (v0.4.15.1)"
git push origin main
```

Release GitHub:
```powershell
gh release create 0.4.15.1 `
  releases\nuvio_plus_0.4.15.1_universal.apk `
  releases\nuvio_plus_0.4.15.1_arm64-v8a.apk `
  releases\nuvio_plus_0.4.15.1_armeabi-v7a.apk `
  releases\nuvio_plus_0.4.15.1_x86_64.apk `
  releases\nuvio_plus_0.4.15.1_x86.apk `
  --title "Nuvio Plus 0.4.15.1" `
  --notes-file releases\release_notes.md `
  --repo Lorenzo0010/nuvio-patch
```

---

## Architettura Download Risultante (post-porting)

```
DownloadsRepository (common)
    |
    +-- URL HTTP/HTTPS diretto (mp4, mkv, ecc.)
    |       +-- DownloadsPlatformDownloader.start() [UPSTREAM 0.4.15 intatto]
    |               +-- AndroidDownloadScheduler
    |                       +-- API 34+: DownloadsTransferJobService (JobScheduler)
    |                       +-- API <34: DownloadsTransferWorker (WorkManager)
    |
    +-- URL HLS (.m3u8) — [PLUS]
    |       +-- HlsDownloadEngine
    |               +-- Download parallelo segmenti HLS
    |               +-- Decrypt AES-128-CBC
    |               +-- DownloadsForegroundService per notifica + WakeLock
    |
    +-- URL Torrent/Magnet — [PLUS]
    |       +-- bloccato da isSupportedDownloadUrl() = false
    |           (da implementare se previsto nella futura roadmap)
    |
    +-- Auto-stream (prefetch) — [PLUS]
            +-- AutoStreamDownloader
```

NOTA: I download HTTP diretti usano il sistema 0.4.15 (robusto, con store persistente
su disco, retry automatici, User-Initiated Jobs su API 34+).
I download HLS usano ancora il sistema Plus con ForegroundService.
Entrambi convivono senza conflitti.

---

## Punti di Attenzione Critici

1. DownloadsForegroundService vs DownloadsTransferJobService: non si escludono.
   Il primo gestisce HLS (Plus), il secondo gestisce HTTP diretto (0.4.15).
   Entrambi devono essere nel AndroidManifest.xml.

2. DownloadsLiveStatusPlatform.android.kt: la versione 0.4.15 espone notifyTransfer(item)
   public e usa fileName nell Intent. Aggiungere removeNotification() Plus senza
   rimuovere le funzioni 0.4.15.

3. DownloadsRepository.kt: isSupportedDownloadUrl() in 0.4.15 blocca .m3u8.
   La versione Plus la sblocca come URL valido per HLS. Usare la versione Plus.

4. DownloadsModels.kt: i campi HLS hanno valori default per retrocompatibilita
   con item gia serializzati (download HTTP in corso non devono crashare).

5. Versione: la prima release su 0.4.15 sara 0.4.15.1.
   Aggiornare solo in iosApp/Configuration/Version.xcconfig via patch 07.

6. $files04Deleted DEVE essere un array vuoto. NON eliminare i file del nuovo
   sistema di scheduling 0.4.15 dalla patch.

---

## File di Riferimento

| File | Ruolo |
|------|-------|
| `F:\GitHub\nuvio\patches\04-plugin-hls-downloads.patch` | Patch attuale (0.4.14) da rimpiazzare |
| `F:\GitHub\nuvio\patches\07-stream-prefetch.patch` | Patch prefetch/versione da aggiornare |
| `F:\GitHub\nuvio\scripts\update-patch-04.ps1` | Script rigenerazione patch 04 — MODIFICARE |
| `F:\GitHub\nuvio\scripts\update-patch-07.ps1` | Script rigenerazione patch 07 |
| `F:\GitHub\nuvio\scripts\test-patch-apply.ps1` | Script test applicazione tutte le patch |
| `F:\GitHub\nuvio\NuvioMobile\` | Working copy Plus (0.4.14+patch) — FONTE CANONICA |
| `F:\GitHub\nuvio\.last_built_upstream_sha` | SHA upstream — aggiornare a 83c409c... |
| `F:\GitHub\nuvio\assets\keystore\nuvio-release.keystore` | Keystore firma — non toccare |
| `F:\GitHub\nuvio\releases\release_notes.md` | Note di rilascio — aggiornare con 0.4.15.1 |

---

## Checklist Finale

- [ ] Clone 0.4.15 in NuvioMobile/; .last_built_upstream_sha = 83c409c401ad98b22eeb8a979859adddfa3eb8f4
- [ ] Patch 01-03, 05-06 applicate senza errori su 0.4.15
- [ ] Assets binari copiati (extra_libs/, jniLibs/)
- [ ] DownloadsForegroundService.kt presente (Plus-only, non toccato da 0.4.15)
- [ ] DownloadsRepository.kt: reattachBackgroundDownload (0.4.15) + HLS Plus coesistono
- [ ] DownloadsModels.kt: campi HLS Plus + DownloadEnqueueResult.HlsNeedsSelection
- [ ] DownloadsLiveStatusPlatform.android.kt: removeNotification (Plus) + notifyTransfer public (0.4.15)
- [ ] AndroidManifest.xml composeApp/androidMain: permessi 0.4.15 + DownloadsForegroundService Plus
- [ ] DownloadsPlatformDownloader.android.kt: NON modificato, identico a 0.4.15
- [ ] DownloadsNotificationActionReceiver.kt: NON modificato, identico a 0.4.15
- [ ] $files04Deleted = @() (array vuoto nello script)
- [ ] strings.xml: stringhe 0.4.15 + stringhe HLS Plus senza duplicati
- [ ] build.gradle.kts: dipendenze 0.4.15 WorkManager + dipendenze Plus
- [ ] libs.versions.toml: versioni 0.4.15 + entries Plus
- [ ] Patch 04 rigenerata (non-zero bytes, nessun errore)
- [ ] Versione aggiornata a 0.4.15.1 in Version.xcconfig
- [ ] Patch 07 rigenerata
- [ ] test-patch-apply.ps1: tutte e 7 le patch OK su fresh clone 0.4.15
- [ ] Build assembleFullRelease OK
- [ ] APK firmati con keystore persistente (verificare SHA-256)
- [ ] APK rinominati in releases/ con nomenclatura pulita
- [ ] releases/release_notes.md aggiornata con sezione 0.4.15.1
- [ ] Commit + push su origin/main
- [ ] gh release create 0.4.15.1 con 5 APK + note
- [ ] gh release view 0.4.15.1 OK
