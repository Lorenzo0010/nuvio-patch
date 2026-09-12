# Nuvio Plus Mobile

Questo è un repository di manutenzione a patch per personalizzare e aggiungere funzionalità all'app **Nuvio Mobile** originale (basata su Compose Multiplatform). 

## Stato Attuale
Attualmente, le patch applicate all'upstream originale introducono le seguenti funzionalità:
- **Branding e Configurazione**: Sostituisce il pacchetto, il nome dell'app e la configurazione per permettere l'installazione side-by-side con l'app originale e configura la connessione ai servizi backend dedicati.
- **App Updater**: Indirizza il motore di aggiornamento integrato verso questo repository (`Lorenzo0010/nuvio-patch`) per ricevere automaticamente i nuovi aggiornamenti della versione Plus.
- **Download Personalizzati**: Consente all'utente di scegliere la cartella in cui salvare i download tramite un picker SAF (Storage Access Framework), migliorando la flessibilità dello storage.

L'interfaccia utente di navigazione (navbar) è allineata all'esperienza dell'app ufficiale e non include tab personalizzate in questa configurazione.

## Compilazione Locale
La compilazione avviene applicando le patch (`01`, `02`, `05`) sull'albero dei sorgenti originale tramite script locali, e producendo file APK universali e suddivisi per architettura (`arm64-v8a`, `armeabi-v7a`, `x86_64`, `x86`).
