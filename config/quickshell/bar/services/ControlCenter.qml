pragma Singleton

import QtQuick
import Quickshell

// Which screen's control panel is open ("" = closed; one panel at a time) and
// which sub-page it shows ("" = main). Use the page constants, not strings.
Singleton {
    id: root

    readonly property string wifiPage: "wifi"
    readonly property string soundPage: "sound"
    readonly property string bluetoothPage: "bluetooth"

    property string openOn: ""
    property string page: ""

    function toggle(screenName) {
        if (root.openOn !== screenName)
            root.page = "";
        root.openOn = root.openOn === screenName ? "" : screenName;
    }

    function close() {
        root.openOn = "";
    }

    function openPage(name) {
        if (![root.wifiPage, root.soundPage, root.bluetoothPage].includes(name))
            console.warn("ControlCenter: unknown page", name);
        root.page = name;
    }

    function back() {
        root.page = "";
    }

    // The page is open on some screen (for services that work only then).
    function showing(name) {
        return root.openOn !== "" && root.page === name;
    }
}
