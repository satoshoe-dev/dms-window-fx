// Defaults here must match WindowFxDaemon.qml and Kinds.js.

pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services
import qs.Modules.Plugins
import qs.Widgets
import "Kinds.js" as Kinds

PluginSettings {
    id: root
    pluginId: "windowFx"

    readonly property var _settings: SettingsData.pluginSettings
    function cfg(key, fallback) {
        root._settings;
        return SettingsData.getPluginSetting("windowFx", key, fallback);
    }

    readonly property string kind: cfg("kind", "default")
    readonly property string openKind: cfg("openKind", "mirror")
    readonly property bool anyRandom: kind === "random" || openKind === "random" || (openKind === "mirror" && kind === "random")

    function kindOptions(withMirror) {
        const opts = withMirror ? [
            {
                label: I18n.trFor("windowFx", "Like closing, backwards"),
                value: "mirror"
            }
        ] : [];
        opts.push(
            {
                label: I18n.trFor("windowFx", "niri default"),
                value: "default"
            },
            {
                label: I18n.trFor("windowFx", "Random"),
                value: "random"
            }
        );
        for (let i = 0; i < Kinds.list.length; i++)
            opts.push({
                label: I18n.trFor("windowFx", Kinds.list[i].label),
                value: Kinds.list[i].key
            });
        return opts;
    }

    StyledText {
        width: parent ? parent.width : implicitWidth
        wrapMode: Text.WordWrap
        text: I18n.trFor("windowFx", "Needs this line at the end of ~/.config/niri/config.kdl:") + "\ninclude optional=true \"windowfx.kdl\""
        color: Theme.surfaceVariantText
        font.pixelSize: Theme.fontSizeSmall
    }

    SelectionSetting {
        settingKey: "kind"
        label: I18n.trFor("windowFx", "Close animation")
        description: I18n.trFor("windowFx", "How a window disappears when it is closed.")
        defaultValue: "default"
        options: root.kindOptions(false)
    }

    SliderSetting {
        visible: root.kind !== "default"
        settingKey: "duration"
        label: I18n.trFor("windowFx", "Duration")
        defaultValue: 600
        minimum: 150
        maximum: 3000
        unit: "ms"
    }

    ToggleSetting {
        visible: root.kind !== "default" && root.cfg("holdSupported", false)
        settingKey: "holdLayout"
        label: I18n.trFor("windowFx", "Neighbours wait")
        description: I18n.trFor("windowFx", "The windows around move into the gap only after the animation. Needs a niri with hold-layout.")
        defaultValue: false
    }

    SelectionSetting {
        settingKey: "openKind"
        label: I18n.trFor("windowFx", "Open animation")
        description: I18n.trFor("windowFx", "How a new window appears. Plays the kind backwards.")
        defaultValue: "mirror"
        options: root.kindOptions(true)
    }

    SliderSetting {
        visible: root.openKind !== "default" && !(root.openKind === "mirror" && root.kind === "default")
        settingKey: "openDuration"
        label: I18n.trFor("windowFx", "Open duration")
        defaultValue: 450
        minimum: 150
        maximum: 3000
        unit: "ms"
    }

    ToggleSetting {
        visible: root.kind !== "default" || root.openKind !== "default"
        settingKey: "glow"
        label: I18n.trFor("windowFx", "Glowing edges")
        description: I18n.trFor("windowFx", "Edges and cracks light up in the accent color.")
        defaultValue: true
    }

    StyledText {
        visible: root.anyRandom
        width: parent ? parent.width : implicitWidth
        wrapMode: Text.WordWrap
        text: I18n.trFor("windowFx", "Random picks from these:")
        color: Theme.surfaceText
        font.pixelSize: Theme.fontSizeMedium
    }

    Repeater {
        model: Kinds.list

        ToggleSetting {
            required property var modelData
            visible: root.anyRandom
            settingKey: "pool_" + modelData.key
            label: I18n.trFor("windowFx", modelData.label)
            defaultValue: modelData.pool
        }
    }
}
