# ðŸš€ Nuvio Plus Mobile â€” Repository di Manutenzione Patch

Questo repository mantiene le **5 patch modulari Plus** per [Nuvio Mobile](https://github.com/NuvioMedia/NuvioMobile) (`branch: cmp-rewrite`), gli script di rigenerazione/test e le librerie binarie necessarie alla compilazione. I sorgenti completi **non sono tracciati qui**: vivono nella copia di lavoro locale `NuvioMobile/` (gitignored), su cui vengono applicate le patch e da cui vengono compilati gli APK.

> **Fa parte dell'ecosistema multipiattaforma [Nuvio Plus](https://github.com/Lorenzo0010/nuvio-patch)**, insieme al repository Desktop [`Lorenzo0010/nuvio-desktop-patch`](https://github.com/Lorenzo0010/nuvio-desktop-patch).

---

## âœ¨ FunzionalitÃ  Plus Incluse

Consulta [ENHANCEMENTS.md](ENHANCEMENTS.md) per la documentazione dettagliata di ogni funzionalitÃ .

| Categoria | FunzionalitÃ  |
|---|---|
| **Branding** | Package ID `com.nuvio.app.plus` - installabile in parallelo all'app ufficiale senza conflitti |
| **Live TV** | Canali M3U/M3U8, preferiti, ricerca, pannello canali nel player |
| **HLS Downloader** | Long-press sullo stream: torrent -> motore originale, HLS -> motore Plus (AES-128, remux MP4, tracce audio/sub) |
| **Cartella download** | Posizione personalizzata per tutti i download (ingranaggio nella schermata Download) |
| **Updater** | Auto-aggiornamento reindirizzato su `Lorenzo0010/nuvio-patch` (GitHub Releases) |

---

## ðŸ—‚ï¸ Struttura del Repository

```text
F:\GitHub\nuvio\
â”œâ”€â”€ patches/                          # Le 5 patch modulari Plus (applicate in ordine)
â”‚   â”œâ”€â”€ 01-branding-and-config.patch  # AppId com.nuvio.app.plus, config Gradle
â”‚   â”œâ”€â”€ 02-app-updater.patch          # Updater â†’ Lorenzo0010/nuvio-patch
â”‚   â”œâ”€â”€ 03-live-tv.patch              # Live TV, storage, parser M3U, tab navbar, pannello player
â”‚   â”œâ”€â”€ 04-hls-downloads.patch        # Motore HLS, sheet tracce, hook long-press, tab Download
â”‚   â””â”€â”€ 05-download-folder.patch      # Cartella download personalizzata + versione corrente
â”œâ”€â”€ scripts/                          # Script PowerShell e Bash
â”‚   â”œâ”€â”€ apply-patches.ps1 / .sh       # Applica le patch su un clone fresco
â”‚   â”œâ”€â”€ apply-to-submodule.ps1        # Applica patch + copia asset in NuvioMobile/
â”‚   â”œâ”€â”€ update-patch-03.ps1           # Rigenera patch 03 da NuvioMobile/
â”‚   â”œâ”€â”€ update-patch-04.ps1           # Rigenera patch 04 da NuvioMobile/
â”‚   â”œâ”€â”€ update-patch-05.ps1           # Rigenera patch 05 da NuvioMobile/ (versione)
â”‚   â”œâ”€â”€ extract-patches.ps1 / .sh     # Estrazione generica patch da diff
â”‚   â””â”€â”€ test-patch-apply.ps1 / .sh    # Test applicabilitÃ  su upstream fresco
â”œâ”€â”€ assets/
â”‚   â”œâ”€â”€ extra_libs/                   # Librerie .aar copiate in composeApp/libs/
â”‚   â”œâ”€â”€ jniLibs/                      # Librerie .so per ABI â†’ composeApp/.../jniLibs/
â”‚   â””â”€â”€ keystore/
â”‚       â””â”€â”€ nuvio-release.keystore    # Keystore persistente di firma (SHA-256: BF:46:A0:...)
â”œâ”€â”€ releases/
â”‚   â””â”€â”€ release_notes.md             # Note di rilascio (unico file tracciato in releases/)
â”œâ”€â”€ NuvioMobile/                      # â›” GITIGNORED â€” copia di lavoro locale con patch applicate
â”œâ”€â”€ dist/                             # â›” GITIGNORED â€” output storici legacy, non usare
â”œâ”€â”€ AGENTS.md                         # Protocollo operativo per l'agente AI
â”œâ”€â”€ ENHANCEMENTS.md                   # Documentazione completa delle funzionalitÃ  Plus
â”œâ”€â”€ PATCHER_APP_FEASIBILITY.md        # Studio di fattibilitÃ  app Patcher on-device
â”œâ”€â”€ .last_built_upstream_sha          # SHA upstream su cui Ã¨ allineata NuvioMobile/
â””â”€â”€ .gitignore
```

> **âš ï¸ Nessuna pipeline CI/CD**: build e pubblicazione avvengono **esclusivamente in locale** con Gradle + `gh`. Non esiste `.github/workflows/`.

---

## ðŸ·ï¸ Versionamento

| Componente | Chi lo controlla | Esempio |
|---|---|---|
| `X.Y.Z` (es. `0.4.14`) | Upstream ufficiale â€” **non modificare mai** | Cambia solo con nuove release di `NuvioMedia/NuvioMobile` |
| `.W` (quarta parte) | Utente, incrementale | `0.4.14.24` â†’ `0.4.14.25` |

- Nessun suffisso: ~~`-7950aba`~~, ~~`-alpha`~~. La versione Ã¨ sempre e solo `X.Y.Z.W`.
- Tag GitHub: `0.4.14.24` (pulito, senza prefissi).
- APK: `nuvio_plus_0.4.14.24_universal.apk`, `nuvio_plus_0.4.14.24_arm64-v8a.apk`, ecc.
- La versione corrente Ã¨ definita da `iosApp/Configuration/Version.xcconfig` nella patch **05**.

---

## ðŸ› ï¸ Ciclo di Sviluppo

Le modifiche avvengono **nella copia di lavoro `NuvioMobile/`**, non nel repo root.

### 1. Modifica il codice
```
NuvioMobile/   â† qui si lavora (giÃ  allineata allo SHA in .last_built_upstream_sha con patch applicate)
```

### 2. Rigenera la patch interessata
```powershell
# Patch 03 — Live TV
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-03.ps1

# Patch 04 — Download HLS
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-04.ps1

# Patch 05 — Cartella download + versione (la patch che conta per il numero di versione)
powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-05.ps1
```

> Se aggiungi **nuovi file**, inseriscili nella lista `$filesNN` dello script corrispondente.

### 3. Testa l'applicabilitÃ  su upstream fresco
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

## ðŸ”¨ Compilazione APK in Locale

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
   - `assets/extra_libs/*` â†’ `composeApp/libs/`
   - `assets/jniLibs/*` â†’ `composeApp/src/androidMain/jniLibs/`

### Comando di build
```powershell
cd NuvioMobile
.\gradlew.bat :androidApp:assembleFullRelease
```

> âš ï¸ Usa sempre `:androidApp:assembleFullRelease` (flavor `full` = `com.nuvio.app.plus`).
> âš ï¸ Non usare `assembleRelease -Pnuvio.android.distribution=full` in PowerShell: la `-P...=...` viene alterata dalla shell.

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

## ðŸ”„ Sincronizzazione Upstream

```powershell
# 1. Verifica SHA attuale upstream
git ls-remote https://github.com/NuvioMedia/NuvioMobile.git refs/heads/cmp-rewrite

# 2. Confronta con il contenuto di .last_built_upstream_sha
Get-Content .last_built_upstream_sha
```

Se gli SHA differiscono: clona upstream in una temporanea, applica le patch con `--3way`, risolvi i conflitti, rigenera le patch aggiornate e aggiorna `.last_built_upstream_sha` solo dopo build e test verificati.

---

## ðŸš€ Pubblicazione su GitHub

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

## ðŸ“Œ Checklist Rapida

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
