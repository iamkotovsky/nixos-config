pragma Singleton

import QtQuick
import Quickshell

// Starting apps from the shell (launcher, mixer button, links in
// notifications). Everything goes through `niri msg action spawn`, so the app
// lives in niri's scope like one started from a keybind. Started directly
// (Quickshell.execDetached, Qt.openUrlExternally) it would stay in the
// `quickshell` service's cgroup, and the restart on every rebuild would close
// it.
Singleton {
    id: root

    // The terminal for apps that run in one (the Mod+Return terminal).
    readonly property var terminal: ["kitty", "-e"]

    // Run `command` (an argv list), optionally from `workingDirectory`.
    function spawn(command, workingDirectory) {
        let argv = command;
        if (workingDirectory)
            argv = ["sh", "-c", 'cd "$1" && shift && exec "$@"', "sh", workingDirectory, ...argv];
        Quickshell.execDetached(["niri", "msg", "action", "spawn", "--", ...argv]);
    }

    // A desktop entry, in a terminal if it asks for one.
    function launch(entry) {
        const command = entry.runInTerminal ? [...root.terminal, ...entry.command] : entry.command;
        root.spawn(command, entry.workingDirectory);
    }

    // A link, in the default handler for its kind (browser, mail...).
    function openUrl(url) {
        root.spawn(["xdg-open", url]);
    }
}
