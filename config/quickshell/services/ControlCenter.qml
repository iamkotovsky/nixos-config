pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which screen's control panel is open ("" = closed; one panel at a time) and
// which sub-page it shows ("" = main). Use the page constants, not strings.
Singleton {
    id: root

    readonly property string wifiPage: "wifi"
    readonly property string soundPage: "sound"
    readonly property string bluetoothPage: "bluetooth"
    readonly property string powerPage: "power"

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
        if (![root.wifiPage, root.soundPage, root.bluetoothPage, root.powerPage].includes(name))
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

    // The screen with keyboard focus, for opening the panel from a keybind.
    function focusedScreen() {
        const focused = NiriEvents.workspaces.find(w => w.is_focused);
        if (focused && focused.output)
            return focused.output;
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    // `quickshell ipc call panel power` (Mod+Shift+E).
    IpcHandler {
        target: "panel"

        function power(): void {
            const screen = root.focusedScreen();
            if (root.showing(root.powerPage) && root.openOn === screen) {
                root.close();
                return;
            }
            root.openOn = screen;
            root.openPage(root.powerPage);
        }
    }
}
