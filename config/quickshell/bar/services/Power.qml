pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import ".."

// Battery (UPower) and power profile (power-profiles-daemon via UPower).
Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool hasBattery: device !== null && device.ready && device.isLaptopBattery
    // Quickshell reports 0-1; accept 0-100 too in case that ever changes.
    readonly property int capacity: hasBattery ? Math.round(device.percentage > 1 ? device.percentage : device.percentage * 100) : -1
    readonly property bool full: hasBattery && device.state === UPowerDeviceState.FullyCharged
    readonly property bool charging: hasBattery && !UPower.onBattery
        && (device.state === UPowerDeviceState.Charging || full || device.state === UPowerDeviceState.PendingCharge)
    readonly property color levelColor: charging ? Theme.foreground : capacity <= 10 ? Theme.red : capacity <= 25 ? Theme.yellow : Theme.foreground

    // Horizontal, rounded Android-style glyphs: they fill their icon box like
    // the Wi-Fi glyph, unlike the tall, thin battery_N_bar set.
    readonly property string icon: {
        if (charging)
            return "battery_android_bolt";
        if (capacity >= 95)
            return "battery_android_full";
        // battery_android_0 .. battery_android_6
        return "battery_android_" + Math.min(6, Math.floor(capacity / 100 * 7));
    }

    function duration(seconds) {
        const minutes = Math.round(seconds / 60);
        const h = Math.floor(minutes / 60);
        const m = minutes % 60;
        return h > 0 ? h + " h " + m + " min" : m + " min";
    }

    readonly property string stateText: {
        if (!hasBattery)
            return "";
        if (full)
            return "Fully charged";
        if (charging)
            return device.timeToFull > 0 ? "Charging · full in " + duration(device.timeToFull) : "Charging";
        return device.timeToEmpty > 0 ? duration(device.timeToEmpty) + " left" : "On battery";
    }

    // Same order as the Mod+P keybind. Always all three: Quickshell 0.3.1
    // reports hasPerformanceProfile = false although the daemon offers it.
    readonly property var profiles: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    readonly property int profile: PowerProfiles.profile
    readonly property bool balanced: profile === PowerProfile.Balanced
    readonly property string profileIcon: profile === PowerProfile.PowerSaver ? "eco" : profile === PowerProfile.Performance ? "speed" : "balance"
    readonly property string profileName: profile === PowerProfile.PowerSaver ? "Power saver" : profile === PowerProfile.Performance ? "Performance" : "Balanced"

    function cycleProfile() {
        const index = profiles.indexOf(PowerProfiles.profile);
        PowerProfiles.profile = profiles[(index + 1) % profiles.length];
    }
}
