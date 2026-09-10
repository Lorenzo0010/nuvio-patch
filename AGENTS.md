# Manuale Operativo Nuvio Mobile (AGENTS.md)

Questo documento definisce il protocollo standard e obbligatorio che l'agente AI deve seguire per lavorare su questo repository: sviluppo feature, rigenerazione patch, compilazione locale degli APK e pubblicazione delle Release su GitHub.

---

## 🎯 Obiettivo del Flusso
Mantenere il fork e le patch personalizzate perfettamente allineate con l'upstream ufficiale (`https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`), isolando i conflitti, aggiornando le patch modulari in `patches/` e generando nuove Release firmate e funzionanti.

---

## ⚖️ Regola di Completezza Funzionale (Rielaborazione Patch)

1. **Risultato = 100% Upstream + Patch**: Il prodotto finale (le APK e la copia di lavoro `NuvioMobile/`) deve contenere **sempre il 100% delle funzioni dell'app originale upstream** e **in aggiunta** tutte le funzioni introdotte dalle patch Plus richieste dall'utente (Live TV, download HLS, cartella download personalizzata, updater, branding, ecc.). Nessuna funzione di base dell'app originale deve essere persa, oscurata, sostituita o degradata dalle patch.
2. **Funzioni presenti o aggiunte dall'Upstream con una nostra patch**: Se una funzione esiste già, oppure viene aggiunta successivamente nel repository upstream, e su quella stessa funzione noi avevamo realizzato una patch, il risultato deve essere:
   - **il 100% della funzionalità del repository originale** basata sul codice ufficiale più aggiornato (con relativi bugfix/ottimizzazioni upstream),
   - **più una rielaborazione delle nostre patch** per ottenere gli stessi risultati/comportamenti Plus richiesti dall'utente, senza sovrapposizioni né conflitti con il codice upstream.
3. **Obbligo di Rielaborazione delle Patch**: Quando l'upstream modifica o aggiunge codice riguardante una funzione toccata da una nostra patch, l'agente **non** deve semplicemente scartare il codice upstream né sovrascriverlo ciecamente: deve **rielaborare/reintegrare la patch** affinché:
   - le funzioni di base dell'app restino quelle originali/aggiornate upstream;
   - le funzioni Plus richieste continuino a essere presenti, visibili e funzionanti;
   - il risultato sia **funzionante al 100%** (compila, non regredisce e non perde alcuna feature).
4. **Visibilità per l'Utente Finale**: nell'app installata l'utente deve sempre vedere **le funzioni di base dell'app + quelle aggiunte dalle patch che ha richiesto** (`base + Plus`). Se un aggiornamento upstream rende una patch obsoleta o in conflitto, l'agente deve rielaborarla — riscrivendo se necessario parti della patch — per mantenere invariato quel comportamento completo, senza rimuovere o degradare nulla.

---

## 🔗 Repository Collegati (Ecosistema Nuvio Plus)
Questo repository (`Nuvio Mobile` / `nuvio-patch`) e il repository Desktop (`F:\GitHub\nuviodesktop`, `Nuvio Desktop` / `nuvio-desktop-patch`) sono **strettamente collegati** e formano l'ecosistema multipiattaforma **Nuvio Plus**:
- **Mobile / Android**: `F:\GitHub\nuvio` (Remote fork: `Lorenzo0010/nuvio-patch`, Upstream: `https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`)
- **Desktop**: `F:\GitHub\nuviodesktop` (Remote fork: `Lorenzo0010/nuvio-desktop-patch`, Upstream: `https://github.com/NuvioMedia/NuvioDesktop.git`, branch `Dev`)

### Principi di Condivisione e Allineamento:
1. **Feature Parity e Logica Condivisa**: Le feature Plus introdotte (es. Live TV con M3U parser/storage, download e gestione multitraccia HLS, patch ai plugin JS/bridges, prefetching dei link di streaming, configurazioni branding/aggiornamenti) seguono la stessa architettura logica. Quando si implementa, ottimizza o corregge una feature su un repository, verificare se la medesima logica o fix è applicabile o deve essere sincronizzata nell'altro.
2. **Architettura Compose Multiplatform**: Entrambe le codebase sono basate su Kotlin Multiplatform / Compose Multiplatform (`composeApp`), pertanto molti file di UI, viewmodel, modelli dati o utilità possono essere condivisi o adattati direttamente tra Mobile e Desktop.

