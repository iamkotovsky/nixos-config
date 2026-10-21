pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Caffeine: while on, idle only turns the display off; the idle manager
// (modules/home/lockscreen.nix) skips its lock and suspend steps when this flag
// file exists. It lives in the runtime dir, so it resets on logout.
Singleton {
    id: root

    readonly property string flag: Quickshell.env("XDG_RUNTIME_DIR") + "/caffeine"
    property bool enabled: false

    function toggle() {
        root.enabled = !root.enabled;
        Quickshell.execDetached(root.enabled ? ["touch", root.flag] : ["rm", "-f", root.flag]);
    }

    // Pick up the flag left by a previous bar instance (restart, rebuild).
    Process {
        running: true
        command: ["test", "-e", root.flag]
        onExited: code => root.enabled = code === 0
    }
}
