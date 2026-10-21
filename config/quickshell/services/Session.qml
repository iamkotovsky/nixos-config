pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Lock, suspend and leaving the session, through `sessionctl`
// (modules/home/session.nix), which closes windows first and then stops the
// session in order. Log out, restart and shut down count down first (the row
// on the Power page shows it): click again to go now, cancel to stay.
// Leaving the Power page or closing the panel cancels. If a window won't
// close, `failure` says so (the lock screen shows it; the bar also gets a
// notification from sessionctl).
Singleton {
    id: root

    readonly property string lock: "lock"
    readonly property string suspend: "suspend"
    readonly property string logout: "logout"
    readonly property string reboot: "reboot"
    readonly property string poweroff: "poweroff"

    // In Power page order. `confirm` actions count down before running.
    readonly property var actions: [
        {
            id: root.lock,
            icon: "lock",
            title: "Lock",
            pendingTitle: "",
            confirm: false
        },
        {
            id: root.suspend,
            icon: "bedtime",
            title: "Suspend",
            pendingTitle: "",
            confirm: false
        },
        {
            id: root.logout,
            icon: "logout",
            title: "Log out",
            pendingTitle: "Logging out",
            confirm: true
        },
        {
            id: root.reboot,
            icon: "restart_alt",
            title: "Restart",
            pendingTitle: "Restarting",
            confirm: true
        },
        {
            id: root.poweroff,
            icon: "power_settings_new",
            title: "Shut down",
            pendingTitle: "Shutting down",
            confirm: true
        }
    ]

    readonly property int countdownSeconds: 5

    // The action counting down ("" = none) and the seconds left.
    property string pending: ""
    property int remaining: 0
    // sessionctl is running (closing windows), and why the last run stopped.
    readonly property bool busy: runner.running
    property string failure: ""

    function find(id) {
        return root.actions.find(a => a.id === id);
    }

    // A click on a row: run it, start its countdown, or (clicked again while
    // counting down) run it now.
    function request(id) {
        const action = root.find(id);
        if (!action)
            return console.warn("Session: unknown action", id);
        if (root.busy)
            return;
        root.failure = "";
        if (!action.confirm || root.pending === id)
            return root.run(id);
        root.pending = id;
        root.remaining = root.countdownSeconds;
        countdown.restart();
    }

    function cancel() {
        countdown.stop();
        root.pending = "";
    }

    function run(id) {
        root.cancel();
        root.failure = "";
        ControlCenter.close();
        runner.action = id;
        runner.command = ["sessionctl", id];
        runner.running = true;
    }

    // Waits for sessionctl (it runs in a unit of its own, so it carries on if
    // this process goes away first). Exit 3: a window stayed open.
    Process {
        id: runner

        property string action

        onExited: code => {
            if (code === 3)
                root.failure = "Some apps didn't close";
            else if (code !== 0)
                root.failure = root.find(runner.action).title + " failed";
        }
    }

    Timer {
        id: countdown

        interval: 1000
        repeat: true
        onTriggered: {
            root.remaining -= 1;
            if (root.remaining <= 0)
                root.run(root.pending);
        }
    }

    Connections {
        target: ControlCenter

        function onOpenOnChanged() {
            root.cancel();
        }

        function onPageChanged() {
            root.cancel();
        }
    }
}
