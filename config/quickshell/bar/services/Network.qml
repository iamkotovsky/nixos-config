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

    // The Wi-Fi card, connected or not, and its networks for the Wi-Fi page:
    // connected first, then saved ones, then by signal.
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: wifiDevice ? [...wifiDevice.networks.values].filter(n => n.name !== "").sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength)) : []
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

    function secured(network) {
        return network.security !== WifiSecurityType.Open && network.security !== WifiSecurityType.Owe;
    }

    function signalIcon(network) {
        const s = network.signalStrength;
        if (s >= 0.75)
            return "network_wifi";
        if (s >= 0.5)
            return "network_wifi_3_bar";
        if (s >= 0.25)
            return "network_wifi_2_bar";
        return "network_wifi_1_bar";
    }

    // Saved and open networks connect directly; a new secured one needs
    // `password`. Failures arrive as the network's connectionFailed signal.
    function connectTo(network, password) {
        if (password)
            network.connectWithPsk(password);
        else
            network.connect();
    }

    // Scan only while the Wi-Fi page is open.
    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: true
        when: root.wifiDevice !== null && ControlCenter.showing(ControlCenter.wifiPage)
    }
}
