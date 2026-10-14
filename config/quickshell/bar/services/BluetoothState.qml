pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

// BlueZ adapter power and connected devices. Named BluetoothState so it
// doesn't shadow Quickshell's own `Bluetooth` singleton.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property string deviceName: connectedDevices.length > 0 ? connectedDevices[0].name : ""

    readonly property string icon: !enabled ? "bluetooth_disabled" : connectedDevices.length > 0 ? "bluetooth_connected" : "bluetooth"

    // Like GNOME: "off" also sets the rfkill soft block, and "on" lifts it
    // first. While soft-blocked (e.g. by blueman, a hotkey or a previous
    // session), BlueZ silently refuses to power the adapter on, so setting
    // `adapter.enabled` alone does nothing. The user can write /dev/rfkill
    // (uaccess), so no root is needed.
    function toggle() {
        if (!available)
            return;
        if (enabled) {
            adapter.enabled = false;
            Quickshell.execDetached(["rfkill", "block", "bluetooth"]);
        } else {
            // The adapter re-registers after unblocking; give it a moment.
            Quickshell.execDetached(["sh", "-c", "rfkill unblock bluetooth && sleep 0.5 && bluetoothctl power on"]);
        }
    }
}
