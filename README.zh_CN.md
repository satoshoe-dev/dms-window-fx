# Window FX

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [Italiano](README.it.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · **简体中文**

[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) 的一个插件，给 niri 上的窗口加上自己的关闭和打开动画: 窗口会烧掉、碎成碎片、融化、出故障，或者像老式显像管那样关掉。边缘用你的强调色发光。

![Window FX](assets/screenshot.png)

带图片的分步说明: [安装与设置指南](docs/GUIDE.zh_CN.md)。

## 它做什么

niri 可以用自定义着色器来画正在关闭或打开的窗口。插件把这样的着色器写进 `~/.config/niri/windowfx.kdl`，文件一变，niri 就自己重新读取。新的设置从下一个关闭或打开的窗口开始生效。

一共有 13 种:

| 效果 | 会发生什么 |
|---|---|
| 余烬 | 窗口沿着一条参差的火线烧掉 |
| 溶解 | 粗颗粒按随机顺序消失 |
| 像素化 | 方块变大，然后淡去 |
| 碎裂 | 窗口裂成碎片，旋转着落下 |
| 融化 | 细细的竖条各按自己的速度往下滑 |
| 故障 | 撕裂、错开的颜色通道和跳动的方块，然后散掉 |
| 显像管关机 | 压成一条线，再压成一个点，闪一下亮光 |
| 雪花屏 | 画面淹没在噪点里，一粒一粒地散开 |
| 扫描 | 一道光束往下走，身后留下边缘的线框 |
| 代码雨 | 一列列字符往下流，后面只剩下代码 |
| 漩涡 | 窗口绕着中心卷起来 |
| 方块 | 方块按随机顺序缩小 |
| 百叶窗 | 横向的叶片合上 |

“随机”会从你自己定的候选里，为每个窗口重新挑一种。关闭和打开各有自己的时长。打开时会把效果倒着播放: 默认情况下，新窗口出现的方式就是上一个窗口消失的方式，只是反过来。选“niri 默认”，插件就把这个动画交给 niri。

“发光边缘”让边缘、裂缝和接缝用 DMS 的强调色发光。强调色一变，插件就重新写文件。显像管关机不管这个设置怎样，总是闪白光。

如果你在用 [Profiles](https://github.com/satoshoe-dev/dms-profiles) 插件，在 设置 → 插件 → Profiles → 随配置保存的插件 里填入 `windowFx`，每个配置就会保留自己的动画。

## 要求

DankMaterialShell 1.6.1 或更新版本，niri 26.04 或更新版本。niri 的版本要求来自下面的 include 行：niri 从 26.04 起才支持 `optional=true`。

插件只写它自己的文件。只有 niri 配置 include 了这个文件，niri 才会读它。把这一行加到 `~/.config/niri/config.kdl` 的末尾:

```kdl
include optional=true "windowfx.kdl"
```

放在末尾，是因为 include 会覆盖它前面的内容；这样插件的动画就会优先于主配置里的动画。

“相邻窗口等待”还需要打了非官方补丁的 niri，详见下文“相邻窗口等待”一节。其余功能用普通的 niri 就可以。

## 安装

从插件注册表安装：

```sh
dms plugins install windowFx
dms ipc call plugins enable windowFx
```

也可以在 DMS 的 设置 → 插件 → 浏览 中找到它。若要从仓库安装：

```sh
git clone https://github.com/satoshoe-dev/dms-window-fx ~/.config/DankMaterialShell/plugins/WindowFx
dms ipc call plugins enable windowFx
```

然后在 设置 → 插件 → Window FX 里选一个关闭动画。在选之前，niri 保留自己的动画。

## 设置

设置 → 插件 → Window FX

| 设置 | 默认值 |
|---|---|
| 关闭动画 | niri 默认 |
| 时长 | 600 ms |
| 相邻窗口等待 | 关 (只在认识 `hold-layout` 的 niri 上) |
| 打开动画 | 和关闭一样，倒着放 |
| 打开时长 | 450 ms |
| 发光边缘 | 开 |
| 随机从这些里面选 | 余烬、碎裂、融化、故障、显像管关机、代码雨 |

两个时长都可以设在 150 到 3000 ms 之间。

## IPC

```sh
dms ipc call windowFx kind shatter   # close animation: a kind, random or default
dms ipc call windowFx open mirror    # open animation: mirror, a kind, random or default
dms ipc call windowFx status
```

各种效果的名字是 `ember`、`dissolve`、`pixel`、`shatter`、`melt`、`glitch`、`crt`、`snow`、`scan`、`code`、`swirl`、`squares` 和 `blinds`。

在 niri 里绑一个键，为接下来的窗口掷一次骰子:

```kdl
binds {
    Mod+Shift+W { spawn "dms" "ipc" "call" "windowFx" "kind" "random"; }
}
```

## 相邻窗口等待

窗口一关闭，niri 就立刻把它从布局里拿掉。旁边的窗口马上开始往空位移动，滑到还在播放动画的窗口上面。短短的淡出几乎看不出来；换成燃烧的边缘或落下的碎片，大部分就被相邻的窗口挡住了。

为此我给 niri 写了一个小补丁，在 `window-close` 里加入选项 `hold-layout`。有了它，移除窗口所引起的一切 (相邻窗口移进来、视图滚动、列改变大小) 都要等关闭动画结束后才开始。这个补丁不属于 niri，发行版里的 niri 不认识这个选项。没有用这个补丁编译的 niri，“相邻窗口等待”就不起作用。

针对 niri 26.04 的补丁位于我的 niri 复刻仓库的 [hold-layout-v26.04](https://github.com/satoshoe-dev/niri/tree/hold-layout-v26.04) 分支。构建方式与 niri 本身相同，参见其 README。

插件启动时会检查装着的 niri 是否认识这个选项，做法是让 `niri validate` 读一个用了这个选项的小文件。如果认识，设置页面上就会出现“相邻窗口等待”这个开关；如果不认识，开关就一直隐藏，插件也从不写这个选项，因为原版 niri 会拒绝整个文件。

## 关掉插件

关掉插件后，`windowfx.kdl` 原样留着，所以最后的动画还在。想回到 niri 自己的动画，先把两个动画都设成“niri 默认”，或者删掉这个文件。有 `optional=true`，文件不存在 niri 也没问题。

## 翻译

设置页面有德语、西班牙语、法语、意大利语、葡萄牙语、俄语、日语和简体中文，跟随 DMS 里设置的语言。如果某处译得不对，欢迎提 pull request。

## 说明

这个插件是我在 Claude (Anthropic) 的帮助下写的，每一处改动都在我自己的 niri 桌面上测试过。

## 许可

MIT
