# Protocollo di Aggiornamento Nuvio Mobile (AGENTS.md)

Questo documento definisce il protocollo standard e obbligatorio che l'agente AI (Antigravity) deve seguire ogni volta che l'utente richiede di **"aggiornare la versione di Nuvio"** o di verificare/applicare le patch all'ultima versione upstream di Nuvio.

---

## 🎯 Obiettivo del Flusso
Mantenere il fork e le patch personalizzate perfettamente allineate con l'upstream ufficiale (`https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`), isolando i conflitti, aggiornando le patch modulari in `patches/` e generando una nuova Release firmata e funzionante.

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

# Protocollo di Aggiornamento Nuvio Mobile (AGENTS.md)

Questo documento definisce il protocollo standard e obbligatorio che l'agente AI (Antigravity) deve seguire ogni volta che l'utente richiede di **"aggiornare la versione di Nuvio"** o di verificare/applicare le patch all'ultima versione upstream di Nuvio.

---

## 🎯 Obiettivo del Flusso
Mantenere il fork e le patch personalizzate perfettamente allineate con l'upstream ufficiale (`https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`), isolando i conflitti, aggiornando le patch modulari in `patches/` e generando una nuova Release firmata e funzionante.

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
1. **Compilazione Locale**: Al termine di qualsiasi modifica o aggiornamento, compila l'APK in locale (ad es. eseguendo `./gradlew assembleRelease -Pnuvio.android.distribution=full` nella directory con le patch applicate).
2. **Rinomina APK**: Rinomina l'APK appena generato utilizzando il formato `nuvio_plus_<numeroversionedibase>_<tagunivoco>.apk` (es. `nuvio_plus_0.4.13_312d499.apk`).
3. **Commit e Push**: Aggiorna `.last_built_upstream_sha` (se in fase di sync upstream), ed esegui il commit e il push di tutte le modifiche (patch aggiornate, script, ecc.) sul repository remoto.
4. **Pubblicazione Release (Caricamento Locale)**: Poiché il workflow di GitHub Actions non è affidabile, crea direttamente una nuova Release su GitHub.
   - Utilizza la GitHub CLI (`gh`) in locale lanciando il seguente comando nel terminale dell'utente:
     `gh release create <tag> <percorso_apk_locale> --title "Nuvio Plus <versione>" --notes "Note di rilascio"`
   - Assicurati di specificare il percorso assoluto o corretto al file APK generato.
   - In caso di errori `gh non riconosciuto`, chiedi all'utente di fornire l'eseguibile corretto o di aprire una nuova shell.

---

## 📌 Checklist Rapida per l'Agente
- [ ] Verificato ultimo commit upstream via `git ls-remote`
- [ ] Testata l'applicazione di tutte le patch `patches/01-*`, `patches/02-*`, `patches/03-*`
- [ ] Conflitti risolti preservando il codice upstream e le feature Plus
- [ ] Patch aggiornate e salvate in `patches/`
- [ ] Aggiornato `.last_built_upstream_sha`
- [ ] Compilato l'APK in locale e rinominato secondo lo standard `nuvio_plus_<versione>_<tag>.apk`
- [ ] Effettuato il commit e push su GitHub
- [ ] Creata manualmente la GitHub Release con l'APK generato tramite `gh release create` e notificato all'utente
