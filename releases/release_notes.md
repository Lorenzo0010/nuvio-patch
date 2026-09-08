## Novità in Nuvio Plus Mobile 0.4.14.19

### 🛠️ Fix persistenza coda download
- La coda di auto-download ora sopravvive al riavvio dell'app: snapshot serializzabile (`PendingAutoDownloadPayload`, solo primitivi) ripristinato all'avvio con ricreazione dei placeholder "In coda".
- Corretto errore di compilazione nel logger del worker di coda.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.19` (versionCode `140`) conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con keystore persistente `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.14.18

### 🔘 Icone download statiche per 4 stati
- **Non in download**: icona Download
- **In coda** (in attesa di partire): icona Schedule (orologio)
- **Scaricando**: icona Pause
- **Completato**: icona Check (✓)

Rimosso l'anello circolare animato per coerenza visiva.

### 🔄 Coda unificata in "Attivi"
- Un solo elemento per contenuto: placeholder lascia il posto al download reale senza duplicati.

### 🛡️ Fix crash coda (v0.4.14.14)
- Worker isolato per item: errore non uccide worker/app.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.18` conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con keystore persistente `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).