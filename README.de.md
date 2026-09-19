# Window FX

[English](README.md) · **Deutsch** · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Ein Plugin für [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell), das Fenstern unter niri eigene Animationen beim Schließen und Öffnen gibt: sie verbrennen, zerspringen in Scherben, schmelzen, stören wie ein kaputtes Signal oder gehen aus wie eine alte Röhre. Die Kanten leuchten dabei in deiner Akzentfarbe.

![Window FX](assets/screenshot.png)

Schritt für Schritt mit Bildern: [Anleitung zu Einbau und Einstellung](docs/GUIDE.de.md).

## Was es macht

niri kann ein Fenster beim Schließen und Öffnen mit einem eigenen Shader zeichnen. Das Plugin schreibt so einen Shader in `~/.config/niri/windowfx.kdl`, und niri lädt die Datei von selbst neu, sobald sie sich ändert. Eine neue Einstellung wirkt also beim nächsten Fenster, das sich schließt oder öffnet.

Es gibt 13 Arten:

| Art | Was passiert |
|---|---|
| Glut | das Fenster brennt entlang einer ausgefransten Front weg |
| Zerfall | grobes Korn verschwindet in zufälliger Reihenfolge |
| Verpixeln | die Blöcke werden größer und blenden dann aus |
| Scherben | das Fenster zerspringt in Scherben, die sich drehen und fallen |
| Schmelzen | schmale Spalten rutschen nach unten, jede in ihrem eigenen Tempo |
| Signalstörung | Risse, verschobene Farbkanäle und springende Blöcke, dann zerfällt es |
| Röhre aus | zu einer Linie gestaucht, dann zu einem Punkt, mit hellem Aufblitzen |
| Schneesturm | das Bild versinkt im Rauschen und zerfällt Korn für Korn |
| Scan | ein Strahl läuft nach unten und lässt ein Drahtgitter der Kanten zurück |
| Code-Regen | Spalten aus Zeichen laufen nach unten, dahinter bleibt nur Code |
| Strudel | das Fenster dreht sich um seine Mitte auf |
| Kacheln | die Kacheln schrumpfen in zufälliger Reihenfolge |
| Jalousie | waagerechte Lamellen schließen sich |

„Zufall“ wählt für jedes Fenster neu eine Art, aus einer Auswahl, die du selbst festlegst. Schließen und Öffnen haben jeweils eine eigene Dauer. Beim Öffnen läuft eine Art rückwärts: von Haus aus erscheint ein neues Fenster so, wie das letzte verschwunden ist, nur umgekehrt. Wählst du „niri-Standard“, überlässt das Plugin diese Animation niri.

„Leuchtende Kanten“ lässt Kanten, Risse und Fugen in der Akzentfarbe von DMS aufleuchten. Ändert sich der Akzent, schreibt das Plugin die Datei neu. „Röhre aus“ blitzt immer weiß auf, mit oder ohne diese Einstellung.

