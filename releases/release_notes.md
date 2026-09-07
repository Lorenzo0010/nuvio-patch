## Novità in Nuvio Plus Mobile 0.4.14.9

### Selettore Sorgente Download Automatico e Filtri Avanzati
- **Selettore Sorgente nelle Impostazioni Nuvio Plus**: Nuova opzione dedicata in *Impostazioni Nuvio Plus* per configurare la sorgente di download automatico:
  - **Entrambi (Chi arriva prima)** (*Predefinito*): Scarica immediatamente dal primo flusso valido disponibile (addon o plugin repository che sia).
  - **Solo Addon (Torrent Cached / HTTP)**: Attende i risultati degli addon con priorità ai torrent in cache RealDebrid (~8s) e successiva ricerca su flussi HTTP (~15s), con fallback sui plugin se gli addon non rispondono.
  - **Solo Repository Plugin**: Scarica direttamente e tempestivamente dai plugin abilitati.
- **Filtro Addon e Filtro Repository**: Possibilità di filtrare la ricerca automatica selezionando un addon specifico o una repository plugin specifica, mantenendo l'opzione di default per ricercare su tutti gli addon o repository.

### Notifica di Stato in Tempo Reale
- **Report Live fin dal Click**: Non appena viene cliccato il pulsante di download, viene emessa una notifica di sistema Android persistente e aggiornata in tempo reale che documenta ogni fase operativa:
  - Ricerca dello stream per il film o episodio selezionato.
  - Verifica della disponibilità cache RealDebrid / Debrid.
  - Tentativo di avvio con il nome dello stream specifico e la categoria di priorità (Torrent Cached, Addon HTTP, Plugin).
  - Transizione automatica alla barra di avanzamento del download non appena lo stream si aggancia con successo.

### Riorganizzazione UI Download in Nuvio Plus
- **Voci Dedicate nelle Impostazioni**: Spostati i due pulsanti in precedenza presenti in alto a destra nella schermata Download (icona cartella e impostazioni) direttamente all'interno della pagina *Impostazioni Nuvio Plus*:
  - **Apri cartella download**: Apre il gestore file di sistema sul percorso dei file scaricati.
  - **Posizione di download**: Consente di scegliere la directory di destinazione personalizzata tramite il selettore di sistema (Storage Access Framework su Android).
  - **Ripristina percorso predefinito**: Disponibile se è impostato un percorso personalizzato.

### Standard di Rilascio e Firme
- Versione conforme alla regola di versionamento: `0.4.14.9` (senza tag o suffissi hash).
- APK firmati con il keystore persistente `nuvio-release.keystore`.
