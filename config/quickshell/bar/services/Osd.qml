pragma Singleton

import QtQuick
import Quickshell
import ".."

// On-screen display state: which value to show ("volume" / "brightness"),
// on which output, and for how long. Osd.qml (one per screen) renders it.
Singleton {
    id: root

    property string kind: ""
    property bool shown: false

    // The output with the focused workspace, i.e. the screen in use.
    readonly property string output: (NiriEvents.workspaces.find(w => w.is_focused) ?? {}).output ?? ""

    function show(kind) {
        root.kind = kind;
        root.shown = true;
        hide.restart();
    }

    Timer {
        id: hide

        interval: 1500
        onTriggered: root.shown = false
    }
}
