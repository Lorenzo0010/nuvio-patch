## Novità in Nuvio Plus Mobile 0.4.14.8

### Attesa e Priorità Addon per il Download Automatico
- **Attesa dei Risultati degli Addon**: Il download automatico attende il completamento del caricamento di tutti gli addon di stream (inclusa la verifica cache Debrid) prima di determinare la sorgente.
- **Priorità al Primo Stream degli Addon**: Viene preferito e tentato per primo lo stream fornito dagli addon (secondo l'ordine di priorità degli addon dell'utente).
- **Transizione ai Plugin condizionata**: Si procede con i risultati dei plugin solo ed esclusivamente se gli addon non forniscono risultati o se tutti i loro stream falliscono in partenza.

### Fallback Automatico su Fallimento in Partenza
- **Monitoraggio Avvio Stream**: Se un download fallisce nella fase iniziale ("in partenza", es. errore di connessione, 403/404 o stream non raggiungibile), l'errore viene intercettato nei primi secondi.
- **Fallback Sequenziale**: L'elemento fallito viene rimosso e il sistema tenta immediatamente lo stream successivo della lista dei candidati.
- **Arresto al Successo**: Non appena uno stream inizia a scaricare dati con successo, il ciclo di fallback si ferma.

### Notifiche di Fallimento
- **Canale Notifiche ad Alta Priorità**: Introdotto su Android il canale `downloads_alerts` ("Avvisi Download") con `IMPORTANCE_HIGH`, suono e vibrazione.
- **Notifiche In-App e di Sistema**: Se un download fallisce o tutti gli stream risultano non disponibili, viene mostrato un Toast e inviata una notifica di sistema Android ad alta priorità.

### Standard di Rilascio e Firme
- Versione conforme alla regola di versionamento: `0.4.14.8` (senza tag o suffissi hash).
- APK firmati con il keystore persistente `nuvio-release.keystore`.