Wenn du das Plugin [Profiles](https://github.com/satoshoe-dev/dms-profiles) benutzt, trag `windowFx` unter Einstellungen → Plugins → Profiles → Im Profil mitgespeicherte Plugins ein, dann behält jedes Profil seine eigenen Animationen.

## Voraussetzungen

DankMaterialShell 1.6.1 oder neuer und niri 26.04 oder neuer. Die niri-Version braucht es für die Include-Zeile unten: `optional=true` kennt niri seit 26.04.

Das Plugin schreibt nur seine eigene Datei. niri liest sie, sobald deine niri-Konfiguration sie einbindet. Trag deshalb diese Zeile am Ende von `~/.config/niri/config.kdl` ein:

```kdl
include optional=true "windowfx.kdl"
```

Am Ende, weil ein Include überschreibt, was vor ihm steht; so setzen sich die Animationen des Plugins gegen die in deiner Hauptkonfiguration durch.

„Nachbarn warten“ braucht zusätzlich ein niri mit einem inoffiziellen Patch, mehr dazu unter [Nachbarn warten](#nachbarn-warten). Alles andere läuft mit dem normalen niri.

## Installation

Aus der Plugin-Registry:

```sh
dms plugins install windowFx
dms ipc call plugins enable windowFx
```

Das Plugin steht auch in DMS unter Einstellungen → Plugins → Durchsuchen. Oder direkt aus dem Repository:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
dms ipc call plugins enable windowFx
```

Wähle dann unter Einstellungen → Plugins → Window FX eine Animation beim Schließen. Bis dahin behält niri seine eigenen Animationen.

## Einstellungen

Einstellungen → Plugins → Window FX

| Einstellung | Standard |
|---|---|
| Animation beim Schließen | niri-Standard |
| Dauer | 600 ms |
| Nachbarn warten | aus (nur mit einem niri, das `hold-layout` kennt) |
| Animation beim Öffnen | Wie beim Schließen, rückwärts |
| Dauer beim Öffnen | 450 ms |
| Leuchtende Kanten | ein |
| Der Zufall wählt aus diesen | Glut, Scherben, Schmelzen, Signalstörung, Röhre aus, Code-Regen |

Beide Dauern reichen von 150 bis 3000 ms.

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Die Arten heißen `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` und `blinds`.

Eine Tastenbindung unter niri, die für die nächsten Fenster neu würfelt:

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Nachbarn warten

Wenn ein Fenster sich schließt, nimmt niri es sofort aus dem Layout. Die Fenster daneben rücken gleich in die Lücke und schieben sich über das schließende Fenster, während seine Animation noch läuft. Bei einem kurzen Ausblenden fällt das kaum auf; bei einer brennenden Kante oder fallenden Scherben deckt der Nachbar das meiste davon zu.

Ich habe dafür einen kleinen Patch für niri geschrieben, der `window-close` um die Option `hold-layout` ergänzt. Mit ihr beginnt alles, was das Entfernen in Gang setzt (Nachbarn rücken nach, die Ansicht scrollt, Spalten ändern ihre Größe), erst dann, wenn die Schließ-Animation zu Ende ist. Der Patch gehört nicht zu niri, und das niri deiner Distribution kennt die Option nicht. Ohne ein niri, das mit diesem Patch gebaut ist, bewirkt „Nachbarn warten“ nichts.

Der Patch für niri 26.04 liegt im Zweig [hold-layout-v26.04](https://github.com/satoshoe-dev/niri/tree/hold-layout-v26.04) meines niri-Forks. Gebaut wird er wie niri selbst, siehe dessen README.

Das Plugin prüft beim Start, ob das installierte niri die Option kennt: es lässt `niri validate` eine winzige Datei lesen, die sie benutzt. Kennt niri sie, erscheint auf der Einstellungsseite der Schalter „Nachbarn warten“; sonst bleibt er verborgen und das Plugin schreibt die Option nie, weil ein unverändertes niri die ganze Datei ablehnen würde.

## Abschalten

Schaltest du das Plugin ab, bleibt `windowfx.kdl` so, wie sie ist, und damit auch die letzten Animationen. Um zu den Animationen von niri zurückzukehren, stell vorher beide Animationen auf „niri-Standard“ oder lösche die Datei. Mit `optional=true` kommt niri mit einer fehlenden Datei zurecht.

## Übersetzungen

Die Einstellungsseite gibt es auf Deutsch, Spanisch, Französisch, Italienisch, Portugiesisch, Russisch, Japanisch und Chinesisch (vereinfacht) und sie folgt der in DMS eingestellten Sprache. Wenn eine Übersetzung falsch klingt, ist ein Pull Request willkommen.

## Hinweis

Dieses Plugin habe ich mit Hilfe von Claude (Anthropic) geschrieben und jede Änderung auf meinem eigenen niri-Schreibtisch getestet.

## Lizenz

MIT
