## Novità in Nuvio Plus Mobile 0.4.14.15

### 🔄 Coda unificata in "Attivi"
- **Sezione "Queue" rimossa**: gli elementi in coda (download non ancora avviati) ora appaiono direttamente nella sezione **Attivi**, sopra i download in corso.
- **Indicatore live**: mostrano il messaggio di fase (es. *"In coda: …"*, *"Ricerca stream…"*) senza pulsanti pausa/riprendi.
- **Cancellazione diretta**: puoi annullare un elemento in coda dallo stesso pulsante elimina.

### 🔘 Progresso sul pulsante download (Detail)
- Il pulsante **Download** nella scheda dettaglio film/serie ora mostra l'anello circolare animato con percentuale (1%..100%) durante l'avvio e lo scaricamento.
- Al termine diventa un **tick** (✓) per aprire/riprodurre.

### 🛡️ Fix crash coda (v0.4.14.14)
- Worker isolato per item: un errore non uccide più il worker né l'app.
- Placeholder stabile: lo stream trovato viene legato alla stessa riga (stesso id), niente sparizioni/riapparizioni.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.15` conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con il keystore persistente ufficiale `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).