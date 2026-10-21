pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Niri state from one long-running `niri msg -j event-stream` (no polling).
// Quickshell's WindowManager module sees no workspaces on niri, so workspaces
// come from here too. Resolvable as the singleton `NiriEvents`.
Singleton {
    id: root

    // Raw niri workspace objects: id, idx, name, output, is_active, ...
    property var workspaces: []
    property var layouts: []
    property int currentLayout: 0

    readonly property string layoutCode: {
        if (layouts.length === 0)
            return "";
        const name = String(layouts[Math.min(currentLayout, layouts.length - 1)]);
        if (name.startsWith("English"))
            return "EN";
        if (name.startsWith("Russian"))
            return "RU";
        return name.slice(0, 2).toUpperCase();
    }

    // The output with keyboard focus (for opening popups from a keybind), or
    // the first screen before niri has reported any workspaces.
    function focusedOutput() {
        const focused = root.workspaces.find(w => w.is_focused);
        if (focused && focused.output)
            return focused.output;
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    // Workspace idx is per output, so focus the output first.
    function focusWorkspace(output, idx) {
        Quickshell.execDetached(["sh", "-c", 'niri msg action focus-monitor "$1" && niri msg action focus-workspace "$2"', "sh", output, String(idx)]);
    }

    function switchLayout() {
        Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"]);
    }

    function updateWorkspaces(fn) {
        root.workspaces = root.workspaces.map(w => Object.assign({}, w, fn(w)));
    }

    function handle(line) {
        let event;
        try {
            event = JSON.parse(line);
        } catch (e) {
            return;
        }

        if (event.WorkspacesChanged) {
            root.workspaces = event.WorkspacesChanged.workspaces;
        } else if (event.WorkspaceActivated) {
            const id = event.WorkspaceActivated.id;
            const focused = event.WorkspaceActivated.focused;
            const target = root.workspaces.find(w => w.id === id);
            if (!target)
                return;
            root.updateWorkspaces(w => ({
                is_active: w.output === target.output ? w.id === id : w.is_active,
                is_focused: focused ? w.id === id : w.is_focused
            }));
        } else if (event.WorkspaceUrgencyChanged) {
            const id = event.WorkspaceUrgencyChanged.id;
            const urgent = event.WorkspaceUrgencyChanged.urgent;
            root.updateWorkspaces(w => ({
                is_urgent: w.id === id ? urgent : w.is_urgent
            }));
        } else if (event.KeyboardLayoutsChanged) {
            const layouts = event.KeyboardLayoutsChanged.keyboard_layouts;
            root.layouts = layouts.names;
            root.currentLayout = layouts.current_idx;
        } else if (event.KeyboardLayoutSwitched) {
            root.currentLayout = event.KeyboardLayoutSwitched.idx;
        }
    }

    Process {
        id: stream

        running: true
        command: ["niri", "msg", "-j", "event-stream"]
        stdout: SplitParser {
            onRead: line => root.handle(line)
        }
        // The stream ends if niri restarts; reconnect shortly after.
        onExited: reconnect.start()
    }

    Timer {
        id: reconnect

        interval: 1000
        onTriggered: stream.running = true
    }
}
