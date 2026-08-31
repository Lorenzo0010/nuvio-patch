# 🚀 Nuvio Plus — Auto-Sync & Build Pipeline

Questo repository mantiene le patch e le funzionalità **Plus** per [Nuvio Mobile](https://github.com/NuvioMedia/NuvioMobile) e include una pipeline **GitHub Actions** automatizzata che:
1. 🔍 **Monitora continuamente** il repository ufficiale (`NuvioMedia/NuvioMobile:cmp-rewrite`).
2. 🔄 **Sincronizza e applica le patch Plus** appena viene rilasciato un nuovo aggiornamento o commit.
3. 🛠️ **Compila l'APK Android** (Release o Debug).
4. 📦 **Pubblica una nuova Release su GitHub** con l'APK pronto da scaricare e installare.
5. ⚡ **Isolamento Completo:** Application ID `com.nuvio.app.plus` e FileProvider indipendente per evitare conflitti con la versione ufficiale di Nuvio.
6. ⚠️ **Apre automaticamente una Issue** se un aggiornamento a monte introduce conflitti di codice.

---

## ✨ Funzionalità Plus Incluse

Consulta il file [ENHANCEMENTS.md](ENHANCEMENTS.md) per l'elenco e la spiegazione dettagliata di tutte le caratteristiche.

- ⚡ **Nuvio Plus Side-by-Side:** Package ID `com.nuvio.app.plus` installabile in parallelo all'app originale senza conflitti.
- 📺 **Live TV (M3U / EPG):** Canali in streaming, ricerca in tempo reale, gestione preferiti e categorie.
- 🖤 **Modalità AMOLED Puro:** Sfondi e superfici neri (`#000000`) per display OLED.
- 🎨 **GlassMorph BottomBar:** Barra di navigazione traslucida e selettore colore HEX/HSV.
- 📊 **Stream Parser Animato:** Badge per qualità (4K/1080p), codec audio/video e stato debrid/cached.
- 📥 **HLS/M3U8 Downloader:** Decrittazione AES-128, supporto fMP4 e rimuxing automatico in MP4.
- ⚡ **Plugin CloudStream 3 DEX:** Supporto ai plugin nativi `.cs3` con architetture multiple.
- 🔗 **Integrazioni Extra:** SIMKL (OAuth PKCE), MyAnimeList (MAL), AniList, OpenSubtitles API sync, Calendario uscite.
- 🔒 **Rete & Debug:** DNS over HTTPS (DoH), User-Agent Override personalizzato e In-App Log Viewer.

---

## ⚙️ Come Configurare il Repository su GitHub

### 1. Creazione dei GitHub Secrets (Opzionali ma consigliati)
Vai su **Settings** > **Secrets and variables** > **Actions** nel tuo repository GitHub e inserisci:

| Secret | Descrizione | Obbligatorio? |
|---|---|---|
| `KEYSTORE_BASE64` | File Keystore (`.keystore` / `.jks`) codificato in Base64 per firmare sempre l'APK con la stessa chiave. | No *(se assente, ne viene generato uno automatico)* |
| `TMDB_API_KEY` | Chiave API di The Movie Database per la risoluzione dei metadati. | Consigliato |
| `TRAKT_CLIENT_ID` | Client ID per l'integrazione con Trakt.tv. | Opzionale |
| `TRAKT_CLIENT_SECRET` | Client Secret per Trakt.tv. | Opzionale |
| `SUPABASE_URL` | URL dell'istanza Supabase (se usata per sync). | Opzionale |
| `SUPABASE_ANON_KEY` | Chiave Anon di Supabase. | Opzionale |

#### Come generare `KEYSTORE_BASE64` da un file esistente:
```bash
# Su Linux/macOS:
base64 -w 0 nuvio-release.keystore > keystore_base64.txt

# Su Windows (PowerShell):
[Convert]::ToBase64String([IO.File]::ReadAllBytes("nuvio-release.keystore")) | Out-File keystore_base64.txt
```

---

## 🏃 Avvio della Compilazione

### 🔄 Automatico:
La GitHub Action si avvia automaticamente **ogni 6 ore**. Se non ci sono nuovi commit su `NuvioMedia/NuvioMobile`, la pipeline si arresta subito senza consumare minuti di calcolo.

### 🔘 Manuale (Dispatch):
1. Vai nella scheda **Actions** del tuo repository su GitHub.
2. Seleziona **Auto-Sync Upstream & Build Enhanced APK**.
3. Clicca su **Run workflow**:
   - Spunta `force_build` se vuoi forzare la ricompilazione immediata.
   - Scegli tra `release` o `debug`.
4. Al termine, troverai l'APK nella sezione **Releases** del tuo repository.

---

## 💻 Script Locali (Per Sviluppatori)

Troverai gli script di manutenzione nella cartella `scripts/`:

- **Estrazione/Aggiornamento delle patch:**
  - PowerShell: `.\scripts\extract-patches.ps1`
  - Bash: `./scripts/extract-patches.sh`
- **Test locale di applicazione patch:**
  - PowerShell: `.\scripts\test-patch-apply.ps1`
  - Bash: `./scripts/test-patch-apply.sh`

---

## 📁 Struttura del Repository

```text
├── .github/
│   └── workflows/
│       └── auto-sync-and-build.yml  # Pipeline di controllo, merge e build
├── patches/                         # File .patch contenenti le feature Enhanced
├── assets/
│   └── extra_libs/                  # Librerie binarie (.aar, .jar)
├── scripts/                         # Script di supporto per estrazione e test
├── ENHANCEMENTS.md                  # Documentazione delle funzionalità Enhanced
├── README.md                        # Questa guida
└── .last_built_upstream_sha         # Commit SHA dell'ultima build eseguita
```