---

## 🗂️ Anatomia del Repository (come è fatto e dove si agisce)

Questo NON è un fork con i sorgenti: è un **repository di manutenzione a patch**. I sorgenti completi vivono solo nella copia di lavoro locale.

| Percorso | Tracciato in git? | Ruolo |
|---|---|---|
| `patches/01-..-06-*.patch` | ✅ SÌ | Le 6 patch modulari Plus, applicate in ordine numerico sopra l'upstream |
| `scripts/*.ps1`, `scripts/*.sh` | ✅ SÌ | Rigenerazione, applicazione e test delle patch |
| `assets/extra_libs/` (`.aar`), `assets/jniLibs/` (`.so` per ABI) | ✅ SÌ | Librerie binarie copiate nel tree di build prima di compilare |
| `assets/keystore/nuvio-release.keystore` | ✅ SÌ (eccezione in `.gitignore`) | Keystore persistente di firma (SHA-256: `BF:46:A0:35:B7:46:8E:77:E2:2D:2D:1F:CE:3A:C9:43:14:E9:EB:D1:AD:35:03:EB:75:C0:06:89:1C:54:46:B7`). Non cambiare mai keystore tra le release |
| `releases/release_notes.md` | ✅ SÌ (solo questo file) | Note di rilascio pubblicate nella GitHub Release |
| `releases/*.apk` | ❌ NO (`*.apk` ignorato) | Copie locali degli APK rinominati, pronte per `gh release create` |
| `dist/` | ❌ NO | Output storici (nomi legacy con hash) — non usare per nuove release |
| `NuvioMobile/` | ❌ NO (gitignored) | **Copia di lavoro locale**: clone completo dell'upstream allo SHA di `.last_built_upstream_sha` con tutte le patch applicate come modifiche non committate + `local.properties` configurato. **È qui che si sviluppa e si compila** |
| `local.properties` (ovunque) | ❌ NO | Configurazione macchina-locale (SDK + firma). **Mai committare** |
| `.last_built_upstream_sha` | ✅ SÌ | SHA upstream su cui è allineata la copia di lavoro `NuvioMobile/` |
| `.github/workflows/` | ⚠️ ASSENTE | Non esiste pipeline CI in questo repo: **build e upload avvengono in locale** con Gradle + `gh` |

### Le 6 patch (ordine di applicazione obbligatorio)
1. `01-branding-and-config.patch` — Branding, appId `com.nuvio.app.plus`, config Gradle (versione pulita senza hash)
2. `02-app-updater.patch` — Updater reindirizzato su `Lorenzo0010/nuvio-patch`
3. `03-live-tv.patch` — Live TV, storage, parser M3U, tab navbar, pannello canali nel player, stringhe `live_tv_*`
4. `04-hls-downloads.patch` — Motore download HLS (segmenti paralleli, decrypt AES-128, remux MP4, tracce companion), sheet selezione tracce, hook long-press in `StreamsScreen` (torrent → motore originale, HLS → motore Plus), tab Download navbar, dipendenze Gradle (media3-muxer, documentfile)
5. `05-download-folder.patch` — Cartella di download personalizzata (repository, picker SAF, ingranaggio nella schermata Download, storage per-profile) + **versione corrente di `Version.xcconfig`**
6. `06-plugin-crypto.patch` — Compatibilità runtime plugin JS: `require('crypto'/'node:crypto')` (hash/HMAC/AES-CBC-ECB/PBKDF2/random su bridge nativi) + `Buffer`/`require('buffer')` minimi

