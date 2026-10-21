import QtQuick
import Quickshell.Wayland
import ".."

// One screen of the session lock; the content lives in LockContent so it can
// also be previewed in an ordinary window.
WlSessionLockSurface {
    id: surface

    property bool checking: false
    property bool failed: false
    property string message: ""
    property int failures: 0
    property bool unlocking: false

    signal submitted(string text)

    color: Theme.background

    LockContent {
        anchors.fill: parent
        checking: surface.checking
        failed: surface.failed
        message: surface.message
        failures: surface.failures
        unlocking: surface.unlocking
        onSubmitted: text => surface.submitted(text)
    }
}
