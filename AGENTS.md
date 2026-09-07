# Protocollo di Aggiornamento Nuvio Mobile (AGENTS.md)

Questo documento definisce il protocollo standard e obbligatorio che l'agente AI (Antigravity) deve seguire ogni volta che l'utente richiede di **"aggiornare la versione di Nuvio"** o di verificare/applicare le patch all'ultima versione upstream di Nuvio.

---

## 🎯 Obiettivo del Flusso
Mantenere il fork e le patch personalizzate perfettamente allineate con l'upstream ufficiale (`https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`), isolando i conflitti, aggiornando le patch modulari in `patches/` e generando una nuova Release firmata e funzionante.

---

## 🔗 Repository Collegati (Ecosistema Nuvio Plus)
Questo repository (`Nuvio Mobile` / `nuvio-patch`) e il repository Desktop (`F:\GitHub\nuviodesktop`, `Nuvio Desktop` / `nuvio-desktop-patch`) sono **strettamente collegati** e formano l'ecosistema multipiattaforma **Nuvio Plus**:
- **Mobile / Android**: `F:\GitHub\nuvio` (Remote fork: `Lorenzo0010/nuvio-patch`, Upstream: `https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`)
- **Desktop**: `F:\GitHub\nuviodesktop` (Remote fork: `Lorenzo0010/nuvio-desktop-patch`, Upstream: `https://github.com/NuvioMedia/NuvioDesktop.git`, branch `Dev`)

### Principi di Condivisione e Allineamento:
1. **Feature Parity e Logica Condivisa**: Le feature Plus introdotte (es. Live TV con M3U parser/storage, download e gestione multitraccia HLS, patch ai plugin JS/bridges, prefetching dei link di streaming, configurazioni branding/aggiornamenti) seguono la stessa architettura logica. Quando si implementa, ottimizza o corregge una feature su un repository, verificare se la medesima logica o fix è applicabile o deve essere sincronizzata nell'altro.
2. **Architettura Compose Multiplatform**: Entrambe le codebase sono basate su Kotlin Multiplatform / Compose Multiplatform (`composeApp`), pertanto molti file di UI, viewmodel, modelli dati o utilità possono essere condivisi o adattati direttamente tra Mobile e Desktop.

---

