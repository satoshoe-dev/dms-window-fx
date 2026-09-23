# Window FX: step by step

**English** · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · [简体中文](GUIDE.zh_CN.md)

## 1. Install the plugin

From the plugin registry:

```sh
dms plugins install windowFx
```

Or clone the repository into your DMS plugin folder:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. Enable it

Open Settings → Plugins. Window FX shows up in the list. Switch it on.

![Plugin list with Window FX](images/01-plugin-list.png)

If it does not appear, click "Scan" on that page or restart the shell with `dms restart`.

## 3. Let niri read the plugin's file

The plugin writes its animations into `~/.config/niri/windowfx.kdl`. niri only reads that file if your config includes it. Add this line at the very end of `~/.config/niri/config.kdl`:

```kdl
include optional=true "windowfx.kdl"
```

It belongs at the end because an include overrides what comes before it. If your config has its own `animations` block with `window-close` or `window-open`, the plugin's values then win. `optional=true` keeps niri happy while the file does not exist yet; it needs niri 26.04 or newer.

niri picks the change up as soon as you save the file.

## 4. Pick a close animation

Expand Window FX in the plugin list. Under "Close animation" choose one of the 13 kinds, for example Shatter.

![The settings page with the list of kinds](images/02-close-animation.png)

Open a terminal and close it again. The window breaks into shards that spin and fall out of the frame.

![A window breaking into shards](images/03-shatter.png)

"Duration" sets how long it takes, from 150 to 3000 ms. At 600 ms it feels quick, at 1500 ms you can watch it.

## 5. Choose how windows open

"Open animation" starts at "Like closing, backwards": a new window appears the way the last one disappeared, played in reverse. The embers come together, the shards fly up and join. As long as the close animation is "niri default", this leaves opening to niri as well.

You can also pick another kind for opening, "Random", or "niri default" if you would rather keep niri's own animation for new windows. "Open duration" works like the one for closing; 450 ms is the default, because a new window should be there quickly.

## 6. Glowing edges

"Glowing edges" lets the front of the fire, the cracks between the shards and the seams of the tiles light up in your accent color. Switch it off for plain animations without light.

![Glowing cracks in the accent color](images/04-glow.png)

The color follows the DMS accent: when the accent changes, the next animation glows in the new color. Tube off always flashes white.

## 7. Let chance decide (optional)

Choose "Random" as the close animation. Every window then gets a kind of its own. Below the settings a list appears, "Random picks from these:", where you switch each kind on or off.

![The selection for the random mode](images/05-random.png)

Six kinds are on at the start: Ember, Shatter, Melt, Glitch, Tube off and Code rain. If you switch all of them off, Ember is used.

## 8. Neighbours wait (niri with hold-layout)

When a window in the middle of a row closes, niri moves the windows to its right into the gap right away, and they slide in underneath the animation while it is still running. If your niri knows the option `hold-layout`, the settings page shows the switch "Neighbours wait". With it on, the neighbours stay where they are until the close animation has ended, and only then move over.

`hold-layout` is not part of niri. It comes from an unofficial patch, so with the niri from your distribution the switch stays hidden. Everything else in this guide works without it.

Try it on a window that has another one to its right; when the last window of a row closes, nothing moves in.

If the switch does not appear, your niri does not have the option. The plugin checks that at start by letting `niri validate` read a tiny file that uses it, and it never writes the option for a niri that would reject it.

## 9. Keep the animations per profile (optional)

With the [Profiles](https://github.com/satoshoe-dev/dms-profiles) plugin, enter `windowFx` under "Plugins saved with a profile". Every profile then keeps its own animations, for example calm ones for work and Glitch for the evening.

## 10. Script it

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

The kinds are called `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` and `blinds`.

Put it on a key, in niri:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Troubleshooting

### Windows still close the way they always did

The include line from step 3 is missing, or "Close animation" is set to "niri default". `ls ~/.config/niri/windowfx.kdl` shows whether the plugin has written its file.

### My own animations in config.kdl win

The include line is above your `animations` block. Move it to the end of the file.

### niri shows a config error that mentions `hold-layout`

niri was replaced by one without the option, and the file still holds it from before. As soon as DMS is running, the plugin checks again and writes the file without it; niri reloads on its own.

### "Neighbours wait" does not appear

The installed niri does not know `hold-layout`. The switch shows up after the next start of DMS once it does.

### Random always shows the same kind

Only one kind is switched on in the list from step 7, or none at all; then Ember is used.

### The animations stay after I switched the plugin off

The plugin leaves `windowfx.kdl` where it is. Set both animations to "niri default" before you switch it off, or delete the file.
