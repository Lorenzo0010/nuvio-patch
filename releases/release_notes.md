## Novità in Nuvio Plus Mobile 0.4.14.12

### ⏱️ Timeout Addon Esteso a 30 Secondi
- **Risoluzione Flussi Lenti**: Il timer di fallback per la modalità *"Solo Addon"* è stato esteso a **30 secondi** (raddoppiato rispetto ai precedenti 15s) per garantire che tutti gli addon e le ricerche sui flussi lenti o complessi abbiano il tempo necessario per restituire i migliori link disponibili prima di tentare fallback alternativi.

### 🔄 Animazione di Progresso Determinato sui Pulsanti di Download
- **Indicatore Live sui Pulsanti**: Tutti i pulsanti di download (nella scheda dettagli dei Film e nelle schede/liste degli Episodi delle Serie TV) integrano ora un anello di avanzamento circolare animato (`CircularProgressIndicator` con `animateFloatAsState`) che segue con precisione millimetrica la percentuale di completamento del download (0%..100%).
- **Feedback Immediato**: L'utente vede direttamente sul pulsante lo stato corrente del download (rotella indeterminata durante la fase di ricerca/risoluzione stream, e barra circolare determinata con percentuale numerica non appena il download è attivo).

### 🛡️ Protezione e Download Continuo in Background
- **Zero Interruzioni**: Implementato un meccanismo di sicurezza con keep-alive e wake-lock persistente (`acquireKeepAlive` / `releaseKeepAlive`) per assicurare che né l'uscita dalla schermata dei dettagli del titolo, né il passaggio ad altre schermate o la minimizzazione dell'app in background interrompano la ricerca o lo scaricamento del video.
- **Coroutines Globali e Notifiche di Sistema**: Il download continua senza interruzione fino al termine o all'eventuale cancellazione esplicita da parte dell'utente.

### 🖱️ Azione Rapida e Menu Avanzato
- Supporto al click secondario / pressione prolungata per visualizzare istantaneamente lo sheet di selezione manuale avanzata di qualità HLS, audio e sottotitoli.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.12` senza suffissi o hash commit, conforme al protocollo `AGENTS.md`.
- APK firmati con il keystore persistente ufficiale `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).
