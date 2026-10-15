pragma Singleton

import QtQuick
import Quickshell

// Which screen's control panel is open ("" = closed; one panel at a time) and
// which sub-page it shows ("" = main, "wifi", "sound", "bluetooth").
Singleton {
    id: root

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
        root.page = name;
    }

    function back() {
        root.page = "";
    }
}
