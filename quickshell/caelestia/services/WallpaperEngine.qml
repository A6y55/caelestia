pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string configPath: `${Paths.config}/wallpaperengine.json`
    readonly property string systemdScript: `${Paths.data}/scripts/caelestia-wallpaperengine-systemd`

    property bool loaded: false
    property bool enabled: true
    property bool autostart: true
    property bool randomSwitchEnabled: false
    property int randomSwitchIntervalMinutes: 30
    property string status: ""

    function readJson(): var {
        const raw = configFile.text().trim();
        if (!raw)
            return {};

        try {
            return JSON.parse(raw);
        } catch (error) {
            root.status = qsTr("Invalid wallpaperengine.json");
            return {};
        }
    }

    function loadConfig(): void {
        const config = readJson();
        const randomSwitch = config.randomSwitch ?? {};

        root.enabled = config.enabled ?? true;
        root.autostart = config.autostart ?? true;
        root.randomSwitchEnabled = randomSwitch.enabled ?? false;
        root.randomSwitchIntervalMinutes = Math.max(1, Math.round(randomSwitch.intervalMinutes ?? 30));
        root.loaded = true;
    }

    function saveConfig(): void {
        const config = readJson();

        config.enabled = root.enabled;
        config.autostart = root.autostart;
        config.randomSwitch = config.randomSwitch ?? {};
        config.randomSwitch.enabled = root.randomSwitchEnabled;
        config.randomSwitch.intervalMinutes = Math.max(1, Math.round(root.randomSwitchIntervalMinutes));
        config.randomSwitch.pauseWhenLocked = config.randomSwitch.pauseWhenLocked ?? true;

        configFile.setText(JSON.stringify(config, null, 2) + "\n");
        applySystemd();
    }

    function setEnabled(value: bool): void {
        if (root.enabled === value)
            return;

        root.enabled = value;
        saveConfig();
    }

    function setAutostart(value: bool): void {
        if (root.autostart === value)
            return;

        root.autostart = value;
        saveConfig();
    }

    function setRandomSwitchEnabled(value: bool): void {
        if (root.randomSwitchEnabled === value)
            return;

        root.randomSwitchEnabled = value;
        saveConfig();
    }

    function setRandomSwitchIntervalMinutes(value: int): void {
        const nextValue = Math.max(1, Math.round(value));
        if (root.randomSwitchIntervalMinutes === nextValue)
            return;

        root.randomSwitchIntervalMinutes = nextValue;
        saveConfig();
    }

    function applySystemd(): void {
        applyProc.exec([root.systemdScript, "apply"]);
        root.status = qsTr("Systemd units updated");
    }

    function restoreCurrent(): void {
        actionProc.exec([root.systemdScript, "restore"]);
        root.status = qsTr("Restoring current wallpaper");
    }

    function nextWallpaper(): void {
        actionProc.exec([root.systemdScript, "next"]);
        root.status = qsTr("Switching wallpaper");
    }

    FileView {
        id: configFile

        path: root.configPath
        watchChanges: true
        onLoaded: root.loadConfig()
        onFileChanged: reload()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.loaded = true;
                root.saveConfig();
            }
        }
    }

    Process {
        id: applyProc
    }

    Process {
        id: actionProc
    }
}
