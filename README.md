# Window FX

**English** · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

A plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) that gives windows on niri their own animations when they close and open: they burn away, break into shards, melt, glitch or switch off like an old tube. The edges light up in your accent color.

![Window FX](assets/screenshot.png)

Step by step with pictures: [installation and setup guide](docs/GUIDE.md).

## What it does

niri can draw a closing or opening window with a custom shader. The plugin writes such a shader into `~/.config/niri/windowfx.kdl`, and niri reloads the file on its own as soon as it changes. A new setting takes effect with the next window that closes or opens.

There are 13 kinds:

| Kind | What happens |
|---|---|
| Ember | the window burns away along a ragged front |
| Dissolve | coarse grain disappears in random order |
| Pixelate | the blocks grow, then fade |
| Shatter | the window breaks into shards that spin and fall |
| Melt | thin columns slide down, each at its own speed |
| Glitch | tears, split color channels and jumping blocks, then it breaks up |
| Tube off | squeezed to a line, then to a dot, with a bright flash |
| Snowstorm | the picture drowns in static and falls apart grain by grain |
| Scan | a beam runs down and leaves a wireframe of the edges behind |
| Code rain | columns of glyphs run down, behind them only code is left |
| Swirl | the window winds up around its center |
| Squares | the tiles shrink in random order |
| Blinds | horizontal slats close |

"Random" picks a kind for every window anew, from a selection you set yourself. Closing and opening each have their own duration. Opening plays a kind backwards: by default a new window appears the way the last one disappeared, only in reverse. Pick "niri default" and the plugin leaves that animation to niri.

"Glowing edges" lets edges, cracks and seams light up in the accent color of DMS. When the accent changes, the plugin writes the file again. Tube off always flashes white, with or without the setting.

If you use the [Profiles](https://github.com/satoshoe-dev/dms-profiles) plugin, enter `windowFx` under Settings → Plugins → Profiles → Plugins saved with a profile, and every profile keeps its own animations.

## Requirements

DankMaterialShell 1.6.1 or newer and niri 26.04 or newer. The niri version matters for the include line below: niri knows `optional=true` since 26.04.

The plugin only writes its own file. niri reads it once your niri config includes it, so add this line at the end of `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

At the end, because an include overrides what comes before it; that way the plugin's animations win over the ones in your main config.

"Neighbours wait" also needs a niri built with an unofficial patch, see [Neighbours wait](#neighbours-wait). Everything else works with a stock niri.

## Installation

From the plugin registry:

```sh
dms plugins install windowFx
dms ipc call plugins enable windowFx
```

It is also listed in DMS under Settings → Plugins → Browse. To install from the repository instead:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
dms ipc call plugins enable windowFx
```

Then pick a close animation in Settings → Plugins → Window FX. Until you do, niri keeps its own animations.

## Settings

Settings → Plugins → Window FX

| Setting | Default |
|---|---|
| Close animation | niri default |
| Duration | 600 ms |
| Neighbours wait | off (only with a niri that knows `hold-layout`) |
| Open animation | Like closing, backwards |
| Open duration | 450 ms |
| Glowing edges | on |
| Random picks from these | Ember, Shatter, Melt, Glitch, Tube off, Code rain |

Both durations go from 150 to 3000 ms.

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

The kinds are called `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` and `blinds`.

A keybind in niri that throws the dice for the next windows:

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Neighbours wait

When a window closes, niri takes it out of the layout right away. The windows next to it start moving into the gap at once and slide over the closing window while its animation is still running. With a short fade that hardly shows; with a burning edge or falling shards the neighbour covers most of it.

I wrote a small patch for niri that adds the option `hold-layout` to `window-close`. With it, everything the removal sets in motion (neighbours sliding in, the view scrolling, columns resizing) starts only when the close animation has ended. The patch is not part of niri, and the niri from your distribution does not know the option. Without a niri built with this patch, "Neighbours wait" has no effect.

The plugin checks at start whether the installed niri knows the option, by letting `niri validate` read a tiny file that uses it. If niri knows it, the switch "Neighbours wait" appears on the settings page; if not, it stays hidden and the plugin never writes the option, because a stock niri would reject the whole file.

## Switching it off

Switching the plugin off leaves `windowfx.kdl` as it is, so the last animations stay. To go back to niri's own animations, set both animations to "niri default" first, or delete the file. With `optional=true` a missing file is fine for niri.

## Translations

The settings page is available in German, Spanish, French, Italian, Portuguese, Russian, Japanese and Simplified Chinese and follows the language set in DMS. If a translation reads wrong, a pull request is welcome.

## Note

I wrote this plugin with help from Claude (Anthropic) and tested every change on my own niri desktop.

## License

MIT
