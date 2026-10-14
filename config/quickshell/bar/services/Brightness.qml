pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness from sysfs. The kernel emits no change events for these
// files, so the value is re-read every second, and only while the control
// panel is open (nothing else shows it). Writes go through brightnessctl.
Singleton {
    id: root

    property string device: ""
    property int maxBrightness: 0
    property int brightness: 0

    readonly property bool available: device !== "" && maxBrightness > 0
    readonly property int percent: available ? Math.round(brightness / maxBrightness * 100) : 0
    readonly property string icon: percent < 34 ? "brightness_low" : percent < 67 ? "brightness_medium" : "brightness_high"

    property int pending: -1

    // Slider drags fire many changes; apply only the latest every 50 ms so
    // brightnessctl isn't spawned per pixel. Never below 1%: 0 is black.
    function set(percent) {
        root.pending = Math.max(1, Math.min(100, Math.round(percent)));
        root.brightness = Math.round(root.pending / 100 * root.maxBrightness);
        if (!apply.running)
            apply.start();
    }

    // One-shot lookup of the first backlight device (e.g. intel_backlight).
    Process {
        running: true
        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: root.device = this.text.trim()
        }
    }

    FileView {
        path: root.device ? "/sys/class/backlight/" + root.device + "/max_brightness" : ""
        onLoaded: root.maxBrightness = parseInt(text())
    }

    FileView {
        id: current

        path: root.device ? "/sys/class/backlight/" + root.device + "/brightness" : ""
        onLoaded: {
            if (root.pending < 0)
                root.brightness = parseInt(text());
        }
    }

    Timer {
        interval: 1000
        running: root.device !== "" && ControlCenter.openOn !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: current.reload()
    }

    Timer {
        id: apply

        interval: 50
        onTriggered: {
            Quickshell.execDetached(["brightnessctl", "set", root.pending + "%"]);
            root.pending = -1;
        }
    }
}
