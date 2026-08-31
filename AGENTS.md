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
3. **Applica manualmente le modifiche/integrazioni Enhanced** preservando sia le nuove modifiche ufficiali dell'upstream, sia tutte le funzionalità Enhanced (es. tab Live TV, gestione icone, ecc.).
4. **Rigenera la patch aggiornata** sovrascrivendo il file corrispondente in `patches/`.

---

### Fase 4: Verifica e Copia Asset
1. Verifica che se presenti librerie in `assets/extra_libs` vengano copiate in `composeApp/libs`.
2. Verifica che se presenti librerie native in `assets/jniLibs` vengano copiate in `composeApp/src/androidMain/jniLibs`.
3. Esegui lo script di test:
   - PowerShell: `powershell -ExecutionPolicy Bypass -File .\scripts\test-patch-apply.ps1`
   - Bash: `bash ./scripts/test-patch-apply.sh`

---

### Fase 5: Commit, Push e Pubblicazione
1. Aggiorna `.last_built_upstream_sha` con il nuovo SHA di upstream.
2. Esegui il commit di tutte le patch aggiornate e dei file modificati:
   ```bash
   git add patches/ .last_built_upstream_sha scripts/
   git commit -m "feat(upstream): sync to upstream <SHORT_SHA> and update patches"
   git push origin main
   ```
3. Il push su `main` attiverà automaticamente la build su GitHub Actions (`.github/workflows/auto-sync-and-build.yml`), che compilerà l'APK e creerà la nuova **GitHub Release**.

---

## 📌 Checklist Rapida per l'Agente
- [ ] Verificato ultimo commit upstream via `git ls-remote`
- [ ] Testata l'applicazione di tutte le patch `patches/01-*`, `patches/02-*`, `patches/03-*`
- [ ] Conflitti risolti preservando il codice upstream e le feature Enhanced
- [ ] Patch aggiornate e salvate in `patches/`
- [ ] Aggiornato `.last_built_upstream_sha`
- [ ] Push su `main` effettuato e notificato all'utente il rilascio della build
