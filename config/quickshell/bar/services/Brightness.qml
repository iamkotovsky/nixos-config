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
        // step() needs the fresh value right after reload().
        blockAllReads: true
        onLoaded: {
            if (root.pending < 0)
                root.brightness = parseInt(text());
        }
    }

    property real lastStep: 0

    // Brightness keys (niri binds) call this over IPC, because sysfs sends no
    // change events the bar could show the slider for. During rapid presses,
    // build on our own last value (brightnessctl may not have written it yet);
    // otherwise re-read the file in case something else changed it.
    function step(delta) {
        if (!root.available)
            return;
        const now = Date.now();
        if (now - root.lastStep > 1000) {
            current.reload();
            root.brightness = parseInt(current.text());
        }
        root.lastStep = now;
        root.set(root.percent + delta);
        Osd.show("brightness");
    }

    IpcHandler {
        target: "brightness"

        function up(): void {
            root.step(5);
        }

        function down(): void {
            root.step(-5);
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
