// Window FX: close and open animations for single windows.
//
// niri draws closing and opening windows with a custom shader if the config
// has one. The plugin fills shaders/window.glsl with the chosen kind, the
// accent color and the random pool, and writes the result to
// ~/.config/niri/windowfx.kdl. Opening plays a kind backwards. niri
// watches included files and reloads on its own, so a change takes effect with
// the next window that closes.
//
// The main niri config needs one line at its end (see README):
//     include optional=true "windowfx.kdl"
//
// "default" leaves the block out, so niri falls back to whatever the main
// config says.

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins
import "Kinds.js" as Kinds

PluginComponent {
    id: root

    property var popoutService: null

    readonly property var _settings: SettingsData.pluginSettings
    function cfg(key, fallback) {
        return SettingsData.getPluginSetting("windowFx", key, fallback);
    }

    // "default", "random" or a key from Kinds.js
    readonly property string kind: {
        root._settings;
        return cfg("kind", "default");
    }
    // "mirror" (the close kind, backwards), "default", "random" or a key
    readonly property string openKind: {
        root._settings;
        return cfg("openKind", "mirror");
    }
    readonly property int openDuration: {
        root._settings;
        return Math.max(150, Math.min(3000, cfg("openDuration", 450)));
    }
    readonly property int duration: {
        root._settings;
        return Math.max(150, Math.min(3000, cfg("duration", 600)));
    }
    readonly property bool glow: {
        root._settings;
        return cfg("glow", true);
    }
    readonly property var pool: {
        root._settings;
        const ids = [];
        for (let i = 0; i < Kinds.list.length; i++) {
            const k = Kinds.list[i];
            if (cfg("pool_" + k.key, k.pool))
                ids.push(k.id);
        }
        return ids;
    }
    readonly property color accent: Theme.primary
    // Neighbours wait for the close animation. Needs a niri that knows
    // `hold-layout` (own patch); a stock niri would reject the whole file.
    readonly property bool holdLayout: {
        root._settings;
        return cfg("holdLayout", false);
    }
    property bool holdSupported: false

    readonly property string targetPath: Quickshell.env("HOME") + "/.config/niri/windowfx.kdl"
    property string lastWritten: ""

    function num(x) {
        return (Math.round(x * 1000) / 1000).toFixed(3);
    }

    function pickCode(ids) {
        if (ids.length === 0)
            return "    return 1;";
        const lines = [];
        for (let i = 0; i < ids.length - 1; i++)
            lines.push("    if (r < " + num((i + 1) / ids.length) + ") return " + ids[i] + ";");
        lines.push("    return " + ids[ids.length - 1] + ";");
        return lines.join("\n");
    }

    function shader(kind, fn, progress) {
        const template = shaderFile.text();
        if (!template)
            return "";
        let id = 0;
        if (kind !== "random") {
            const k = Kinds.byKey(kind);
            id = k ? k.id : 1;
        }
        const c = root.accent;
        return template
            .replace("@KIND@", String(id))
            .replace("@GLOW@", root.glow ? "1.0" : "0.0")
            .replace("@ACCENT@", num(c.r) + ", " + num(c.g) + ", " + num(c.b))
            .replace("@PICK@", pickCode(root.pool))
            .replace("@FUNCTION@", fn)
            .replace("@PROGRESS@", progress);
    }

    function block(name, ms, code, extra) {
        return "    " + name + " {\n"
            + "        duration-ms " + ms + "\n"
            + "        curve \"linear\"\n"
            + (extra || "")
            + "        custom-shader r#\"\n" + code + "\n\"#\n"
            + "    }\n";
    }

    function build() {
        const head = "// Written by the Window FX plugin (DMS). Changes here are overwritten.\n";
        if (!shaderFile.text())
            return "";
        const openKind = root.openKind === "mirror" ? root.kind : root.openKind;
        let body = "";
        if (root.kind !== "default")
            body += block("window-close", root.duration, shader(root.kind, "close_color", "niri_clamped_progress"),
                root.holdLayout && root.holdSupported ? "        hold-layout\n" : "");
        if (openKind !== "default")
            body += block("window-open", root.openDuration, shader(openKind, "open_color", "1.0 - niri_clamped_progress"));
        if (!body)
            return head + "// Open and close animations: niri default.\n";
        return head + "animations {\n" + body + "}\n";
    }

    function write() {
        const text = build();
        if (!text || text === root.lastWritten)
            return;
        root.lastWritten = text;
        outFile.setText(text);
    }

    // Several settings change at once when a profile is applied; write once.
    Timer {
        id: writeLater
        interval: 150
        onTriggered: root.write()
    }

    onKindChanged: writeLater.restart()
    onOpenKindChanged: writeLater.restart()
    onOpenDurationChanged: writeLater.restart()
    onDurationChanged: writeLater.restart()
    onGlowChanged: writeLater.restart()
    onPoolChanged: writeLater.restart()
    onAccentChanged: writeLater.restart()
    onHoldLayoutChanged: writeLater.restart()
    onHoldSupportedChanged: writeLater.restart()

    // Does the installed niri know hold-layout? Validate a tiny config with it.
    Process {
        id: holdProbe
        command: ["sh", "-c", "f=$(mktemp --suffix=.kdl) && printf 'animations {\\n    window-close {\\n        hold-layout\\n    }\\n}\\n' > \"$f\" && niri validate -c \"$f\" >/dev/null 2>&1; r=$?; rm -f \"$f\"; exit $r"]
        onExited: code => {
            root.holdSupported = code === 0;
            SettingsData.setPluginSetting("windowFx", "holdSupported", code === 0);
        }
    }

    FileView {
        id: shaderFile
        path: String(Qt.resolvedUrl("shaders/window.glsl")).replace(/^file:\/\//, "")
        blockLoading: true
        onLoaded: writeLater.restart()
    }

    FileView {
        id: outFile
        path: root.targetPath
        atomicWrites: true
        blockLoading: true
        onLoaded: root.lastWritten = text()
    }

    Component.onCompleted: {
        holdProbe.running = true;
        writeLater.restart();
    }

    IpcHandler {
        target: "windowFx"

        // dms ipc call windowFx kind shatter   (or default, random)
        function kind(name: string): string {
            if (name !== "default" && name !== "random" && !Kinds.byKey(name))
                return "unknown kind: " + name;
            SettingsData.setPluginSetting("windowFx", "kind", name);
            return name;
        }

        // dms ipc call windowFx open mirror   (or default, random, a kind)
        function open(name: string): string {
            if (name !== "default" && name !== "random" && name !== "mirror" && !Kinds.byKey(name))
                return "unknown kind: " + name;
            SettingsData.setPluginSetting("windowFx", "openKind", name);
            return name;
        }

        function status(): string {
            return "close " + root.kind + " " + root.duration + " ms, open " + root.openKind + " " + root.openDuration + " ms, glow " + (root.glow ? "on" : "off") + ", pool " + root.pool.join(",");
        }
    }
}
