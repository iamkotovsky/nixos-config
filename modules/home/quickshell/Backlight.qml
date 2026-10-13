import QtQuick
import Quickshell
import Quickshell.Io

// Screens backlight via brightnessctl, matching waybar's backlight module
// (scroll adjusts by 5%). Hidden when no backlight device exists.
Pill {
    id: root

    property int percent: -1

    visible: root.percent >= 0
    contentImplicitWidth: label.implicitWidth

    Process {
        id: poll
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",");
                if (fields.length >= 4) {
                    root.percent = parseInt(fields[3].replace("%", ""), 10);
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: poll.running = true
    }

    Component.onCompleted: poll.running = true

    Process {
        id: action
        command: ["true"]
    }

    function run(args) {
        action.command = args;
        action.running = true;
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: Theme.foreground
        text: "󰃠 " + root.percent + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                root.run(["brightnessctl", "set", "5%+"]);
            } else {
                root.run(["brightnessctl", "set", "5%-"]);
            }
        }
    }
}
