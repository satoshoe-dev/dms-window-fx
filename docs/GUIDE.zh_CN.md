# Window FX: 分步说明

[English](GUIDE.md) · [Deutsch](GUIDE.de.md) · [Español](GUIDE.es.md) · [Français](GUIDE.fr.md) · [Italiano](GUIDE.it.md) · [Português](GUIDE.pt.md) · [Русский](GUIDE.ru.md) · [日本語](GUIDE.ja.md) · **简体中文**

## 1. 安装插件

从插件注册表安装：

```sh
dms plugins install windowFx
```

或者把仓库克隆到 DMS 的插件目录:

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
```

## 2. 打开它

打开 设置 → 插件。列表里会有 Window FX，把它打开。

![插件列表里的 Window FX](images/01-plugin-list.png)

如果没出现，点这个页面上的“扫描”，或者用 `dms restart` 重启 shell。

## 3. 让 niri 读取插件的文件

插件把动画写进 `~/.config/niri/windowfx.kdl`。只有你的配置 include 了这个文件，niri 才会读它。把这一行加到 `~/.config/niri/config.kdl` 的最末尾:

```kdl
include optional=true "windowfx.kdl"
```

放在末尾，是因为 include 会覆盖它前面的内容。如果你的配置里有自己的 `animations` 块，里面带 `window-close` 或 `window-open`，那么插件的值会优先。有 `optional=true`，文件还不存在时 niri 也不会出错；这需要 niri 26.04 或更新版本。

保存文件后 niri 立刻生效。

## 4. 选一个关闭动画

在插件列表里展开 Window FX。在“关闭动画”里从 13 种里选一种，比如“碎裂”。

![打开了效果列表的设置页面](images/02-close-animation.png)

打开一个终端，再把它关掉。窗口会裂成碎片，旋转着掉出窗口的范围。

![正在碎裂的窗口](images/03-shatter.png)

“时长”决定它持续多久，可以设在 150 到 3000 ms 之间。600 ms 感觉很快，1500 ms 就能看清楚。

## 5. 选择窗口怎样打开

“打开动画”一开始是“和关闭一样，倒着放”: 新窗口出现的方式，就是上一个窗口消失的方式倒过来。余烬聚拢起来，碎片飞上去拼合。只要关闭动画还是“niri 默认”，打开也同样交给 niri。

打开时也可以选别的效果、“随机”，或者如果你想让新窗口保留 niri 自己的动画，就选“niri 默认”。“打开时长”和关闭的时长一样用；默认是 450 ms，因为新窗口应该快点出来。

## 6. 发光边缘

“发光边缘”让火线的前沿、碎片之间的裂缝和方块的接缝用你的强调色发光。想要不带光的朴素动画，就把它关掉。

![用强调色发光的裂缝](images/04-glow.png)

颜色跟随 DMS 的强调色: 强调色一变，下一次动画就用新颜色发光。显像管关机总是闪白光。

## 7. 交给随机 (可选)

把关闭动画选成“随机”。每个窗口就会得到自己的效果。设置下方会出现一个列表“随机从这些里面选:”，可以逐个打开或关闭每种效果。

![随机模式的候选](images/05-random.png)

一开始打开的有六种: 余烬、碎裂、融化、故障、显像管关机和代码雨。如果全部关掉，就用余烬。

## 8. 相邻窗口等待 (带 hold-layout 的 niri)

一行中间的窗口关闭时，niri 会立刻把它右边的窗口移进空位，这些窗口会滑到还在播放的动画上面。如果你的 niri 认识 `hold-layout` 这个选项，设置页面上会出现“相邻窗口等待”这个开关。打开后，相邻的窗口会停在原处，直到关闭动画结束，然后才移过来。

`hold-layout` 不是 niri 自带的选项，而是来自一个非官方补丁。所以用发行版里的 niri 时，这个开关不会出现。本指南的其余内容不需要它也能用。

在右边还有别的窗口的窗口上试试；一行最后一个窗口关闭时，没有窗口会移进来。

如果开关没出现，说明你的 niri 没有这个选项。插件启动时会让 `niri validate` 读一个用了这个选项的小文件来检查，对不认识它的 niri，插件从不写这个选项。

## 9. 按配置保留动画 (可选)

如果你在用 [Profiles](https://github.com/satoshoe-dev/dms-profiles) 插件，在“随配置保存的插件”中填入 `windowFx`。每个配置就会保留自己的动画，比如工作时用安静的效果，晚上用故障。

## 10. 用脚本控制

```sh
dms ipc call windowFx kind melt      # close animation: a kind, random or default
dms ipc call windowFx open random    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

各种效果的名字是 `ember`、`dissolve`、`pixel`、`shatter`、`melt`、`glitch`、`crt`、`snow`、`scan`、`code`、`swirl`、`squares` 和 `blinds`。

在 niri 里绑到一个键上:

```kdl
binds {
    Mod+Shift+W hotkey-overlay-title="Window FX: random close animation" { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## 排查

### 窗口关闭的样子和以前一样

缺了第 3 步里的 include 行，或者“关闭动画”设成了“niri 默认”。用 `ls ~/.config/niri/windowfx.kdl` 可以看出插件有没有写出它的文件。

### config.kdl 里我自己的动画占了上风

include 行在你的 `animations` 块上面。把它移到文件末尾。

### niri 报出一个提到 `hold-layout` 的配置错误

niri 被换成了没有这个选项的版本，而文件里还留着之前写的选项。DMS 一运行，插件就会重新检查，写出不带这个选项的文件；niri 会自己重新读取。

### “相邻窗口等待”没有出现

装着的 niri 不认识 `hold-layout`。换成认识它的 niri 后，下次启动 DMS 时开关就会出现。

### 随机总是出同一种效果

第 7 步的列表里只打开了一种，或者一种也没开；一种也没开时就用余烬。

### 关掉插件后动画还在

插件会把 `windowfx.kdl` 原样留着。关掉插件之前先把两个动画都设成“niri 默认”，或者删掉这个文件。
