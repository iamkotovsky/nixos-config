pragma Singleton

import QtQuick
import Quickshell
import ".."

// On-screen display state: which value to show (Osd.volume or
// Osd.brightness) and for how long. OsdPopup (one per screen) renders it on
// the screen in use (NiriEvents.focusedOutput).
Singleton {
    id: root

    readonly property string volume: "volume"
    readonly property string brightness: "brightness"

    property string kind: ""
    property bool shown: false

    function show(kind) {
        root.kind = kind;
        root.shown = true;
        hide.restart();
    }

    Timer {
        id: hide

        interval: Theme.osdTimeout
        onTriggered: root.shown = false
    }
}
