# Window FX: Schritt für Schritt

[English](GUIDE.md) · **Deutsch** · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Plugin einbauen

Aus der Plugin-Registry:

```sh
dms plugins install windowFx
```

Oder klone das Repository in deinen DMS-Plugin-Ordner:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. Einschalten

Öffne Einstellungen → Plugins. Window FX steht in der Liste. Schalte es ein.

![Plugin-Liste mit Window FX](images/01-plugin-list.png)

Wenn es nicht auftaucht, klick auf dieser Seite auf „Scannen“ oder starte die Shell mit `dms restart` neu.

## 3. niri die Datei des Plugins lesen lassen

Das Plugin schreibt seine Animationen in `~/.config/niri/windowfx.kdl`. niri liest diese Datei nur, wenn deine Konfiguration sie einbindet. Trag diese Zeile ganz am Ende von `~/.config/niri/config.kdl` ein:

```kdl
include optional=true "windowfx.kdl"
```

Sie gehört ans Ende, weil ein Include überschreibt, was vor ihm steht. Hat deine Konfiguration einen eigenen `animations`-Block mit `window-close` oder `window-open`, setzen sich dann die Werte des Plugins durch. `optional=true` sorgt dafür, dass niri nicht klagt, solange die Datei noch nicht existiert; dafür braucht es niri 26.04 oder neuer.

niri übernimmt die Änderung, sobald du die Datei speicherst.

## 4. Eine Animation beim Schließen wählen

Klapp Window FX in der Plugin-Liste auf. Wähle unter „Animation beim Schließen“ eine der 13 Arten, zum Beispiel Scherben.

![Die Einstellungsseite mit der Liste der Arten](images/02-close-animation.png)

Öffne ein Terminal und schließ es wieder. Das Fenster zerspringt in Scherben, die sich drehen und aus dem Rahmen fallen.

![Ein Fenster zerspringt in Scherben](images/03-shatter.png)

„Dauer“ legt fest, wie lange es dauert, von 150 bis 3000 ms. Bei 600 ms wirkt es flott, bei 1500 ms kannst du zusehen.

## 5. Festlegen, wie Fenster aufgehen

„Animation beim Öffnen“ steht zu Beginn auf „Wie beim Schließen, rückwärts“: ein neues Fenster erscheint so, wie das letzte verschwunden ist, nur rückwärts abgespielt. Die Glut sammelt sich, die Scherben fliegen hoch und fügen sich zusammen. Solange die Animation beim Schließen auf „niri-Standard“ steht, überlässt das auch das Öffnen niri.

Du kannst fürs Öffnen auch eine andere Art wählen, „Zufall“, oder „niri-Standard“, wenn du für neue Fenster lieber die Animation von niri behältst. „Dauer beim Öffnen“ arbeitet wie die beim Schließen; 450 ms ist der Standard, weil ein neues Fenster schnell da sein soll.

## 6. Leuchtende Kanten

„Leuchtende Kanten“ lässt die Front des Feuers, die Risse zwischen den Scherben und die Fugen der Kacheln in deiner Akzentfarbe aufleuchten. Schalte es aus für schlichte Animationen ohne Licht.

![Leuchtende Risse in der Akzentfarbe](images/04-glow.png)

Die Farbe folgt dem Akzent von DMS: ändert sich der Akzent, leuchtet die nächste Animation in der neuen Farbe. „Röhre aus“ blitzt immer weiß auf.

## 7. Den Zufall entscheiden lassen (nach Wunsch)

Wähle „Zufall“ als Animation beim Schließen. Jedes Fenster bekommt dann seine eigene Art. Unter den Einstellungen erscheint eine Liste, „Der Zufall wählt aus diesen:“, in der du jede Art ein- oder ausschaltest.

![Die Auswahl für den Zufall](images/05-random.png)

Zu Beginn sind sechs Arten eingeschaltet: Glut, Scherben, Schmelzen, Signalstörung, Röhre aus und Code-Regen. Schaltest du alle aus, wird Glut genommen.

## 8. Nachbarn warten (niri mit hold-layout)

Schließt sich ein Fenster mitten in einer Reihe, schiebt niri die Fenster rechts davon sofort in die Lücke, und sie rutschen über die Animation, während sie noch läuft. Kennt dein niri die Option `hold-layout`, zeigt die Einstellungsseite den Schalter „Nachbarn warten“. Ist er ein, bleiben die Nachbarn stehen, bis die Schließ-Animation zu Ende ist, und rücken erst dann nach.

`hold-layout` gehört nicht zu niri, die Option stammt aus einem inoffiziellen Patch. Mit dem niri deiner Distribution bleibt der Schalter deshalb verborgen. Alles andere in dieser Anleitung funktioniert ohne ihn.

Probier es an einem Fenster, rechts von dem noch ein weiteres steht; schließt sich das letzte Fenster einer Reihe, rückt nichts nach.

Erscheint der Schalter nicht, hat dein niri die Option nicht. Das Plugin prüft das beim Start, indem es `niri validate` eine winzige Datei lesen lässt, die sie benutzt, und es schreibt die Option nie für ein niri, das sie ablehnen würde.

## 9. Die Animationen je Profil behalten (nach Wunsch)

Mit dem Plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles) trägst du `windowFx` unter „Im Profil mitgespeicherte Plugins“ ein. Jedes Profil behält dann seine eigenen Animationen, zum Beispiel ruhige für die Arbeit und Signalstörung für den Abend.

## 10. Per Skript steuern

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Die Arten heißen `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` und `blinds`.

Leg es auf eine Taste, unter niri:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Fehlersuche

### Fenster schließen sich wie immer

Die Include-Zeile aus Schritt 3 fehlt, oder „Animation beim Schließen“ steht auf „niri-Standard“. `ls ~/.config/niri/windowfx.kdl` zeigt, ob das Plugin seine Datei geschrieben hat.

### Meine eigenen Animationen aus config.kdl setzen sich durch

Die Include-Zeile steht über deinem `animations`-Block. Verschieb sie ans Ende der Datei.

### niri meldet einen Konfigurationsfehler, in dem `hold-layout` vorkommt

niri wurde durch eines ohne die Option ersetzt, und die Datei enthält sie noch von vorher. Sobald DMS läuft, prüft das Plugin erneut und schreibt die Datei ohne sie; niri lädt von selbst neu.

### „Nachbarn warten“ erscheint nicht

Das installierte niri kennt `hold-layout` nicht. Sobald es das tut, taucht der Schalter nach dem nächsten Start von DMS auf.

### Der Zufall zeigt immer dieselbe Art

In der Liste aus Schritt 7 ist nur eine Art eingeschaltet oder gar keine; dann wird Glut genommen.

### Die Animationen bleiben, nachdem ich das Plugin abgeschaltet habe

Das Plugin lässt `windowfx.kdl` liegen. Stell beide Animationen auf „niri-Standard“, bevor du es abschaltest, oder lösche die Datei.
