# Nuvio Mobile Enhanced — Elenco Completo Funzionalità

Questo documento riassume tutte le funzionalità e personalizzazioni avanzate introdotte nel fork **Enhanced** di Nuvio Mobile rispetto alla versione originale.

---

## 🎨 Interfaccia & Personalizzazione Visiva

### 1. Barra di Navigazione Ufficiale con Live TV e Download
- Utilizza la barra di navigazione ufficiale fluttuante di Nuvio (con animazione etichette, scroll state e blur Haze) e la modalità classica.
- Include le due schede dedicate aggiuntive: **Live TV** e **Download**, per un totale di 6 tab (Home, Cerca, Libreria, Live TV, Download, Profilo/Impostazioni).

### 2. Modalità AMOLED (Nero Puro)
- **Toggle AMOLED Base:** Imposta lo sfondo dell'app su nero assoluto (`#000000`) per massimizzare il risparmio energetico sui display OLED.
- **Sotto-opzione Superfici AMOLED:** Quando attivo, rende neri anche tutti i contenitori, card elevate, dialoghi e sfondi dei componenti interni. Se la modalità AMOLED viene disattivata, la sotto-opzione si disattiva automaticamente.

### 3. Selettore Colore Tema Personalizzato
- Possibilità di scegliere qualsiasi colore personalizzato per l'intera interfaccia.
- **Supporto Codice Esadecimale (HEX):** Campo di testo per digitare direttamente il colore desiderato (es. `#E50914`, `#00E5FF`).
- **Tavolozza Rapida:** Griglia con i colori preimpostati più popolari.
- **Slider HSV di Precisione:** Tre cursori dedicati per Tonalità (Hue), Saturazione (Saturation) e Luminosità (Value) con anteprima in tempo reale.

### 4. Icone Applicazione Personalizzate
- Scelta dinamica dell'icona dell'app Android tra molteplici stili:
  - *Default*, *Neon*, *Monochrome*, *Emerald*, *Aurora*, *Gear*, *Chrome*, *Enhanced Edition*.

### 5. Cataloghi TOP 10 Numerati
- Righe configurabili nella Home che mostrano poster con badge numerato da 1 a 10 con design graduato, evidenziando i contenuti in tendenza o più popolari.

### 6. Tab Download Diretta nella Barra di Navigazione (Navbar)
- Accesso rapido e diretto a tutti i media scaricati offline tramite pulsante dedicato nella barra inferiore (tra *Live TV* e *Profilo/Impostazioni*).
- Supporta layout sia mobile (Navbar classica e Glass) sia tablet/desktop (Floating Top Bar).

---

## 🎬 Player & Esperienza di Visione

### 1. Stream Parser Avanzato con Badge Animati
- Analisi automatica del titolo dello stream per estrarre e mostrare badge chiari e animati:
  - **Risoluzione:** 4K UHD, 1080p FHD, 720p HD, SD.
  - **Codec Video & HDR:** H.265 / HEVC, AV1, Dolby Vision, HDR10+, HDR.
  - **Audio:** Dolby Atmos, DTS-HD, TrueHD, 5.1 / 7.1 Surround.
  - **Stato Debrid / Cached:** Indicatore visivo istantaneo per stream già pronti alla riproduzione in cloud senza buffering.
- **Ordinamento Stream per Qualità:** Toggle per ordinare automaticamente i flussi dal migliore al peggiore.

### 2. Live TV con Supporto Playlist M3U
- Integrazione completa per canali televisivi in diretta tramite playlist M3U/M3U8 fornite dall'utente.
- **Guida TV (EPG):** Supporto a programmazione e metadati dove presenti nel feed.
- **Ricerca in Tempo Reale & Filtri:** Barra di ricerca rapida con contatore canali dinamico e filtri per categorie/gruppi.
- **Canali Preferiti:** Possibilità di contrassegnare i canali preferiti per un accesso istantaneo.
- **Isolamento Cronologia:** I canali Live TV non intasano la sezione "Continua la visione".

### 3. Sincronizzazione e Regolazione Sottotitoli
- **Controllo Ritardo con Accelerazione:** Tasti `+` e `-` con funzione *hold-to-accelerate* (accelerazione progressiva tenendo premuto) e aggiornamento debounced per sincronizzare audio e testo senza scatti.
- **Iniezione Sottotitoli OpenSubtitles & SubDL:** Ricerca, scaricamento e sincronizzazione automatica della propria API Key OpenSubtitles. Chip dedicato nel player per distinguere la sorgente dei sottotitoli.

### 4. Controlli Riproduzione & Gesti
- **Disabilitazione Swipe:** Possibilità di spegnere i gesti di scorrimento verticale per volume e luminosità, evitando tocchi accidentali.
- **Intervallo Salto Configurabile:** Impostazione precisa dei secondi da saltare al tocco avanti/indietro (es. 5s, 10s, 15s, 30s).
- **Prompt "Ancora in visione?" (Stile Netflix):** Notifica dopo periodi prolungati di inattività, con opzione per limitare la funzione alle ore notturne (22:00–04:00).

---

## 🔌 Estensioni, Plugin & Integrazioni

### 1. Supporto Plugin CloudStream 3 (DEX)
- Possibilità di caricare ed eseguire repository di plugin DEX nativi (`.cs3`) Android direttamente da Nuvio, oltre ai plugin JS/Stremio.
- Rilevamento automatico del formato del manifesto e badge dedicato "CloudStream" nelle schede dei repository.
- Supporto multi-architettura CPU (arm64-v8a, armeabi-v7a, x86_64).

### 2. Provider di Tracciamento & Metadati
- **SIMKL:** Tracciamento bidirezionale con autenticazione moderna OAuth PKCE, motore di sincronizzazione e visualizzazione stato.
- **MyAnimeList (MAL) & AniList:** Rating integrati da MDBList con icone vettoriali dedicate e schede informative.
- **Calendario Uscite in Libreria:** Vista a calendario con le date di rilascio dei prossimi episodi per tutte le serie presenti in "Continua la visione".

---

## ⚡ Rete, Downloader & Strumenti di Debug

### 1. HLS / M3U8 Downloader ad Alte Prestazioni
- Motore di download riscritto con supporto per:
  - Decrittazione flussi protetti **AES-128**.
  - Segmenti frammentati **fMP4** e rimuxing automatico in formato standard `.mp4`.
  - Scaricamento automatico delle tracce audio e sottotitoli secondarie (companion tracks).
  - Indicatori di progresso e barre di avanzamento nella sezione download.

### 2. Sicurezza & Privacy di Rete
- **DNS over HTTPS (DoH):** Risoluzione sicura dei domini contro blocchi DNS e sniffing dell'ISP.
- **User-Agent Personalizzabile:** Possibilità di definire uno User-Agent personalizzato per le richieste HTTP con 3 modalità: *Solo Addon*, *Solo Plugin* o *Entrambi*.

### 3. In-App Debug Log Viewer
- Visualizzatore di log integrato nell'app accessibile tramite BottomSheet con filtri per categoria (CloudStream, Player, Rete, Addon) ed esportazione facilitata per il troubleshooting.
