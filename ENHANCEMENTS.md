# Nuvio Plus Mobile — Funzionalità (build slim)

Questo documento descrive le **sole** personalizzazioni del fork Plus rispetto alla base originale NuvioMobile (`cmp-rewrite`). Tutto il resto dell'app è il 100% del codice upstream, invariato.

## Patch applicate (ordine)

1. `01-branding-and-config` — package `com.nuvio.app.plus` (installabile side-by-side), nome "Nuvio Plus", firma release con fallback debug.
2. `02-app-updater` — controllo aggiornamenti reindirizzato sulle GitHub Releases di `Lorenzo0010/nuvio-patch`.
3. `03-live-tv` — sezione Live TV.
4. `04-hls-downloads` — motore di download HLS + tab Download.
5. `05-download-folder` — cartella di download personalizzata + versione corrente.
6. `06-plugin-crypto` — compatibilità runtime plugin JS (`require('crypto')`/`Buffer`).

## 📺 Live TV (patch 03)

- Tab **Live TV** nella barra di navigazione (mobile + tablet).
- Sorgenti playlist **M3U/M3U8** configurabili, categorie/gruppi, ricerca canali con contatore.
- **Preferiti**, canale recente, pannello canali dentro il player (solo per sorgenti live).
- I canali live non inquinano "Continua la visione".

## ⬇️ Download HLS (patch 04)

- Nessun pulsante aggiunto: il download parte dal **long-press sullo stream** (stesso gesto dell'originale).
  - Stream **torrent/diretti** → flusso di download originale, invariato.
  - Stream **HLS (`.m3u8`)** → sheet di selezione **qualità + tracce audio/sottotitoli**, poi motore Plus.
- Motore HLS: download parallelo dei segmenti con retry/backoff (403/429/5xx), cookie di sessione, header `Referer` automatico, decrypt **AES-128**, supporto fMP4, **remux MP4** (MediaMuxer), tracce companion audio/video separate.
- La riga download usa il modello/screen originale (progresso, pausa/ripresa/retry/cancella): niente code, placeholder, prefetch o stati extra.
- Servizio foreground dedicato + wake lock per i download HLS in background.

## 📂 Cartella di download (patch 05)

- **Ingranaggio nella schermata Download** (tab Offline) → selettore cartella (SAF) + ripristino predefinito.
- Vale per **tutti** i download: i file completati (anche in background ad app chiusa) vengono spostati nella cartella scelta; la risoluzione dei file la cerca lì per prima.
- Le **Impostazioni restano identiche all'originale**: nessuna pagina/voce "Plus".

## 🔌 Compatibilità plugin JS (patch 06)

- `require('crypto')` / `require('node:crypto')`: `createHash` (MD5/SHA-1/256/384/512), `createHmac`, `createCipheriv`/`createDecipheriv` (AES-CBC/ECB 128/192/256), `pbkdf2Sync`, `randomBytes`/`randomFillSync`/`randomInt`/`randomUUID`, `timingSafeEqual` — eseguiti sui bridge crittografici nativi dell'app.
- `Buffer` globale minimo + `require('buffer')` (`from`/`alloc`/`concat`/`isBuffer`/`byteLength`, `toString('hex'/'base64'/'utf8'/...)`).
- `require('fs')` (in-memory: `read/write/exists/unlink/stat/rename/mkdir`), `require('path')` (posix: `join`/`resolve`/`dirname`/`basename`/`extname`), `require('http'/'https')` (stub `Agent`), `require('axios')` (minimale sopra fetch nativo: `get`/`post`/`create`, `CancelToken`, `isCancel`), globale `process` (`env`/`cwd`/`versions`/...) e timer `setTimeout`/`clearTimeout`/`setInterval` (no-op sicuri: le richieste usano i timeout nativi).
- Serve ai plugin che usano helper di tipo `cloudflare_provider_fetch.js` (prima fallivano con `Module 'crypto'/'fs' is not available` e il ripiego Cloudflare non partiva). Verificato contro i bundle EasyStreams: gli unici externals usati sono `axios`, `crypto`, `fs`, `http`/`https`, `path` (`undici` è già in `try/catch` nel plugin).

## Rimosso rispetto alle build Plus precedenti

Widget launcher, prefetch/auto-download e coda Plus, pagina "Patches Plus", pulsanti download nelle schede dettaglio, dialog di conferma extra, icone-stato download, salvataggio copia/Condividi, DNS-over-HTTPS, logger in-app, fix player extra.
