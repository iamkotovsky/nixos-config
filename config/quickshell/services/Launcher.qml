pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The app launcher (windows/AppLauncher.qml, Mod+D): which screen it is open on
// ("" = closed), the search, and the ranked apps. Apps start through
// `niri msg action spawn` so they live in niri's scope, not this shell's: a
// shell restart (every rebuild) would otherwise take them down with it.
Singleton {
    id: root

    property string openOn: ""
    property string query: ""

    // { desktop id: launches }, kept in Quickshell's state directory.
    property var usage: ({})

    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay)

    // Matching apps, best first; every app (most used first) when the
    // search is empty.
    readonly property var results: {
        const q = root.query.trim().toLowerCase();
        const scored = [];
        for (const entry of root.apps) {
            const score = q === "" ? 0 : root.match(entry, q);
            if (score > 0 || q === "")
                scored.push({
                    entry: entry,
                    score: score + root.boost(entry)
                });
        }
        scored.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
        return scored.map(s => s.entry);
    }

    // How well `entry` matches the lower-cased query `q` (0 = not at all).
    function match(entry, q) {
        const name = (entry.name ?? "").toLowerCase();
        if (name === q)
            return 100;
        if (name.startsWith(q))
            return 80;
        if (name.split(/[\s\-_.]+/).some(word => word.startsWith(q)))
            return 60;
        if (name.includes(q))
            return 40;
        const generic = (entry.genericName ?? "").toLowerCase();
        const keywords = (entry.keywords ?? []).map(k => k.toLowerCase());
        if (generic.includes(q) || keywords.some(k => k.includes(q)))
            return 25;
        if (root.subsequence(name, q))
            return 15;
        if ((entry.comment ?? "").toLowerCase().includes(q))
            return 10;
        return 0;
    }

    // The letters of `q` appear in `text` in order ("ffx" -> "firefox").
    function subsequence(text, q) {
        let i = 0;
        for (const c of text) {
            if (c === q[i])
                i += 1;
            if (i === q.length)
                return true;
        }
        return false;
    }

    function boost(entry) {
        return Math.min(20, (root.usage[entry.id] ?? 0) * 2);
    }

    function toggle(screenName) {
        if (root.openOn === screenName)
            return root.close();
        ControlCenter.close();
        root.query = "";
        root.openOn = screenName;
    }

    function close() {
        root.openOn = "";
    }

    function launch(entry) {
        if (!entry)
            return;
        root.close();

        const counts = Object.assign({}, root.usage);
        counts[entry.id] = (counts[entry.id] ?? 0) + 1;
        root.usage = counts;
        usageFile.setText(JSON.stringify(counts));

        Quickshell.execDetached(root.spawnCommand(entry));
    }

    // niri spawns the app (own scope); terminal apps run in kitty, the
    // Mod+Return terminal; a working directory needs a small sh wrapper.
    function spawnCommand(entry) {
        let command = entry.command;
        if (entry.runInTerminal)
            command = ["kitty", "-e", ...command];
        if (entry.workingDirectory)
            command = ["sh", "-c", 'cd "$1" && shift && exec "$@"', "sh", entry.workingDirectory, ...command];
        return ["niri", "msg", "action", "spawn", "--", ...command];
    }

    FileView {
        id: usageFile

        path: Quickshell.statePath("launcher-usage.json")
        // First run: start the file so later reads find it.
        onLoadFailed: setText("{}")
        onLoaded: {
            try {
                root.usage = JSON.parse(text()) ?? {};
            } catch (e) {
                root.usage = {};
            }
        }
    }

    // `quickshell ipc call launcher toggle` (Mod+D).
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle(NiriEvents.focusedOutput());
        }
    }
}
