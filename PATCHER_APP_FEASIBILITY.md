# Studio di Fattibilità & Architettura: Nuvio Patcher App (Stile Morphe / ReVanced)

## 📌 1. Introduzione & Concetto
Questo documento analizza la fattibilità tecnica, l'architettura e la strategia di sviluppo per creare un'applicazione Android **"Nuvio Patcher"** (ispirata a **Morphe**, **ReVanced Manager** o **LSPatch**).

L'obiettivo dell'app è consentire all'utente di:
1. Selezionare o scaricare direttamente l'APK ufficiale di **Nuvio Mobile**.
2. Applicare le personalizzazioni **Enhanced** (Live TV, Downloader, Branding, ecc.) direttamente sullo smartphone Android con un tocco.
3. Generare, firmare e installare l'APK modificato direttamente sul dispositivo senza passare da un computer o da server di compilazione remoti.

---

## 🔍 2. Come Funzionano i Patcher On-Device (Morphe / ReVanced)

Le app di patching on-device per Android non ricompilano il codice sorgente (il compilatore Gradle e Kotlin non possono girare su Android in modo efficiente). Invece operano a **livello di bytecode DEX e risorse binarie**:

```
[ APK Ufficiale Nuvio ] 
          │
          ▼
   [ Unpack APK ] ─────────► [ Estrazione DEX, Manifest, Risorse ]
          │
          ▼
 [ DexLib2 Patcher ] ──────► Inserimento Bytecode / MultiDex Hook
          │
          ▼
 [ Resource Patcher ] ─────► Modifica Manifest, stringhe e icone
          │
          ▼
[ Repack & APK Sign ] ─────► Firma con keystore locale (ApkSig)
          │
          ▼
[ Android PackageInstaller ] ──► Installazione diretta
```

### Componenti Chiave del Motore di Patch:
1. **`dexlib2` / `smali`**: Libreria Java/Kotlin per leggere, disassemblare, modificare e riassemblare i file `.dex` (bytecode Dalvik/ART).
2. **`AXML` / `ArscLib`**: Librerie per decodificare e modificare al volo il file `AndroidManifest.xml` binario e la tabella risorse `resources.arsc` (per cambiare il nome dell'app, il package name e i permessi).
3. **`apksig` (Google Android Signer)**: Libreria ufficiale Android usata per firmare l'APK risultante in formato V1, V2 e V3.
4. **Android PackageInstaller API**: Consente di avviare l'installazione dell'APK generato direttamente in-app tramite `PackageInstaller.Session`.

---

## 🧩 3. Analisi Tecnica per Nuvio (Kotlin Multiplatform + Jetpack Compose)

Nuvio Mobile è sviluppato con **Kotlin Multiplatform (KMP)** e **Compose Multiplatform**.

### Sfida di Jetpack Compose nel Bytecode:
- Il compilatore Jetpack Compose trasforma le funzioni `@Composable` generando parametri sintetici per lo stato di ricomposizione (`$composer`, `$changed`, numeri di versione).
- Tentare di inserire manualmente un'intera interfaccia utente complessa (come la schermata Live TV) modificando istruzione per istruzione il bytecode Smali è estremamente fragile ad ogni aggiornamento.

### 💡 Soluzione Architetturale Ottimale: *MultiDex Extension Injection*
Invece di modificare il codice esistente riga per riga:
1. **Pre-compilazione del Modulo Enhanced**: Compiliamo le schermate e le classi aggiuntive (Live TV, storage, downloader) in un file `.dex` autonomo (es. `enhanced-core.dex`).
2. **Iniezione MultiDex**: Il Patcher inserisce semplicemente `enhanced-core.dex` nell'archivio dell'APK come `classes2.dex` (o `classes3.dex`).
3. **Hook Entry Point Leggero**: Tramite `dexlib2`, il Patcher inietta **solo 2-3 istruzioni Smali** all'interno dell'Entry Point dell'app (es. in `AppShell` o `MainActivity`) per registrare la schermata Live TV e i tab personalizzati.
4. **Firma e Installazione**: L'APK viene riallineato con `zipalign`, firmato con `apksig` e installato.

---

## 🛠️ 4. Opzioni di Realizzazione del Patcher

| Caratteristica | Opzione A: Patcher On-Device (DEX Hook) | Opzione B: Nuvio Manager (Cloud Build + Direct Install) |
| :--- | :--- | :--- |
| **Funzionamento** | Modifica l'APK locale tramite iniezione MultiDex | Scarica l'APK già compilato e pronto dalle Release |
| **Requisiti Utente** | APK ufficiale Nuvio salvato sul telefono | Connessione internet |
| **Complessità Sviluppo** | Alta (gestione DEX, Smali, AXML, firma) | Media (UI moderna, download manager, auto-install) |
| **Tempo di Applicazione** | ~5-15 secondi sullo smartphone | ~10 secondi (tempo di download) |
| **Stabilità nel Tempo** | Richiede aggiornamento degli hook Smali se la struttura interna di Nuvio cambia radicalmente | Massima: ogni build è garantita al 100% dal compilatore |

---

## 🚀 5. Roadmap di Implementazione per Nuvio Patcher

Qualora decidessi di sviluppare l'app Patcher Android:

### Fase 1: Creazione dell'App Android Patcher (UI Compose)
- Creare un progetto Android leggero con Jetpack Compose e Material 3.
- Interfaccia con selezione file APK, toggle per attivare/disattivare le patch (Branding, Live TV, Updater).
- Schermata di log e barra di avanzamento del processo di patching.

### Fase 2: Motore di Patching Integrato
- Integrazione delle librerie:
  - `com.android.tools.build:apksig` (per la firma).
  - `org.smali:dexlib2` (per la manipolazione dei file DEX).
  - Gestore ZIP ottimizzato per streaming su memoria senza saturare la RAM del telefono.

### Fase 3: Modulo di Estensione MultiDex
- Creazione del pacchetto `enhanced-core.dex` contenente tutte le classi Live TV compilate.
- Implementazione dell'hook per collegare la navigazione di Nuvio al nuovo modulo.

### Fase 4: Installer In-App
- Gestione dei permessi `REQUEST_INSTALL_PACKAGES` e integrazione con l'API standard `PackageInstaller`.
