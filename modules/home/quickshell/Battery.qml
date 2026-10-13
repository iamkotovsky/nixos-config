import QtQuick
import Quickshell
import Quickshell.Io

// Battery level from sysfs, matching waybar's battery module: icons per 20%
// bucket, charging glyph, warning/critical colors, 30s poll. Hidden when no
// battery is present.
Pill {
    id: root

    property int capacity: -1
    property bool charging: false

    visible: root.capacity >= 0
    contentImplicitWidth: label.implicitWidth

    readonly property color levelColor: root.capacity <= 10 ? Theme.red : root.capacity <= 25 ? Theme.yellow : Theme.foreground

    function binIcon(percent) {
        if (percent <= 20)
            return "󰁺";
        if (percent <= 40)
            return "󰁼";
        if (percent <= 60)
            return "󰁾";
        if (percent <= 80)
            return "󰂀";
        return "󰁹";
    }

    Process {
        id: poll
        command: ["bash", Quickshell.shellDir + "/battery.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(this.text.trim());
                    root.capacity = d.cap;
                    root.charging = !!d.charging;
                } catch (e) {
                    console.warn("failed to parse battery status:", e);
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: poll.running = true
    }

    Component.onCompleted: poll.running = true

    Text {
        id: label
        anchors.centerIn: parent
        color: root.levelColor
        text: root.charging || root.capacity >= 100 ? "󰂄 " + root.capacity + "%" : root.binIcon(root.capacity) + " " + root.capacity + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
