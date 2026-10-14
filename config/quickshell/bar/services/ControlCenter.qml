pragma Singleton

import QtQuick
import Quickshell

// Which screen's control panel is open ("" = closed). One panel at a time.
Singleton {
    id: root

    property string openOn: ""

    function toggle(screenName) {
        root.openOn = root.openOn === screenName ? "" : screenName;
    }

    function close() {
        root.openOn = "";
    }
}
