# Note di rilascio — Nuvio Plus Mobile

## Novità in Nuvio Plus Mobile 0.4.17.1

### 🚀 Allineamento Upstream 0.4.17
- **Base Upstream 0.4.17**: Allineata la base dell'app all'upstream ufficiale `0.4.17` (`74492b2`), mantenendo il 100% del codice originale.
- **Nuova Navigazione "Jelly" Integrata**: Supporto completo per la nuova `FloatingNavigationBar` dinamica sia per la visualizzazione mobile che per tablet, integrando perfettamente i tab dedicati **Live TV** e **Download** con animazioni fluide e stile coerente.
- **Player & Streams Screen**: Integrati i nuovi parametri di rendering dei provider e formattazione badge/dimensione stream (`LocalStreamSizeLabelFormat`), salvaguardando il motore di selezione multitraccia e download HLS Plus.
- **Funzionalità Plus 100% Preservate**: Live TV (M3U, canali, categorie, pannello player), motore di download HLS a segmenti paralleli e decrittazione AES-128 con salvataggio/condivisione, selettore cartella personalizzata SAF e updater dedicato su `Lorenzo0010/nuvio-patch`.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.17.1` (versionCode `155`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:46:8E:77:E2:2D:2D:1F:CE:3A:C9:43:14:E9:EB:D1:AD:35:03:EB:75:C0:06:89:1C:54:46:B7`).

## Novità in Nuvio Plus Mobile 0.4.15.9