### `local.properties` (mai committare)
Ogni directory di build (la copia `NuvioMobile/` o un clone temporaneo con patch applicate) deve contenere un `local.properties` con:
```properties
sdk.dir=C:/Users/<utente>/AppData/Local/Android/Sdk
NUVIO_RELEASE_STORE_FILE=<percorso-assoluto>/assets/keystore/nuvio-release.keystore
NUVIO_RELEASE_STORE_PASSWORD=<password>
NUVIO_RELEASE_KEY_ALIAS=<alias>
NUVIO_RELEASE_KEY_PASSWORD=<password>
```
- La copia canonica già configurata è `NuvioMobile/local.properties`: per build in cartelle temporanee, **copiarla** lì (non ricrearla a mano, non stamparne i segreti nei log/commit).
- Senza queste chiavi, `androidApp/build.gradle.kts` firma con la chiave di **debug** → APK **non pubblicabili**.

---

## 🏷️ Regola di Versionamento Obbligatoria
1. **Controllo delle Prime 3 Parti (`X.Y.Z`, es. `0.4.14`)**: Le prime tre parti della versione sono controllate **esclusivamente dal repository upstream ufficiale** (`https://github.com/NuvioMedia/NuvioMobile.git`). Non devono MAI essere modificate o avanzate arbitrariamente. Cambiano solo ed esclusivamente quando viene rilasciata una nuova versione ufficiale upstream (es. quando l'upstream rilascerà `0.4.15`).
2. **Controllo Utente della Quarta Parte (`.x`, es. `0.4.14.1`, `0.4.14.2`, ecc.)**: Tutte le modifiche, patch aggiuntive, nuove feature (Live TV, Download HLS, cartella download personalizzata, updater, branding, ecc.), bugfix o personalizzazioni sono gestite dall'utente incrementando **esclusivamente il quarto numero (`.x`)**:
   - Prima release fork: `0.4.14.1`
   - Seconda release fork: `0.4.14.2`
   - Terza release fork: `0.4.14.3`
   - Quarta release fork: `0.4.14.4`, ecc.
3. **Nessun Tag o Suffisso dopo il Numero di Versione**:
   - È **tassativamente vietato inserire tag, commit hash o suffissi dopo il numero di versione** (NON usare `-<short_sha>`, `-7950aba`, `-alpha`, ecc.). I suffissi `-<sha>` visibili su vecchi tag/APK in `dist/` sono legacy e non devono più essere prodotti.
   - La versione deve essere sempre e unicamente pulita: `<versione>` (es. `0.4.14.13`).
   - In `androidApp/build.gradle.kts` e `composeApp/build.gradle.kts`, `releaseAppVersionName` deve essere uguale a `baseAppVersionName` senza appendere `-$gitCommitHash`.
   - Il Tag della release su GitHub deve essere esattamente `<versione>` (es. `0.4.14.13`).
   - Gli APK pubblicati devono seguire la nomenclatura pulita senza hash: `nuvio_plus_<versione>_universal.apk`, `nuvio_plus_<versione>_<abi>.apk` (es. `nuvio_plus_0.4.14.13_universal.apk`, `nuvio_plus_0.4.14.13_arm64-v8a.apk`, ecc.).
4. **Firma APK Persistente**: Tutti gli APK devono essere firmati con il keystore persistente in `assets/keystore/nuvio-release.keystore` (impronta SHA-256: `BF:46:A0:35:B7:46:8E:77:E2:2D:2D:1F:CE:3A:C9:43:14:E9:EB:D1:AD:35:03:EB:75:C0:06:89:1C:54:46:B7`). Non cambiare mai keystore tra le release per evitare l'errore Android di firma non corrispondente.
5. **File Sorgente della Versione**: l'unica fonte è `iosApp/Configuration/Version.xcconfig` (`MARKETING_VERSION` = `<versione>`, `CURRENT_PROJECT_VERSION` = versionCode intero incrementale). Il valore **effettivo** è quello della patch 05 (l'ultima che tocca il file). Per un version bump: modifica il file nella copia `NuvioMobile/`, poi rigenera la patch 05 (vedi § Sviluppo).

---

## 🛠️ Ciclo di Sviluppo (come si agisce sul repo)

Le modifiche al codice **non** avvengono nel repo root (che non contiene sorgenti), ma nella copia di lavoro `NuvioMobile/`:

