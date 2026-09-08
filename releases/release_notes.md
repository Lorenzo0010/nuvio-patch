## Novità in Nuvio Plus Mobile 0.4.14.13

### 📋 Monitoraggio Coda di Download Diretta
- **Visualizzazione Coda Pending**: Integrata direttamente nella schermata dei Download la visualizzazione della coda in attesa (`pendingQueue`), con monitoraggio dello stato di avanzamento e dei download programmati in background.
- **Accesso Rapido alle Impostazioni Download**: Aggiunto collegamento diretto alle impostazioni dei download dalla toolbar superiore della sezione Download.

### ⏱️ Timeout Addon Esteso a 30 Secondi
- **Risoluzione Flussi Lenti**: Il timer di fallback per la modalità *"Solo Addon"* è confermato a **30 secondi** per garantire che tutti gli addon debrid/streaming abbiano il tempo necessario prima di tentare fallback.

### 🔄 Animazione di Progresso Determinato sui Pulsanti
- **Indicatore Live sui Pulsanti**: I pulsanti di download di film ed episodi mostrano l'anello circolare animato con percentuale di completamento precisa (0%..100%).

### 🛡️ Protezione e Download Continuo in Background
- **Zero Interruzioni**: Keep-alive e wake-lock continuo (`acquireKeepAlive` / `releaseKeepAlive`) per garantire che lo scaricamento proceda senza blocchi anche a schermo spento o app minimizzata.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.13` conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con il keystore persistente ufficiale `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).
