## Novità in Nuvio Plus Mobile 0.4.14.14

### 🛡️ Fix Crash Cambio Download in Coda
- **Worker a prova di crash**: l'esecuzione di ogni elemento in coda è isolata; un errore su un item non uccide più il worker né chiude l'app, si passa automaticamente al download successivo.
- **Fasi pre-try protette**: anche keep-alive e notifiche di avvio sono dentro il blocco di gestione errori.

### 👁️ Download Sempre Visibile dal Primo Tap
- **Riga immediata in Download**: non appena tocchi download, il film/episodio appare nella scheda Download (sezione Attivi) già durante prefetch/ricerca stream.
- **Aggiornamento per fase**: la riga mostra lo stato live — *"In coda"*, *"Ricerca dello stream…"*, *"Ricerca dagli addon/plugin…"*, *"Tentativo avvio con: …"*, poi progresso reale.
- **Niente più sparizioni**: lo stream trovato viene legato alla stessa riga (stesso id), anche nei fallback tra candidati; la cancellazione utente interrompe tutto in silenzio senza toast spuri.
- I placeholder non vengono persistiti su disco e non hanno pulsanti pausa/riprendi.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.14` conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con il keystore persistente ufficiale `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).
