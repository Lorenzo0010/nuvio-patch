# 🚀 Nuvio Plus Mobile — Repository di Manutenzione Patch

Questo repository mantiene le **7 patch modulari Plus** per [Nuvio Mobile](https://github.com/NuvioMedia/NuvioMobile) (`branch: cmp-rewrite`), gli script di rigenerazione/test e le librerie binarie necessarie alla compilazione. I sorgenti completi **non sono tracciati qui**: vivono nella copia di lavoro locale `NuvioMobile/` (gitignored), su cui vengono applicate le patch e da cui vengono compilati gli APK.

> **Fa parte dell'ecosistema multipiattaforma [Nuvio Plus](https://github.com/Lorenzo0010/nuvio-patch)**, insieme al repository Desktop [`Lorenzo0010/nuvio-desktop-patch`](https://github.com/Lorenzo0010/nuvio-desktop-patch).

---

## ✨ Funzionalità Plus Incluse

Consulta [ENHANCEMENTS.md](ENHANCEMENTS.md) per la documentazione dettagliata di ogni funzionalità.

| Categoria | Funzionalità |
|---|---|
| 🆔 **Branding** | Package ID `com.nuvio.app.plus` — installabile in parallelo all'app ufficiale senza conflitti |
| 📺 **Live TV** | Canali M3U/M3U8, guida TV (EPG), preferiti, ricerca in tempo reale |
| 📥 **HLS Downloader** | Decrittazione AES-128, fMP4, remux MP4, selezione tracce audio/sub, coda FIFO con retry |
| ⚡ **Stream Prefetch** | Pre-risoluzione asincrona dei link stream con coda di auto-download |
| 🔌 **Plugin CloudStream 3** | Supporto plugin nativi `.cs3` (DEX) multi-architettura |
| 🎨 **UI/UX** | AMOLED puro, selettore colore HEX/HSV, icone app personalizzate, badge qualità stream |
| 🔄 **Updater** | Auto-aggiornamento reindirizzato su `Lorenzo0010/nuvio-patch` (GitHub Releases) |
| 🧩 **Widget Launcher** | Widget Android per il launcher |
| 🔗 **Integrazioni** | SIMKL (OAuth PKCE), MAL, AniList, OpenSubtitles, calendario uscite |
| 🔒 **Rete & Debug** | DNS over HTTPS, User-Agent override, In-App Log Viewer |

---

## 🗂️ Struttura del Repository

```text
F:\GitHub\nuvio\
├── patches/                          # Le 7 patch modulari Plus (applicate in ordine)
│   ├── 01-branding-and-config.patch  # AppId com.nuvio.app.plus, config Gradle
│   ├── 02-app-updater.patch          # Updater → Lorenzo0010/nuvio-patch
│   ├── 03-live-tv.patch              # Live TV, storage, parser M3U, navbar
│   ├── 04-plugin-hls-downloads.patch # Download HLS, plugin DEX, selezione tracce
│   ├── 05-bugfixes.patch             # Fix vari (valori versione storici, sovrascritti dalla 07)
│   ├── 06-launcher-widget.patch      # Widget launcher
│   └── 07-stream-prefetch.patch      # Prefetch stream, coda download, versione corrente
├── scripts/                          # Script PowerShell e Bash
│   ├── apply-patches.ps1 / .sh       # Applica le patch su un clone fresco
│   ├── apply-to-submodule.ps1        # Applica patch + copia asset in NuvioMobile/
│   ├── update-patch-04.ps1           # Rigenera patch 04 da NuvioMobile/
│   ├── update-patch-07.ps1           # Rigenera patch 07 da NuvioMobile/ (versione)
│   ├── generate-patch-06.ps1         # Rigenera patch 06 (widget)
│   ├── extract-patches.ps1 / .sh     # Estrazione generica patch da diff
│   └── test-patch-apply.ps1 / .sh    # Test applicabilità su upstream fresco
├── assets/
│   ├── extra_libs/                   # Librerie .aar copiate in composeApp/libs/
│   ├── jniLibs/                      # Librerie .so per ABI → composeApp/.../jniLibs/
│   └── keystore/
│       └── nuvio-release.keystore    # Keystore persistente di firma (SHA-256: BF:46:A0:...)
├── releases/
│   └── release_notes.md             # Note di rilascio (unico file tracciato in releases/)
├── NuvioMobile/                      # ⛔ GITIGNORED — copia di lavoro locale con patch applicate
├── dist/                             # ⛔ GITIGNORED — output storici legacy, non usare
├── AGENTS.md                         # Protocollo operativo per l'agente AI
├── ENHANCEMENTS.md                   # Documentazione completa delle funzionalità Plus
├── PATCHER_APP_FEASIBILITY.md        # Studio di fattibilità app Patcher on-device
├── .last_built_upstream_sha          # SHA upstream su cui è allineata NuvioMobile/
└── .gitignore
```

> **⚠️ Nessuna pipeline CI/CD**: build e pubblicazione avvengono **esclusivamente in locale** con Gradle + `gh`. Non esiste `.github/workflows/`.

---

## 🏷️ Versionamento

| Componente | Chi lo controlla | Esempio |
|---|---|---|
| `X.Y.Z` (es. `0.4.14`) | Upstream ufficiale — **non modificare mai** | Cambia solo con nuove release di `NuvioMedia/NuvioMobile` |
| `.W` (quarta parte) | Utente, incrementale | `0.4.14.24` → `0.4.14.25` |

- Nessun suffisso: ~~`-7950aba`~~, ~~`-alpha`~~. La versione è sempre e solo `X.Y.Z.W`.
- Tag GitHub: `0.4.14.24` (pulito, senza prefissi).
- APK: `nuvio_plus_0.4.14.24_universal.apk`, `nuvio_plus_0.4.14.24_arm64-v8a.apk`, ecc.
- La versione corrente è definita da `iosApp/Configuration/Version.xcconfig` nella patch **07**.

---

## 🛠️ Ciclo di Sviluppo

Le modifiche avvengono **nella copia di lavoro `NuvioMobile/`**, non nel repo root.

### 1. Modifica il codice
```
NuvioMobile/   ← qui si lavora (già allineata allo SHA in .last_built_upstream_sha con patch applicate)
```

### 2. Rigenera la patch interessata
```powershell
# Patch 04 — Download/HLS/Plugin
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-04.ps1

# Patch 07 — Prefetch/versione (la patch che conta per il numero di versione)
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-07.ps1

# Patch 06 — Widget launcher
powershell -ExecutionPolicy Bypass -File .\scripts\generate-patch-06.ps1
```

> Se aggiungi **nuovi file**, inseriscili nella lista `$filesNN` dello script corrispondente.

### 3. Testa l'applicabilità su upstream fresco
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-patch-apply.ps1
# oppure
bash ./scripts/test-patch-apply.sh
```

### 4. Riallinea NuvioMobile/ da zero (se necessario)
```powershell
# Clona upstream + applica tutte le patch + copia asset
powershell -ExecutionPolicy Bypass -File .\scripts\apply-to-submodule.ps1
```

---

## 🔨 Compilazione APK in Locale

Esegui la build **dentro `NuvioMobile/`** (o un clone temporaneo con patch applicate), mai nel repo root.

### Precondizioni
1. `local.properties` presente nella root di build (copialo da `NuvioMobile/local.properties`):
   ```properties
   sdk.dir=C:/Users/<utente>/AppData/Local/Android/Sdk
   NUVIO_RELEASE_STORE_FILE=<percorso-assoluto>/assets/keystore/nuvio-release.keystore
   NUVIO_RELEASE_STORE_PASSWORD=<password>
   NUVIO_RELEASE_KEY_ALIAS=<alias>
   NUVIO_RELEASE_KEY_PASSWORD=<password>
   ```
2. Asset copiati (`apply-to-submodule.ps1` lo fa automaticamente):
   - `assets/extra_libs/*` → `composeApp/libs/`
   - `assets/jniLibs/*` → `composeApp/src/androidMain/jniLibs/`

### Comando di build
```powershell
cd NuvioMobile
.\gradlew.bat :androidApp:assembleFullRelease
```

> ⚠️ Usa sempre `:androidApp:assembleFullRelease` (flavor `full` = `com.nuvio.app.plus`).
> ⚠️ Non usare `assembleRelease -Pnuvio.android.distribution=full` in PowerShell: la `-P...=...` viene alterata dalla shell.

### Output
APK grezzi in `androidApp\build\outputs\apk\full\release\`:
```
androidApp-full-universal-release.apk
androidApp-full-arm64-v8a-release.apk
androidApp-full-armeabi-v7a-release.apk
androidApp-full-x86_64-release.apk
androidApp-full-x86-release.apk
```

### Rinomina (obbligatoria)
```powershell
$v = "0.4.14.24"   # sostituisci con la versione corrente
$src = "androidApp\build\outputs\apk\full\release"
Copy-Item "$src\androidApp-full-universal-release.apk"    "releases\nuvio_plus_${v}_universal.apk"
Copy-Item "$src\androidApp-full-arm64-v8a-release.apk"    "releases\nuvio_plus_${v}_arm64-v8a.apk"
Copy-Item "$src\androidApp-full-armeabi-v7a-release.apk"  "releases\nuvio_plus_${v}_armeabi-v7a.apk"
Copy-Item "$src\androidApp-full-x86_64-release.apk"       "releases\nuvio_plus_${v}_x86_64.apk"
Copy-Item "$src\androidApp-full-x86-release.apk"          "releases\nuvio_plus_${v}_x86.apk"
```

---

## 🔄 Sincronizzazione Upstream

```powershell
# 1. Verifica SHA attuale upstream
git ls-remote https://github.com/NuvioMedia/NuvioMobile.git refs/heads/cmp-rewrite

# 2. Confronta con il contenuto di .last_built_upstream_sha
Get-Content .last_built_upstream_sha
```

Se gli SHA differiscono: clona upstream in una temporanea, applica le patch con `--3way`, risolvi i conflitti, rigenera le patch aggiornate e aggiorna `.last_built_upstream_sha` solo dopo build e test verificati.

---

## 🚀 Pubblicazione su GitHub

```powershell
# 1. Aggiorna releases/release_notes.md

# 2. Commit e push
git add patches/ scripts/ releases/release_notes.md .last_built_upstream_sha
git commit -m "feat: descrizione (v0.4.14.24)"
git push origin main

# 3. Crea la GitHub Release (esegui dalla root F:\GitHub\nuvio)
$v = "0.4.14.24"
gh release create $v `
  releases\nuvio_plus_${v}_universal.apk `
  releases\nuvio_plus_${v}_arm64-v8a.apk `
  releases\nuvio_plus_${v}_armeabi-v7a.apk `
  releases\nuvio_plus_${v}_x86_64.apk `
  releases\nuvio_plus_${v}_x86.apk `
  --title "Nuvio Plus $v" `
  --notes-file releases\release_notes.md `
  --repo Lorenzo0010/nuvio-patch

# 4. Verifica
gh release view $v --repo Lorenzo0010/nuvio-patch
```

---

## 📌 Checklist Rapida

- [ ] SHA upstream verificato (`git ls-remote`) e confrontato con `.last_built_upstream_sha`
- [ ] Modifiche sviluppate in `NuvioMobile/`; nuovi file aggiunti alla lista `$filesNN` dello script
- [ ] Patch rigenerate e testate con `test-patch-apply.ps1`
- [ ] Versione: `X.Y.Z` da upstream, `.W` incrementato; nessun suffisso/hash
- [ ] `local.properties` presente nella dir di build (mai committato); firma = keystore persistente
- [ ] Build con `.\gradlew.bat :androidApp:assembleFullRelease`; verificati `applicationId`/`versionName`/`versionCode`
- [ ] APK rinominati in `releases/`; `releases/release_notes.md` aggiornata
- [ ] Commit + push su `origin/main`
- [ ] Release creata con `gh release create` e verificata con `gh release view`
- [ ] Directory temporanee `$env:TEMP\nuvio_*` rimosse
