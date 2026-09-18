// Window FX: close animations for single windows.
//
// niri draws closing windows with a custom shader if the config has one. The
// plugin fills shaders/close.glsl with the chosen kind, the accent color and
// the random pool, and writes the result to ~/.config/niri/windowfx.kdl. niri
// watches included files and reloads on its own, so a change takes effect with
// the next window that closes.
//
// The main niri config needs one line at its end (see README):
//     include optional=true "windowfx.kdl"
//
// "default" writes a file without an animation block, so niri falls back to
// whatever the main config says.

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

    function build() {
        const head = "// Written by the Window FX plugin (DMS). Changes here are overwritten.\n";
        if (root.kind === "default")
            return head + "// Close animation: niri default.\n";
        const template = shaderFile.text();
        if (!template)
            return "";
        let id = 0;
        if (root.kind !== "random") {
            const k = Kinds.byKey(root.kind);
            id = k ? k.id : 1;
        }
        const c = root.accent;
        const shader = template
            .replace("@KIND@", String(id))
            .replace("@GLOW@", root.glow ? "1.0" : "0.0")
            .replace("@ACCENT@", num(c.r) + ", " + num(c.g) + ", " + num(c.b))
            .replace("@PICK@", pickCode(root.pool));
        return head
            + "animations {\n"
            + "    window-close {\n"
            + "        duration-ms " + root.duration + "\n"
            + "        curve \"linear\"\n"
            + "        custom-shader r#\"\n" + shader + "\n\"#\n"
            + "    }\n"
            + "}\n";
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
    onDurationChanged: writeLater.restart()
    onGlowChanged: writeLater.restart()
    onPoolChanged: writeLater.restart()
    onAccentChanged: writeLater.restart()

    FileView {
        id: shaderFile
        path: String(Qt.resolvedUrl("shaders/close.glsl")).replace(/^file:\/\//, "")
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

    Component.onCompleted: writeLater.restart()

    IpcHandler {
        target: "windowFx"

        // dms ipc call windowFx kind shatter   (or default, random)
        function kind(name: string): string {
            if (name !== "default" && name !== "random" && !Kinds.byKey(name))
                return "unknown kind: " + name;
            SettingsData.setPluginSetting("windowFx", "kind", name);
            return name;
        }

        function status(): string {
            return root.kind + ", " + root.duration + " ms, glow " + (root.glow ? "on" : "off") + ", pool " + root.pool.join(",");
        }
    }
}
