import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import "lock"

// The lock screen, a separate Quickshell process from the bar (started by the
// `lockscreen` user unit, see modules/home/lockscreen.nix), so a bar crash
// never touches it. It shares this directory's Theme and ui/ components.
//
// It holds the session lock (ext-session-lock) until PAM accepts the
// password, then fades out, unlocks and exits. If it crashes, niri keeps the
// session locked; from a TTY run `systemctl --user stop lockscreen; lock-screen`.
ShellRoot {
    id: root

    // Set while PAM checks a password, and after a wrong one.
    property bool checking: false
    property bool failed: false
    property string message: ""
    // Counts wrong passwords, so every screen's field can shake.
    property int failures: 0
    // Set once PAM succeeded: surfaces animate out, then the lock is released.
    property bool unlocking: false

    property string password: ""
    // Marks the session as securely locked, for "lock before sleep".
    readonly property string marker: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-lock.secure"

    function submit(text) {
        if (root.checking || root.unlocking || text === "")
            return;
        root.password = text;
        root.checking = true;
        root.failed = false;
        root.message = "";
        pam.start();
    }

    PamContext {
        id: pam

        config: "quickshell-lock"

        onPamMessage: {
            if (responseRequired)
                respond(root.password);
        }

        onCompleted: result => {
            root.password = "";
            root.checking = false;
            if (result === PamResult.Success) {
                root.unlocking = true;
                release.start();
            } else {
                root.failed = true;
                root.failures += 1;
                root.message = result === PamResult.MaxTries ? "Too many attempts" : "Wrong password";
            }
        }

        onError: error => {
            root.password = "";
            root.checking = false;
            root.failed = true;
            root.failures += 1;
            root.message = "Authentication error";
        }
    }

    // Lets the surfaces' exit animation finish before the lock goes.
    Timer {
        id: release

        interval: Theme.exitDuration(Theme.durationSlow)
        onTriggered: lock.locked = false
    }

    WlSessionLock {
        id: lock

        locked: true

        onSecureChanged: {
            if (secure)
                Quickshell.execDetached(["touch", root.marker]);
        }

        onLockedChanged: {
            if (!locked) {
                Quickshell.execDetached(["rm", "-f", root.marker]);
                Qt.quit();
            }
        }

        // One per screen.
        surface: Component {
            LockSurface {
                checking: root.checking
                failed: root.failed
                message: root.message
                failures: root.failures
                unlocking: root.unlocking
                onSubmitted: text => root.submit(text)
            }
        }
    }
}
