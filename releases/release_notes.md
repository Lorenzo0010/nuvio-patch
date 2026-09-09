# Note di rilascio — Nuvio Plus Mobile

## Novità in Nuvio Plus Mobile 0.4.14.22

### 🛡️ Download Debrid Cached: niente più crash a fine download e episodi mai persi

- **Pipeline HLS riscritta**: un segmento che fallisce in ritardo (CDN debrid che tronca la connessione dopo l'ultimo byte) non fa più fallire l'intero download già completo. Prima un segmento "pigro" poteva generare un errore proprio alla fine → download fallito o porta di crash. Ora ogni segmento consegna successo o errore una sola volta e il motore scrive su disco in modo deterministico: se tutti i byte sono arrivati, il file viene finalizzato.
- **Fallback automatico riparato**: quando uno stream falliva in partenza, la riga NON tornava più allo stato di placeholder → il candidato successivo non trovava la riga e l'episodio spariva o restava bloccato ("scaricato e non salvato"). Ora il fallback ripristina correttamente la riga e prova lo stream successivo.
- **Retry automatico dei download falliti a metà**: se un download parte ma fallisce durante il trasferimento (CDN instabile, playlist scaduta), l'episodio viene riaccedato automaticamente UNA volta con nuova ricerca stream invece di restare "Failed" in lista.
- **Worker di coda resiliente**: gli errori non gestiti non cancellano più la riga né fermano la coda: l'episodio resta visibile e il worker riprova (fino a 3 tentativi), poi lascia la riga con messaggio esplicito. Niente più episodi che "spariscono in silenzio".
- **Righe orfane recuperate all'avvio**: eventuali download bloccati senza sorgente vengono marcati come falliti con messaggio chiaro (prima ripartivano all'infinito o restavano "in coda" per sempre).
- **Firma e integrità**: versione pulita `0.4.14.22` (versionCode `143`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.14.21

### 📡 Download HLS: retry automatico su 403/502 e gestione CDN instabili
- **Retry con backoff su segmenti e playlist HLS**: un segmento che risponde `403` (rate limit / token momentaneo / edge CDN instabile) o `502/503` sul fetch della playlist ora viene **ritentato automaticamente** (fino a 3 tentativi con backoff crescente) invece di far fallire l'intero download. È il motivo principale degli errori "HLS segment 3/339 failed (HTTP 403)".
- **Header `Referer` automatico su tutti i download HLS** (manifest, segmenti, audio, sottotitoli, probe): molti CDN anti-hotlinking restituiscono 403 quando manca. Usato anche nel fetch della playlist master e nel probe di sniffing.
- **Cookie JAR di sessione**: i cookie restituiti dai manifest (sessioni CDN) vengono conservati e reinviati alle richieste dei segmenti. Diversi CDN HLS autorizzano i segmenti solo con il cookie di sessione.
- **Retry anche sui download diretti**: un 403/429/5xx alla prima richiesta (cold cache dei CDN debrid) viene ritentato prima di segnare il download come fallito.
- **Niente più download corrotti**: se la playlist HLS non è leggibile, il download NON scarica più il file `.m3u8` come se fosse il video completo: la riga torna in attesa e si prova la sorgente successiva.

### 🗂️ Download Debrid Cached
- I flussi debrid cached (RealDebrid/Torbox/Premiumize ecc.) ora beneficiano di tutti i punti sopra: retry alla risoluzione del link, Referer/cookie se il CDN finale serve HLS, fallback più pulito se il link non è ottenibile.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.21` (versionCode `142`) conforme alle regole di versionamento `AGENTS.md`.
- APK firmati con keystore persistente `nuvio-release.keystore` (SHA-256: `BF:46:A0:35:B7:...`).

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