## 🏷️ Regola di Versionamento Obbligatoria
1. **Controllo delle Prime 3 Parti (`X.Y.Z`, es. `0.4.14`)**: Le prime tre parti della versione sono controllate **esclusivamente dal repository upstream ufficiale** (`https://github.com/NuvioMedia/NuvioMobile.git`). Non devono MAI essere modificate o avanzate arbitrariamente. Cambiano solo ed esclusivamente quando viene rilasciata una nuova versione ufficiale upstream (es. quando l'upstream rilascerà `0.4.15`).
2. **Controllo Utente della Quarta Parte (`.x`, es. `0.4.14.1`, `0.4.14.2`, ecc.)**: Tutte le modifiche, patch aggiuntive, nuove feature (Live TV, Download HLS, Launcher Widget, Patches Plus, Stream prefetch, ecc.), bugfix o personalizzazioni sono gestite dall'utente incrementando **esclusivamente il quarto numero (`.x`)**:
   - Prima release fork: `0.4.14.1`
   - Seconda release fork: `0.4.14.2`
   - Terza release fork: `0.4.14.3`
   - Quarta release fork: `0.4.14.4`, ecc.
3. **Nessun Tag o Suffisso dopo il Numero di Versione**:
   - È **tassativamente vietato inserire tag, commit hash o suffissi dopo il numero di versione** (NON usare `-<short_sha>`, `-7950aba`, `-alpha`, ecc.).
   - La versione deve essere sempre e unicamente pulita: `<versione>` (es. `0.4.14.4`).
   - In `androidApp/build.gradle.kts` e `composeApp/build.gradle.kts`, `releaseAppVersionName` deve essere uguale a `baseAppVersionName` senza appendere `-$gitCommitHash`.
   - Il Tag della release su GitHub deve essere esattamente `<versione>` (es. `0.4.14.4`).
   - Gli APK prodotti devono seguire la nomenclatura pulita senza hash: `nuvio_plus_<versione>_universal.apk`, `nuvio_plus_<versione>_<abi>.apk` (es. `nuvio_plus_0.4.14.4_universal.apk`, `nuvio_plus_0.4.14.4_arm64-v8a.apk`, ecc.).
4. **Firma APK Persistente**: Tutti gli APK devono essere firmati con il keystore persistente in `assets/keystore/nuvio-release.keystore` (impronta SHA-256: `BF:46:A0:35:B7:46:8E:77:E2:2D:2D:1F:CE:3A:C9:43:14:E9:EB:D1:AD:35:03:EB:75:C0:06:89:1C:54:46:B7`). Non cambiare mai keystore tra le release per evitare l'errore Android di firma non corrispondente.

---

## 📋 Fasi Operative per l'Agente

### Fase 1: Verifica dello Stato Upstream
1. Identifica l'ultimo commit di `upstream/cmp-rewrite` interrogando il remote:
   ```bash
   git ls-remote https://github.com/NuvioMedia/NuvioMobile.git refs/heads/cmp-rewrite
   ```
2. Confronta lo SHA ottenuto con quello salvato in `.last_built_upstream_sha`.
3. Se gli SHA coincidono e l'utente non richiede un force-update, informa l'utente che il repository è già all'ultima versione disponibile. Altrimenti procedi alla Fase 2.

---

### Fase 2: Clone Pulito in Cartella Temporanea
1. Clona l'upstream ufficiale in una directory temporanea (es. `$env:TEMP\nuvio_update_<timestamp>` o `nuvio_workspace`):
   ```bash
   git clone --branch cmp-rewrite https://github.com/NuvioMedia/NuvioMobile.git <tempDir>
   ```
2. Verifica l'integrità dei sorgenti clonati.

---

### Fase 3: Applicazione Sequenziale delle Patch Modulari
Le patch si trovano nella cartella `patches/` e vanno applicate rigorosamente in ordine numerico:
1. `patches/01-branding-and-config.patch` (Branding, appId, config Gradle)
2. `patches/02-app-updater.patch` (Reindirizzamento updater su `Lorenzo0010/nuvio-patch`)
3. `patches/03-live-tv.patch` (Funzionalità Live TV, storage, parser M3U, navbar)
4. `patches/04-plugin-hls-downloads.patch` (Sheet di selezione qualità video, traccia audio e sottotitoli per download stream HLS e plugin)
5. `patches/05-bugfixes.patch` (Fix vari, animazioni, testi e ottimizzazioni)

Per ciascuna patch:
```bash
git apply --3way <path-to-patch>
```

#### ⚠️ Gestione dei Conflitti (Risoluzione Manuale Intelligente):
Se una patch fallisce (ad esempio `03-live-tv.patch` a causa di modifiche alla navbar in `AppShellComponents.kt` o in `strings.xml`):
1. **Identifica il file in conflitto** leggendo l'output del comando git.
2. **Analizza il nuovo codice upstream** nel file target.
3. **Applica manualmente le modifiche/integrazioni Plus** preservando sia le nuove modifiche ufficiali dell'upstream, sia tutte le funzionalità Plus (es. tab Live TV, gestione icone, ecc.).
4. **Rigenera la patch aggiornata** sovrascrivendo il file corrispondente in `patches/`.

---

### Fase 4: Verifica e Copia Asset
1. Verifica che se presenti librerie in `assets/extra_libs` vengano copiate in `composeApp/libs`.
2. Verifica che se presenti librerie native in `assets/jniLibs` vengano copiate in `composeApp/src/androidMain/jniLibs`.
3. Esegui lo script di test:
   - PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\test-patch-apply.ps1`
   - Bash: `bash ./scripts/test-patch-apply.sh`

---

### Fase 5: Compilazione Locale, Commit e Pubblicazione
1. **Compilazione Locale**: Al termine di qualsiasi modifica o aggiornamento (quando esplicitamente richiesto o approvato dall'utente), compila l'APK in locale (ad es. eseguendo `./gradlew assembleRelease -Pnuvio.android.distribution=full` nella directory con le patch applicate). Assicurati di usare il keystore persistente `assets/keystore/nuvio-release.keystore`.
2. **Rinomina APK**: Rinomina gli APK generati utilizzando il formato pulito senza tag o commit hash: `nuvio_plus_<versione>_<arch>.apk` (es. `nuvio_plus_0.4.14.4_universal.apk`, `nuvio_plus_0.4.14.4_arm64-v8a.apk`, ecc.).
3. **Commit e Push**: Aggiorna `.last_built_upstream_sha` (se in fase di sync upstream), ed esegui il commit e il push di tutte le modifiche (patch aggiornate, script, documentazione, ecc.) sul repository remoto.
4. **Pubblicazione Release (Caricamento Locale)**: Quando si crea una nuova release su GitHub:
   - `gh release create <versione> <percorso_apk_locale> --title "Nuvio Plus <versione>" --notes "Note di rilascio"`
   - Il tag coincide esattamente con la versione pulita `<versione>` (es. `0.4.14.4`), senza tag o hash suffissi.
   - Specifica i file APK generati (universale e per architettura ABI).

---

## 📌 Checklist Rapida per l'Agente
- [ ] Verificato ultimo commit upstream via `git ls-remote`
- [ ] Applicata la regola di versionamento: le prime 3 parti (`0.4.14`) rispecchiano upstream, la quarta parte (`0.4.14.x`) è gestita dall'utente
- [ ] Verificato che nessun tag/hash suffisso sia presente nella versione o nel release tag (formato pulito `<versione>`, es. `0.4.14.4`)
- [ ] Testata l'applicazione di tutte le patch `patches/01-*` .. `07-*`
- [ ] Conflitti risolti preservando il codice upstream e le feature Plus
- [ ] Patch aggiornate e salvate in `patches/`
- [ ] Aggiornato `.last_built_upstream_sha` (se sync upstream)
- [ ] Compilato l'APK in locale firmato con keystore persistente `assets/keystore/nuvio-release.keystore` (quando richiesto)
- [ ] Ridenominati gli APK secondo lo standard pulito `nuvio_plus_<versione>_<arch>.apk`
- [ ] Effettuato il commit e push su GitHub
- [ ] Creata la GitHub Release con `gh release create <versione>` (quando richiesto) e notificato all'utente
