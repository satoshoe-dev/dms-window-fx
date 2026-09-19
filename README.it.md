# Window FX

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · **Italiano** · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Un plugin per [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) che dà alle finestre su niri le loro animazioni di chiusura e di apertura: bruciano, vanno in frantumi, si sciolgono, si disturbano o si spengono come un vecchio tubo catodico. I bordi si illuminano nel tuo colore di accento.

![Window FX](assets/screenshot.png)

Passo per passo con immagini: [guida all'installazione e alla configurazione](docs/GUIDE.it.md).

## Cosa fa

niri può disegnare una finestra che si chiude o si apre con uno shader personalizzato. Il plugin scrive uno shader del genere in `~/.config/niri/windowfx.kdl`, e niri ricarica il file da solo appena cambia. Una nuova impostazione vale dalla prossima finestra che si chiude o si apre.

Ci sono 13 animazioni:

| Animazione | Cosa succede |
|---|---|
| Brace | la finestra brucia lungo un fronte irregolare |
| Dissolvenza | una grana grossa sparisce in ordine casuale |
| Pixel | i blocchi crescono, poi svaniscono |
| Frantumi | la finestra si rompe in frammenti che ruotano e cadono |
| Scioglimento | sottili colonne scivolano in basso, ognuna alla sua velocità |
| Glitch | strappi, canali di colore sfasati e blocchi che saltano, poi si disfa |
| Tubo spento | schiacciata in una linea, poi in un punto, con un lampo |
| Neve | l'immagine affoga nel rumore e si disfa grano per grano |
| Scansione | un raggio scende e lascia dietro di sé i contorni in fil di ferro |
| Pioggia di codice | colonne di caratteri scendono, dietro di loro resta solo codice |
| Vortice | la finestra si avvolge attorno al suo centro |
| Quadrati | i quadrati si rimpiccioliscono in ordine casuale |
| Veneziana | lamelle orizzontali si chiudono |

"Casuale" sceglie un'animazione per ogni finestra, da una selezione che decidi tu. Chiusura e apertura hanno ciascuna la propria durata. L'apertura riproduce un'animazione al contrario: di norma una nuova finestra compare come l'ultima è sparita, solo all'indietro. Scegli "Predefinita di niri" e il plugin lascia quell'animazione a niri.

"Bordi luminosi" fa illuminare bordi, crepe e giunture nel colore di accento di DMS. Quando l'accento cambia, il plugin riscrive il file. Tubo spento fa sempre un lampo bianco, con o senza questa impostazione.

Se usi il plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), inserisci `windowFx` in Impostazioni → Plugin → Profiles → Plugin salvati con il profilo, e ogni profilo tiene le sue animazioni.

## Requisiti

DankMaterialShell 1.6.1 o più recente e niri 26.04 o più recente. La versione di niri serve per la riga include qui sotto: niri conosce `optional=true` dalla 26.04.

Il plugin scrive solo il proprio file. niri lo legge quando la tua configurazione di niri lo include, quindi aggiungi questa riga alla fine di `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

Alla fine, perché un include sovrascrive ciò che viene prima; così le animazioni del plugin prevalgono su quelle della tua configurazione principale.

"Le vicine aspettano" richiede in più un niri con una patch non ufficiale, vedi più sotto la sezione "Le vicine aspettano". Tutto il resto funziona con un niri normale.

## Installazione

Dal registro dei plugin:

```sh
dms plugins install windowFx
dms ipc call plugins enable windowFx
```

Si trova anche in DMS in Impostazioni → Plugin → Sfoglia. Per installarlo dal repository:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
dms ipc call plugins enable windowFx
```

Poi scegli un'animazione di chiusura in Impostazioni → Plugin → Window FX. Finché non lo fai, niri tiene le sue animazioni.

## Impostazioni

Impostazioni → Plugin → Window FX

| Impostazione | Predefinito |
|---|---|
| Animazione di chiusura | Predefinita di niri |
| Durata | 600 ms |
| Le vicine aspettano | spento (solo con un niri che conosce `hold-layout`) |
| Animazione di apertura | Come la chiusura, al contrario |
| Durata di apertura | 450 ms |
| Bordi luminosi | acceso |
| Il caso sceglie tra queste | Brace, Frantumi, Scioglimento, Glitch, Tubo spento, Pioggia di codice |

Entrambe le durate vanno da 150 a 3000 ms.

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Le animazioni si chiamano `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` e `blinds`.

Una scorciatoia in niri che rilancia il caso per le prossime finestre:

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Le vicine aspettano

Quando una finestra si chiude, niri la toglie subito dal layout. Le finestre accanto cominciano subito a occupare lo spazio e scivolano sopra la finestra che si chiude mentre la sua animazione è ancora in corso. Con una breve dissolvenza si nota appena; con un bordo che brucia o frammenti che cadono, la vicina ne copre gran parte.

Ho scritto una piccola patch per niri che aggiunge l'opzione `hold-layout` a `window-close`. Con essa, tutto ciò che la rimozione mette in moto (le vicine che scivolano, la vista che scorre, le colonne che cambiano misura) parte solo quando l'animazione di chiusura è finita. La patch non fa parte di niri, e il niri della tua distribuzione non conosce l'opzione. Senza un niri compilato con questa patch, "Le vicine aspettano" non ha effetto.

All'avvio il plugin controlla se il niri installato conosce l'opzione, facendo leggere a `niri validate` un file minuscolo che la usa. Se niri la conosce, nella pagina delle impostazioni compare l'interruttore "Le vicine aspettano"; altrimenti resta nascosto e il plugin non scrive mai l'opzione, perché un niri standard rifiuterebbe l'intero file.

## Spegnerlo

Spegnere il plugin lascia `windowfx.kdl` com'è, quindi le ultime animazioni restano. Per tornare alle animazioni di niri, imposta prima entrambe le animazioni su "Predefinita di niri", oppure cancella il file. Con `optional=true` un file mancante non disturba niri.

## Traduzioni

La pagina delle impostazioni è disponibile in tedesco, spagnolo, francese, italiano, portoghese, russo, giapponese e cinese semplificato e segue la lingua impostata in DMS. Se una traduzione suona male, una pull request è benvenuta.

## Nota

Ho scritto questo plugin con l'aiuto di Claude (Anthropic) e ho provato ogni modifica sulla mia scrivania niri.

## Licenza

MIT
