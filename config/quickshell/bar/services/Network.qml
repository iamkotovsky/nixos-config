pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// NetworkManager state: wired link, Wi-Fi radio, connected network and signal.
Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wifiNetwork: wifi ? wifi.networks.values.find(n => n.connected) ?? null : null

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property string ssid: wifiNetwork ? wifiNetwork.name : ""
    readonly property int signal: wifiNetwork ? Math.round(wifiNetwork.signalStrength * 100) : 0

    readonly property string wifiIcon: {
        if (!wifiEnabled)
            return "wifi_off";
        if (!wifi)
            return "signal_wifi_0_bar";
        if (signal >= 75)
            return "network_wifi";
        if (signal >= 50)
            return "network_wifi_3_bar";
        if (signal >= 25)
            return "network_wifi_2_bar";
        return "network_wifi_1_bar";
    }

    // Wired wins in the status button, like GNOME.
    readonly property string icon: wired ? "lan" : wifiIcon
    readonly property bool connected: wired !== null || wifi !== null

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
