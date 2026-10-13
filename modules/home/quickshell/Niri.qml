pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Polls the niri IPC socket for the state the bar cares about.
// Resolvable as the singleton type `Niri` from any file in the config.
Singleton {
    id: niri

    property var workspaces: []
    property string rawWorkspaces: ""
    property var layouts: []
    property int currentLayout: 0

    readonly property string layoutCode: {
        if (layouts.length === 0)
            return "EN";
        const name = String(layouts[Math.min(currentLayout, layouts.length - 1)]).toLowerCase();
        if (name.indexOf("english") >= 0)
            return "EN";
        if (name.indexOf("russian") >= 0)
            return "RU";
        return String(layouts[currentLayout]).slice(0, 2).toUpperCase();
    }

    Process {
        id: workspacesProcess
        command: ["niri", "msg", "-j", "workspaces"]

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = this.text.trim();
                if (raw === niri.rawWorkspaces)
                    return;
                niri.rawWorkspaces = raw;
                try {
                    niri.workspaces = JSON.parse(raw);
                } catch (e) {
                    console.warn("failed to parse niri workspaces:", e);
                }
            }
        }
    }

    Process {
        id: keyboardProcess
        command: ["niri", "msg", "-j", "keyboard-layouts"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text.trim());
                    if (data && data.names && data.names.length > 0) {
                        niri.layouts = data.names;
                        niri.currentLayout = data.current_idx;
                    }
                } catch (e) {
                    console.warn("failed to parse niri keyboard-layouts:", e);
                }
            }
        }
    }

    Process {
        id: actionProcess
        command: ["true"]
    }

    function runAction(args) {
        actionProcess.command = args;
        actionProcess.running = true;
    }

    function focusWorkspace(idx) {
        niri.runAction(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    function switchLayout() {
        niri.runAction(["niri", "msg", "action", "switch-layout"]);
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            workspacesProcess.running = true;
            keyboardProcess.running = true;
        }
    }
}
