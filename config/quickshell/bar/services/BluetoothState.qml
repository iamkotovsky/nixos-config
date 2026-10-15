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

    // For the Bluetooth page: connected first, then paired, then nearby ones
    // found by discovery (only those with a real name).
    readonly property var devices: Bluetooth.devices.values.filter(d => d.paired || d.connected || (d.name !== "" && d.name !== d.address.replace(/:/g, "-"))).sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
    // A device being paired from the page; connected once pairing succeeds.
    property var pairing: null

    function deviceIcon(device) {
        const icon = device.icon ?? "";
        if (icon.includes("headset") || icon.includes("headphone"))
            return "headphones";
        if (icon.startsWith("audio"))
            return "speaker";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        if (icon.includes("phone"))
            return "smartphone";
        if (icon.includes("computer"))
            return "computer";
        if (icon.includes("gaming"))
            return "sports_esports";
        return "bluetooth";
    }

    // Click on a device row: disconnect, connect, or pair + trust + connect
    // (blueman's agent handles any PIN prompt).
    function activate(device) {
        if (device.connected) {
            device.disconnect();
        } else if (device.paired) {
            device.connect();
        } else {
            device.trusted = true;
            root.pairing = device;
            device.pair();
        }
    }

    function forget(device) {
        device.forget();
    }

    // Like GNOME: "off" also sets the rfkill soft block, and "on" lifts it
    // first. While soft-blocked (e.g. by blueman, a hotkey or a previous
    // session), BlueZ silently refuses to power the adapter on, so setting
    // `adapter.enabled` alone does nothing. The user can write /dev/rfkill
    // (uaccess), so no root is needed.
    // Discover nearby devices only while the Bluetooth page is open.
    Binding {
        target: root.adapter
        property: "discovering"
        value: true
        when: root.enabled && ControlCenter.openOn !== "" && ControlCenter.page === "bluetooth"
    }

    Connections {
        target: root.pairing

        function onPairedChanged() {
            if (root.pairing.paired) {
                root.pairing.connect();
                root.pairing = null;
            }
        }
    }

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