1. **Modifica** i file in `NuvioMobile/` (già allineata a `.last_built_upstream_sha` con tutte le patch applicate).
2. **Rigenera la patch** interessata (ogni script clona l'upstream fresco, applica le patch precedenti, sovrappone i file elencati copiati da `NuvioMobile/`, poi `git diff --binary`):
   - `powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-03.ps1` (Live TV + wiring shell/tab — lista file in `$files03`)
   - `powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-04.ps1` (motore HLS, hook stream, tab Download — lista file in `$files04`)
    - `powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-05.ps1` (cartella download, schermata Download, **versione** — lista file in `$files05`)
    - `powershell -ExecutionPolicy Bypass -File .\scripts\update-patch-06.ps1` (compatibilità `require('crypto')`/`Buffer` plugin JS — lista file in `$files06`)
   - Se aggiungi **nuovi file**, inseriscili nella lista `$filesNN` dello script corrispondente, altrimenti non finiranno nella patch.
3. **Testa** l'applicabilità di tutte le patch su upstream fresco:
   - PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\test-patch-apply.ps1`
   - Bash: `bash ./scripts/test-patch-apply.sh`
4. **Gestione conflitti** (se una patch fallisce): identifica il file dall'output git, analizza il nuovo codice upstream, reintegra manualmente le feature Plus preservando entrambi, rigenera la patch.
5. Per riallineare da zero la copia di lavoro: clone upstream + `.\scripts\apply-to-submodule.ps1` (applica le patch in `NuvioMobile/` e copia gli asset).

---

## 🔄 Sincronizzazione Upstream

1. Identifica l'ultimo commit di `upstream/cmp-rewrite`:
   ```powershell
   git ls-remote https://github.com/NuvioMedia/NuvioMobile.git refs/heads/cmp-rewrite
   ```
2. Confronta lo SHA con `.last_built_upstream_sha`. Se coincidono e non c'è richiesta di force-update, il repo è già aggiornato.
3. Altrimenti: clone pulito in temporanea (`$env:TEMP\nuvio_update_<timestamp>`), applica le patch in ordine con `git apply --3way`, risolvi i conflitti (§ Sviluppo punto 4), rigenera le patch, aggiorna `.last_built_upstream_sha` **solo dopo** build+test verificati.

---

## 🔨 Compilazione APK in Locale

Esegui la build **nella directory con le patch applicate** (`NuvioMobile/` oppure il clone temporaneo), mai nel repo root.

### Precondizioni (tutte obbligatorie)
1. `local.properties` presente nella root di build con `sdk.dir` + chiavi `NUVIO_RELEASE_*` (copialo da `NuvioMobile/local.properties` se la dir è fresca).
2. Asset copiati: `assets/extra_libs/*` → `composeApp/libs/`, `assets/jniLibs/*` → `composeApp/src/androidMain/jniLibs/` (gli script `apply-*.ps1` lo fanno da soli).
3. `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` già al valore target (via patch 05).

### Comando (PowerShell)
```powershell
cd <dir-di-build-con-patch>
.\gradlew.bat :androidApp:assembleFullRelease
```
- Usa il **task esplicito di flavor** `:androidApp:assembleFullRelease` (flavor `full` = package `com.nuvio.app.plus` installabile side-by-side). Il task abilita automaticamente gli ABI split.
- ⚠️ Non usare la forma aggregata `assembleRelease -Pnuvio.android.distribution=full` in PowerShell: l'argomento `-P...=...` viene alterato dalla shell (osservato: `Task '.android.distribution=full' not found`).

### Output e firma
- APK grezzi in `androidApp\build\outputs\apk\full\release\`:
  `androidApp-full-universal-release.apk`, `androidApp-full-arm64-v8a-release.apk`, `androidApp-full-armeabi-v7a-release.apk`, `androidApp-full-x86_64-release.apk`, `androidApp-full-x86-release.apk`
- Verifica firma e versione prima di pubblicare (es. `output-metadata.json`: `applicationId=com.nuvio.app.plus`, `versionName=<versione>`, `versionCode=<CURRENT_PROJECT_VERSION>`).
- Se la firma è di debug (manca `local.properties`), **fermati**: rigenera la config e ricompila.

### Rinomina (obbligatoria, nomi puliti)
```powershell
Copy-Item androidApp\build\outputs\apk\full\release\androidApp-full-universal-release.apk releases\nuvio_plus_<versione>_universal.apk
Copy-Item androidApp\build\outputs\apk\full\release\androidApp-full-arm64-v8a-release.apk  releases\nuvio_plus_<versione>_arm64-v8a.apk
Copy-Item androidApp\build\outputs\apk\full\release\androidApp-full-armeabi-v7a-release.apk releases\nuvio_plus_<versione>_armeabi-v7a.apk
Copy-Item androidApp\build\outputs\apk\full\release\androidApp-full-x86_64-release.apk     releases\nuvio_plus_<versione>_x86_64.apk
Copy-Item androidApp\build\outputs\apk\full\release\androidApp-full-x86-release.apk        releases\nuvio_plus_<versione>_x86.apk
```

---

## 🚀 Pubblicazione su GitHub (commit, push, release)

1. **Aggiorna** `releases/release_notes.md` con la sezione `## Novità in Nuvio Plus Mobile <versione>` (è l'unico file tracciato sotto `releases/`, gli APK restano locali/ignorati fino all'upload).
2. **Commit e push** su `origin/main` (solo file tracciati: patch rigenerate, script, `releases/release_notes.md`, `.last_built_upstream_sha` se in sync, docs). Convenzioni osservate:
   - `feat(downloads): <descrizione> (v<versione>)`
   - `fix(<area>): <descrizione> (v<versione>)`
   - `chore: aggiorna patch 05 ... v<versione>`
   - `docs: aggiorna note di rilascio per v<versione>`
3. **Crea la GitHub Release** sul repository fork `Lorenzo0010/nuvio-patch` (tag = versione pulita, creato dal comando se assente). Esegui il comando **nella root `F:\GitHub\nuvio`** (il cui `origin` è il fork) oppure aggiungi `--repo Lorenzo0010/nuvio-patch`:
   ```powershell
   gh release create <versione> releases\nuvio_plus_<versione>_universal.apk releases\nuvio_plus_<versione>_arm64-v8a.apk releases\nuvio_plus_<versione>_armeabi-v7a.apk releases\nuvio_plus_<versione>_x86_64.apk releases\nuvio_plus_<versione>_x86.apk --title "Nuvio Plus <versione>" --notes-file releases\release_notes.md --repo Lorenzo0010/nuvio-patch
   ```
4. **Verifica** con `gh release view <versione>`: 5 asset con nomi puliti, tag = `<versione>`, note pubblicate.
5. **Pulizia**: rimuovi le directory temporanee `$env:TEMP\nuvio_*` (gli script di test/generazione già lo fanno; per build manuali fallo a mano).

---

## 📌 Checklist Rapida per l'Agente
- [ ] Verificato ultimo commit upstream via `git ls-remote` e confrontato con `.last_built_upstream_sha`
- [ ] Sviluppato in `NuvioMobile/`; nuovi file aggiunti alla lista `$filesNN` dello script di rigenerazione
- [ ] Patch rigenerate (`update-patch-03/04/05/06.ps1`) e testate (`test-patch-apply.ps1`)
- [ ] Regola di versionamento rispettata: `X.Y.Z` da upstream, `.W` dall'utente; versione effettiva via patch 05
- [ ] Completezza funzionale: risultato = 100% upstream + patch rielaborate; funzioni base e Plus richieste tutte presenti, visibili e funzionanti (`base + Plus`)
- [ ] Nessun suffisso/hash in versione, tag (`<versione>`) e nomi APK (`nuvio_plus_<versione>_<abi>.apk`)
- [ ] `local.properties` presente nella dir di build (mai committato); firma = keystore persistente
- [ ] Build con `.\gradlew.bat :androidApp:assembleFullRelease`; verificati `applicationId`/`versionName`/`versionCode`
- [ ] APK rinominati in `releases/`; `releases/release_notes.md` aggiornata
- [ ] Commit + push su `origin/main` con messaggi convenzionali
- [ ] Release creata con `gh release create <versione>` e verificata con `gh release view <versione>`
- [ ] Directory temporanee `$env:TEMP\nuvio_*` rimosse
