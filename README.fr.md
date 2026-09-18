# Window FX

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · **Français** · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh_CN.md)

Un plugin pour [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) qui donne aux fenêtres de niri leurs propres animations à la fermeture et à l'ouverture : elles se consument, se brisent en éclats, fondent, se brouillent ou s'éteignent comme un vieux tube. Les bords s'allument dans ta couleur d'accent.

![Window FX](assets/screenshot.png)

Pas à pas avec des images : [guide d'installation et de réglage](docs/GUIDE.fr.md).

## Ce que ça fait

niri peut dessiner une fenêtre qui se ferme ou s'ouvre avec un shader personnalisé. Le plugin écrit un tel shader dans `~/.config/niri/windowfx.kdl`, et niri recharge le fichier de lui-même dès qu'il change. Un nouveau réglage agit dès la prochaine fenêtre qui se ferme ou s'ouvre.

Il y a 13 animations :

| Animation | Ce qui se passe |
|---|---|
| Braise | la fenêtre se consume le long d'un front irrégulier |
| Dissolution | un grain grossier disparaît dans un ordre aléatoire |
| Pixelisation | les blocs grossissent, puis s'effacent |
| Éclats | la fenêtre se brise en éclats qui tournent et tombent |
| Fonte | de fines colonnes glissent vers le bas, chacune à sa vitesse |
| Glitch | déchirures, canaux de couleur décalés et blocs qui sautent, puis tout se défait |
| Tube éteint | écrasée en une ligne, puis en un point, avec un éclair |
| Neige | l'image se noie dans la neige et se défait grain par grain |
| Balayage | un faisceau descend et laisse derrière lui les contours en fil de fer |
| Pluie de code | des colonnes de signes descendent, derrière elles il ne reste que du code |
| Tourbillon | la fenêtre s'enroule autour de son centre |
| Carreaux | les carreaux rétrécissent dans un ordre aléatoire |
| Store | des lames horizontales se ferment |

« Au hasard » choisit une animation pour chaque fenêtre, parmi une sélection que tu fixes toi-même. La fermeture et l'ouverture ont chacune leur durée. L'ouverture joue une animation à l'envers : par défaut, une nouvelle fenêtre apparaît comme la dernière a disparu, simplement en sens inverse. Choisis « Par défaut de niri » et le plugin laisse cette animation à niri.

« Bords lumineux » fait s'allumer les bords, les fissures et les jointures dans la couleur d'accent de DMS. Quand l'accent change, le plugin réécrit le fichier. Tube éteint fait toujours un éclair blanc, avec ou sans ce réglage.

Si tu utilises le plugin [Profiles](https://github.com/21Rebel/dms-profiles), saisis `windowFx` dans Paramètres → Plugins → Profiles → Plugins enregistrés avec le profil, et chaque profil garde ses propres animations.

## Prérequis

DankMaterialShell 1.6.1 ou plus récent et niri 26.04 ou plus récent.

Le plugin n'écrit que son propre fichier. niri le lit dès que ta configuration niri l'inclut, donc ajoute cette ligne à la fin de `~/.config/niri/config.kdl` :

```kdl
include optional=true "windowfx.kdl"
```

À la fin, parce qu'un include remplace ce qui vient avant lui ; ainsi les animations du plugin l'emportent sur celles de ta configuration principale.

## Installation

```sh
git clone https://github.com/21Rebel/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
dms ipc call plugins enable windowFx
```

Choisis ensuite une animation de fermeture dans Paramètres → Plugins → Window FX. Tant que tu ne le fais pas, niri garde ses propres animations.

## Paramètres

Paramètres → Plugins → Window FX

| Paramètre | Par défaut |
|---|---|
| Animation de fermeture | Par défaut de niri |
| Durée | 600 ms |
| Les voisines attendent | désactivé (seulement avec un niri qui connaît `hold-layout`) |
| Animation d'ouverture | Comme la fermeture, à l'envers |
| Durée d'ouverture | 450 ms |
| Bords lumineux | activé |
| Le hasard choisit parmi celles-ci | Braise, Éclats, Fonte, Glitch, Tube éteint, Pluie de code |

Les deux durées vont de 150 à 3000 ms.

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

Les animations s'appellent `ember`, `dissolve`, `pixel`, `shatter`, `melt`, `glitch`, `crt`, `snow`, `scan`, `code`, `swirl`, `squares` et `blinds`.

Un raccourci niri qui relance le hasard pour les prochaines fenêtres :

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## Les voisines attendent

Quand une fenêtre se ferme, niri la retire aussitôt de la disposition. Les fenêtres voisines commencent tout de suite à combler le vide et glissent par-dessus la fenêtre qui se ferme pendant que son animation tourne encore. Avec un court fondu, ça se voit à peine ; avec un bord qui brûle ou des éclats qui tombent, la voisine en cache la plus grande partie.

Le patch qui change cela est petit : une nouvelle option `hold-layout` dans `window-close`. Avec elle, tout ce que le retrait met en mouvement (les voisines qui glissent, la vue qui défile, les colonnes qui changent de taille) ne démarre qu'une fois l'animation de fermeture terminée. Il est proposé à niri sous forme de pull request.

Au démarrage, le plugin vérifie si le niri installé connaît l'option, en faisant lire à `niri validate` un petit fichier qui l'utilise. Si niri la connaît, l'interrupteur « Les voisines attendent » apparaît dans la page de paramètres ; sinon il reste caché et le plugin n'écrit jamais l'option, parce qu'un niri d'origine rejetterait tout le fichier.

## Le désactiver

Désactiver le plugin laisse `windowfx.kdl` tel quel, les dernières animations restent donc. Pour revenir aux animations de niri, mets d'abord les deux animations sur « Par défaut de niri », ou supprime le fichier. Avec `optional=true`, un fichier absent ne gêne pas niri.

## Traductions

La page de paramètres existe en allemand, espagnol, français, italien, portugais, russe, japonais et chinois simplifié, et elle suit la langue réglée dans DMS. Si une traduction sonne faux, une pull request est bienvenue.

## Remarque

J'ai écrit ce plugin avec l'aide de Claude (Anthropic) et j'ai testé chaque changement sur mon propre bureau niri.

## Licence

MIT