### 📥 Ripristino funzioni HLS Plus (stato pre-82fb0e4, rielaborato su base 0.4.15)
- **Progresso per traccia**: durante il download HLS la schermata Download e le notifiche mostrano l'avanzamento separato di Video, Audio e Sottotitoli.
- **Stato Elaborazione**: quando inizia il remux MP4 l'item passa in "Elaborazione • …" invece di restare fermo; le notifiche offrono l'azione di annullamento in quella fase.
- **Condividi/Salva**: sui download completati tornano i tasti Condividi (chooser di sistema) e Salva (copia con SAF).
- **DNS-over-HTTPS**: il motore di download usa DoH selezionabile (Cloudflare, Google, Quad9, AdGuard, NextDNS, Mullvad, OpenDNS) con fallback al DNS di sistema.
- I download diretti restano sul flusso originale invariato; mantenuti gli hardening (cookie di sessione CDN, Referer, retry 403/429/5xx, rilevamento HLS).

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.9` (versionCode `154`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).
- Base upstream invariata (`e377942`, 100% funzioni originali).

## Novità in Nuvio Plus Mobile 0.4.15.8

### 🎧 Fix selezione tracce audio/sottotitoli HLS
- Rimosso `distinctBy { it.uri }` troppo aggressivo: le playlist HLS reali usano lo stesso URI per tracce audio diverse (gruppi separati). Ora ogni traccia compare separatamente e si seleziona indipendentemente.
- Risolti: impossibile selezionare risoluzione (dropdown vuoto se varianti assenti) e una sola lingua audio visibile.

### ➖ Rimossa la compatibilità plugin JS (patch 06)
- Il runtime plugin torna al 100% upstream: niente più shim `require('crypto'/'fs'/'axios'/...)`. Restano solo le patch strettamente necessarie al download HLS (01–05).
- Base upstream invariata (`e377942`).

### 🎧 Fix selezione tracce audio/sottotitoli HLS
- Nel menu di selezione, se la playlist ripete la stessa traccia in più gruppi, le righe condividevano la selezione (togliendone una si toglievano tutte). Ora ogni flusso compare una sola volta e si seleziona indipendentemente.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.7` (versionCode `152`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.15.6

### 🔌 Fix plugin: moduli `fs`, `axios` e altri mancanti
- Dopo il fix `crypto`, i plugin (es. helper `cloudflare_provider_fetch.js`) chiedevano altri moduli Node: analizzati tutti i bundle EasyStreams, gli externals usati sono `axios`, `crypto`, `fs`, `http`/`https`, `path` (`undici` è già in `try/catch` nel plugin e non serve).
- Ora il runtime JS fornisce: `require('fs')` (in-memory), `require('path')` (posix), `require('http'/'https')` (stub `Agent`), `require('axios')` (minimale sopra fetch nativo, con `CancelToken`/`isCancel`), globale `process` e timer `setTimeout`/`clearTimeout` (no-op sicuri, le richieste usano i timeout nativi).
- Restano validati: `require('crypto')`, `Buffer`, base upstream invariata (`e377942`, 100% funzioni originali).

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.6` (versionCode `151`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.15.5

### 🔌 Fix plugin: modulo `crypto` non disponibile
- I plugin che usano `require('crypto')` (es. helper `cloudflare_provider_fetch.js`) fallivano nel test/ricerca con `Error: Module 'crypto' is not available` e di conseguenza anche il passaggio Cloudflare non partiva. Ora il runtime JS espone un modulo `crypto` compatibile Node (`createHash`, `createHmac`, `createCipheriv`/`createDecipheriv` AES, `pbkdf2Sync`, `randomBytes`/`randomUUID`, `timingSafeEqual`) appoggiato ai bridge crittografici nativi, più un `Buffer` minimo globale (`require('buffer')` incluso).
- Base upstream invariata (`e377942`, 100% funzioni originali) + patch 06.
- Schermata test plugin: gli errori del test ora mostrano il messaggio completo in modo più leggibile.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.5` (versionCode `150`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.15.4

### 🧹 Schermata Download semplificata
- Rimosso il tasto "Apri cartella download" dalla schermata Download: resta solo l'ingranaggio che apre la scelta della cartella personalizzata (o il ripristino ai predefiniti).

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.4` (versionCode `149`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.15.3

### 🧹 Riprogettazione: base originale + sole patch essenziali
- L'app torna al **100% alla base originale NuvioMobile 0.4.15**, con in aggiunta **solo**:
  - **Download HLS**: tieni premuto uno stream — se è torrent parte il motore originale, se è `.m3u8` si apre la selezione qualità/tracce e scarica il motore Plus (segmenti paralleli, decrypt AES-128, remux MP4, audio/sottotitoli companion).
  - **Cartella di download personalizzata**: ingranaggio nella schermata Download → scegli la cartella (vale per tutti i download).
  - **Live TV**: playlist M3U, preferiti, pannello canali nel player.
  - **Updater Plus e branding** (`com.nuvio.app.plus`, nome Nuvio Plus).
- **Rimosso tutto il resto**: widget launcher, prefetch/auto-download, coda Plus, pagina "Patches Plus" nelle Impostazioni (le Impostazioni tornano identiche all'originale), pulsanti download extra, dialog e icone aggiuntive. I download diretti usano di nuovo il flusso originale invariato.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.3` (versionCode `148`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.15.2

### 📂 Cartella personalizzata per tutti i download
- La cartella di download scelta nelle impostazioni (Plus → Posizione di download) ora vale per **tutti i tipi di download**, non solo per gli HLS: al completamento, anche i file scaricati dal sistema in background vengono spostati automaticamente nella cartella scelta.
- Se il download era già stato completato in background ad app chiusa, il file viene adottato senza riscaricarlo (e spostato nella cartella personalizzata se impostata).
- Rimosso il tasto "Apri cartella download" dalla schermata Offline e dalla scheda Plus (la gestione dei file resta al file manager di sistema).

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.2` (versionCode `147`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.15.1

### ⬆️ Porting su base upstream 0.4.15 (100% upstream + patch Plus)
- **Nuovo sistema di download in background upstream**: i download HTTP/HTTPS diretti usano ora `AndroidDownloadScheduler` con store persistente su disco, retry automatici e User-Initiated Jobs su Android 14+ (`DownloadsTransferJobService`) / WorkManager (`DownloadsTransferWorker`) sulle versioni precedenti.
- **Download HLS Plus invariati**: gli stream `.m3u8` continuano a usare il motore Plus (download parallelo segmenti, decrypt AES-128, remux MP4, selezione tracce audio/sottotitoli, coda dinamica, progress per traccia, notifiche con tasti Pausa/Riprendi).
- **Coda dinamica e tasti preservati**: pausa/ripresa/annullamento e coda FIFO Plus funzionano sopra il nuovo scheduler; le notifiche mostrano i tasti e il progresso per traccia.
- **Nuove funzioni upstream integrate**: editor temi personalizzati (gradienti/colori custom), disponibilità riproduzione (`PlaybackAvailability`: il tasto Play si disabilita quando non c'è sorgente), resume position condiviso, lingua russa, miglioramenti home/player/sottotitoli (risoluzione formati off-main-thread).
- **Bugfix player**: rimossi i duplicati del resolver MIME sottotitoli (ora si usa `PlaybackSubtitleMime` upstream), ripristinato il cleanup libass (`releaseWithAssSupportCompat`), risoluzione item media in `LaunchedEffect` (niente più rete sul Main thread).

### 🏷️ Firme e Integrità
- Versione pulita `0.4.15.1` (versionCode `146`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.14.24

### 🔧 Hardening del sottosistema Download (bug report interno)
Risolti 11 problemi individuati nell'analisi del codice di download:

- **B-01 – Spin-lock eliminato**: il lock dello scheduler usava un busy-wait su `Mutex.tryLock()` (consumo CPU e rischio race). Sostituito con `synchronized` JVM (rientrante, sezioni critiche brevi).
- **B-02 – SSL trust-all rimosso**: i download non accettano più certificati arbitrari con verifica hostname disabilitata (rischio MITM). Ora il client usa la PKI di sistema Android.
- **B-03 – Niente più `runBlocking` su Main in caso di failure**: `handleDownloadFailure` è ora suspend e usa una sola stringa precaricata (niente UI bloccata, messaggi coerenti).
- **B-04 – Race `notifyScheduled` eliminata**: coalescing delle notifiche ora con `AtomicBoolean.compareAndSet` (niente doppie notifiche concorrenti).
- **B-05 – Fetch playlist HLS fuori dal Main**: `fetchHlsMasterPlaylist` è ora `suspend` con HTTP su `Dispatchers.IO`.
- **B-06 – Validazione MP4 binaria**: la ricerca dell'atom `moov` ora è binaria (fourCC) invece di `decodeToString()` UTF-8, che produceva falsi negativi su file MP4.
- **B-07 – URL HLS con path assoluti**: sostituito il resolver difettoso con `resolveHlsUrl` che gestisce path `/assoluti`, `..` e query (niente più 400/404 su CDN).
- **B-08 – Coda persa a riavvio**: la pending queue ora viene salvata subito dopo l'accodamento (prima c'era una finestra di crash che perdeva l'episodio).
- **B-09 – `runBlocking` nei toast rimossi**: i messaggi di esito enqueue sono precaricati via `stringResource` nei context composable.
- **B-10 – Job di cleanup fuori dal lock**: il lancio della coroutine di rimozione "Processing" non avviene più dentro `schedulerLocked`.
- **B-11 – MIME audio reale nel remux**: il muxer usa il codec effettivo estratto (Opus/AC3/EAC3/AAC) invece di forzare sempre `AUDIO_AAC`.

### 🏷️ Firme e Integrità
- Versione pulita `0.4.14.24` (versionCode `145`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

## Novità in Nuvio Plus Mobile 0.4.14.23

### 🗑️ Cancellazione con conferma dal pulsante "Scaricato" (✓)
- **Film**: quando un film è già scaricato, toccando il pulsante con il tic (✓) accanto al pulsante Play ora compare una finestra di conferma: "Il download di … verrà eliminato dal dispositivo". Confermando, la riga e il file vengono rimossi; annullando, non succede nulla.
- **Serie TV**: stesso comportamento su ogni episodio scaricato, sia nella card orizzontale (schermo) sia nella vista elenco: il tic (✓) ora chiede conferma prima di eliminare l'episodio. Nessuna cancellazione accidentale.
- Prima il tocco sul tic mostrava solo un avviso "Contenuto già scaricato": ora l'azione di eliminazione è davvero disponibile da lì (la cancellazione resta comunque possibile anche dalla schermata Download).
- **Firma e integrità**: versione pulita `0.4.14.23` (versionCode `144`), APK firmati con keystore persistente (SHA-256: `BF:46:A0:35:B7:...`).

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