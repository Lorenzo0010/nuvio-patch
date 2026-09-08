## Novità in Nuvio Plus Mobile 0.4.14.20

### 🛠️ Coda download: ciclo di vita completo riscritto e stabilizzato
- **Scheduler FIFO con concorrenza limitata**: non si parte più con download illimitati in parallelo. Ora massimo 2 download simultanei, di cui **un solo HLS alla volta** (i remux sono pesanti in memoria). Accodare decine di episodi non causa più crash/OOM.
- **Ripristino automatico al riavvio**: i download interrotti (chiusura app o crash) **ripartono da soli** all'apertura: i diretti riprendono dal file `.part`, gli HLS ricominciano da zero. Niente più righe "in coda" che non partono mai.
- **Recupero crash a metà remux**: un download bloccato nello stato `Processing` (es. crash durante il remux HLS) viene riportato in `Downloading` e riavviato automaticamente.
- **Worker di coda riavviato dopo riavvio**: la coda di auto-download persistita viene ricaricata E il worker riparte subito (prima restava ferma).
- **Meno attriti durante il download**: progress delle notifiche coalescente e sempre sul main thread (niente chiamate concorrenti da chunk IO), persistenza del progresso su disco throttled (ogni 2s).
- **Fix vari**: annullamento placeholder con chiave corretta (la cancellazione del placeholder funziona ora davvero), riordino `onProfileChanged` (backlog prima dei placeholder), eliminati race e loop infinito dello scheduler.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.20` (versionCode `141`) conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con keystore persistente `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).

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