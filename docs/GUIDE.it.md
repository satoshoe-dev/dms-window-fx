# Window FX: passo per passo

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · **Italiano** · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Installare il plugin

Dal registro dei plugin:

```sh
dms plugins install windowFx
```

Oppure clona il repository nella tua cartella dei plugin DMS:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. Attivarlo

Apri Impostazioni → Plugin. Window FX compare nell'elenco. Attivalo.

![Elenco dei plugin con Window FX](images/01-plugin-list.png)

Se non compare, clicca su «Scansiona» in quella pagina oppure riavvia la shell con `dms restart`.

## 3. Far leggere a niri il file del plugin

Il plugin scrive le sue animazioni in `~/.config/niri/windowfx.kdl`. niri legge quel file solo se la tua configurazione lo include. Aggiungi questa riga proprio alla fine di `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

Va alla fine perché un include sovrascrive ciò che viene prima. Se la tua configurazione ha un suo blocco `animations` con `window-close` o `window-open`, prevalgono così i valori del plugin. `optional=true` evita un errore finché il file non esiste ancora; serve niri 26.04 o più recente.

niri recepisce la modifica appena salvi il file.

## 4. Scegliere un'animazione di chiusura

Espandi Window FX nell'elenco dei plugin. In "Animazione di chiusura" scegli una delle 13 animazioni, per esempio Frantumi.

![La pagina delle impostazioni con l'elenco delle animazioni](images/02-close-animation.png)

Apri un terminale e chiudilo di nuovo. La finestra si rompe in frammenti che ruotano e cadono fuori dal riquadro.

![Una finestra che va in frantumi](images/03-shatter.png)

"Durata" imposta quanto dura, da 150 a 3000 ms. A 600 ms sembra rapida, a 1500 ms la puoi guardare.

## 5. Scegliere come si aprono le finestre

"Animazione di apertura" parte da "Come la chiusura, al contrario": una nuova finestra compare come l'ultima è sparita, riprodotta all'indietro. Le braci si riuniscono, i frammenti risalgono e si ricompongono. Finché l'animazione di chiusura è "Predefinita di niri", anche l'apertura resta a niri.

Puoi anche scegliere un'altra animazione per l'apertura, "Casuale", oppure "Predefinita di niri" se preferisci tenere l'animazione di niri per le nuove finestre. "Durata di apertura" funziona come quella di chiusura; 450 ms è il valore predefinito, perché una nuova finestra deve esserci presto.

## 6. Bordi luminosi

"Bordi luminosi" fa illuminare nel tuo colore di accento il fronte del fuoco, le crepe tra i frammenti e le giunture dei quadrati. Spegnilo per animazioni senza luce.

![Crepe luminose nel colore di accento](images/04-glow.png)

Il colore segue l'accento di DMS: quando l'accento cambia, l'animazione successiva brilla nel nuovo colore. Tubo spento fa sempre un lampo bianco.

## 7. Lasciar decidere al caso (facoltativo)

Scegli "Casuale" come animazione di chiusura. Ogni finestra riceve allora un'animazione sua. Sotto le impostazioni compare un elenco, "Il caso sceglie tra queste:", dove accendi o spegni ogni animazione.

![La selezione per la modalità casuale](images/05-random.png)

All'inizio sono accese sei animazioni: Brace, Frantumi, Scioglimento, Glitch, Tubo spento e Pioggia di codice. Se le spegni tutte, viene usata Brace.

## 8. Le vicine aspettano (niri con hold-layout)

Quando si chiude una finestra in mezzo a una fila, niri sposta subito nello spazio libero le finestre alla sua destra, e queste scivolano sotto l'animazione mentre è ancora in corso. Se il tuo niri conosce l'opzione `hold-layout`, la pagina delle impostazioni mostra l'interruttore "Le vicine aspettano". Se è acceso, le vicine restano dove sono finché l'animazione di chiusura non è finita, e solo dopo si spostano.

`hold-layout` non fa parte di niri; l'opzione viene da una patch non ufficiale. Con il niri della tua distribuzione l'interruttore resta quindi nascosto. Tutto il resto di questa guida funziona anche senza.

Provalo su una finestra che ne ha un'altra alla sua destra; quando si chiude l'ultima finestra di una fila, non arriva nulla a riempire lo spazio.

Se l'interruttore non compare, il tuo niri non ha l'opzione. Il plugin lo controlla all'avvio facendo leggere a `niri validate` un file minuscolo che la usa, e non scrive mai l'opzione per un niri che la rifiuterebbe.

## 9. Tenere le animazioni per profilo (facoltativo)

Con il plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles), inserisci `windowFx` in "Plugin salvati con il profilo". Ogni profilo tiene allora le sue animazioni, per esempio quelle calme per il lavoro e Glitch per la sera.

## 10. Comandarlo da script

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Le animazioni si chiamano `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` e `blinds`.

Mettilo su un tasto, in niri:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Risoluzione dei problemi

### Le finestre si chiudono ancora come sempre

Manca la riga include del passo 3, oppure "Animazione di chiusura" è su "Predefinita di niri". `ls ~/.config/niri/windowfx.kdl` mostra se il plugin ha scritto il suo file.

### Prevalgono le mie animazioni in config.kdl

La riga include sta sopra il tuo blocco `animations`. Spostala alla fine del file.

### niri mostra un errore di configurazione che nomina `hold-layout`

niri è stato sostituito da uno senza l'opzione, e il file la contiene ancora. Appena DMS è in esecuzione, il plugin controlla di nuovo e riscrive il file senza; niri ricarica da solo.

### "Le vicine aspettano" non compare

Il niri installato non conosce `hold-layout`. L'interruttore compare al prossimo avvio di DMS quando lo conosce.

### Il caso mostra sempre la stessa animazione

Nell'elenco del passo 7 è accesa una sola animazione, oppure nessuna; in quel caso viene usata Brace.

### Le animazioni restano dopo aver spento il plugin

Il plugin lascia `windowfx.kdl` dov'è. Imposta entrambe le animazioni su "Predefinita di niri" prima di spegnerlo, oppure cancella il file.
