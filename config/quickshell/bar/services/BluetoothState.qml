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

    // Off: power the adapter down through BlueZ first (it disconnects
    // devices cleanly and returns once done), then set the rfkill soft block,
    // like GNOME. One step after the other: cutting the radio while BlueZ is
    // still tearing down an audio connection hung this Intel controller's
    // firmware (HCI Reset timeouts; restarting bluetoothd did not help).
    // On: lift the block, then power on, retrying while the adapter
    // re-registers; while soft-blocked BlueZ refuses to power on. The user
    // can write /dev/rfkill (uaccess), so no root is needed.
    function toggle() {
        if (!available)
            return;
        if (enabled)
            Quickshell.execDetached(["sh", "-c", "bluetoothctl power off; rfkill block bluetooth"]);
        else
            Quickshell.execDetached(["sh", "-c", "rfkill unblock bluetooth; for i in 1 2 3 4 5 6 7 8 9 10; do bluetoothctl power on && exit 0; sleep 0.5; done"]);
    }
}
