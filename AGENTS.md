# Protocollo di Aggiornamento Nuvio Mobile (AGENTS.md)

Questo documento definisce il protocollo standard e obbligatorio che l'agente AI (Antigravity) deve seguire ogni volta che l'utente richiede di **"aggiornare la versione di Nuvio"** o di verificare/applicare le patch all'ultima versione upstream di Nuvio.

---

## 🎯 Obiettivo del Flusso
Mantenere il fork e le patch personalizzate perfettamente allineate con l'upstream ufficiale (`https://github.com/NuvioMedia/NuvioMobile.git`, branch `cmp-rewrite`), isolando i conflitti, aggiornando le patch modulari in `patches/` e generando una nuova Release firmata e funzionante.

---

## 🏷️ Regola di Versionamento Obbligatoria
1. **Versione Base Upstream (`0.4.13`)**: La versione base (es. `0.4.13`) deve rispecchiare esclusivamente la versione dell'app originale upstream rilasciata ufficialmente. **NON deve mai essere incrementata a versioni successive (es. non passare a `0.4.14` o `0.4.14.x`) a meno che non ci sia una nuova release ufficiale upstream o che l'utente non lo richieda esplicitamente.** Anche se il branch upstream git contiene commit intermedi o bump interni di versione, la base di Nuvio Plus deve rimanere ancorata a `0.4.13`.
2. **Incremento Patch Utente (`0.4.13.x`)**: Tutte le modifiche, nuove funzionalità (come il Launcher Widget), bugfix o personalizzazioni richieste dall'utente devono essere rilasciate incrementando **esclusivamente il quarto numero (`.x`)**:
   - Prima modifica: `0.4.13.1`
   - Seconda modifica: `0.4.13.2`
   - Terza modifica: `0.4.13.3` (es. Launcher Widget)
   - Quarta modifica: `0.4.13.4`, ecc.
   Non modificare o avanzare mai i primi tre numeri per modifiche dell'utente.
3. **Aggiornamento in-app e Tag Release**: L'incremento `0.4.13.x` va impostato in `iosApp/Configuration/Version.xcconfig` e utilizzato nel tag di release (formato: `<versione>-<short_sha>`, es. `0.4.13.3-7950aba`). Questo consente all'updater in-app di rilevare e proporre sempre l'aggiornamento senza blocchi.
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
1. **Compilazione Locale**: Al termine di qualsiasi modifica o aggiornamento, compila l'APK in locale (ad es. eseguendo `./gradlew assembleRelease -Pnuvio.android.distribution=full` nella directory con le patch applicate). Assicurati di usare il keystore persistente `assets/keystore/nuvio-release.keystore`.
2. **Rinomina APK**: Rinomina l'APK appena generato utilizzando il formato `nuvio_plus_<versione>_<tagunivoco>.apk` (es. `nuvio_plus_0.4.13.1_9b09045.apk`).
3. **Commit e Push**: Aggiorna `.last_built_upstream_sha` (se in fase di sync upstream), ed esegui il commit e il push di tutte le modifiche (patch aggiornate, script, ecc.) sul repository remoto.
4. **Pubblicazione Release (Caricamento Locale)**: Poiché il workflow di GitHub Actions non è affidabile, crea direttamente una nuova Release su GitHub:
   - `gh release create <tag> <percorso_apk_locale> --title "Nuvio Plus <versione>" --notes "Note di rilascio"`
   - Specifica i file APK generati (universale e per architettura ABI).

---

## 📌 Checklist Rapida per l'Agente
- [ ] Verificato ultimo commit upstream via `git ls-remote`
- [ ] Applicata la regola di versionamento `0.4.13.x` (la versione base cambia solo con upstream)
- [ ] Testata l'applicazione di tutte le patch `patches/01-*` .. `05-*`
- [ ] Conflitti risolti preservando il codice upstream e le feature Plus
- [ ] Patch aggiornate e salvate in `patches/`
- [ ] Aggiornato `.last_built_upstream_sha`
- [ ] Compilato l'APK in locale firmato con keystore persistente `assets/keystore/nuvio-release.keystore`
- [ ] Ridenominati gli APK secondo lo standard `nuvio_plus_<versione>_<tag>.apk`
- [ ] Effettuato il commit e push su GitHub
- [ ] Creata la GitHub Release con `gh release create` e notificato all'utente
