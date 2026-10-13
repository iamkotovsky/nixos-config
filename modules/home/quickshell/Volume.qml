import QtQuick
import Quickshell
import Quickshell.Io

// WirePlumber volume sink: icon + percent, muted state, matching waybar's
// wireplumber module (left toggles mute, right opens pavucontrol, scroll 5%).
Pill {
    id: root

    property int volume: -1
    property bool muted: false

    readonly property string icon: {
        if (volume < 0)
            return "󰕿";
        if (volume <= 0)
            return "󰝟";
        if (volume < 34)
            return "󰕿";
        if (volume < 67)
            return "󰖀";
        return "󰕾";
    }

    contentImplicitWidth: label.implicitWidth

    Process {
        id: poll
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: {
                const match = /Volume: ([0-9.]+)( \[MUTED\])?/.exec(this.text.trim());
                if (!match)
                    return;
                root.volume = Math.round(parseFloat(match[1]) * 100);
                root.muted = match[2] !== undefined;
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
        text: root.muted ? "󰝟 muted" : root.icon + " " + Math.max(root.volume, 0) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.run(["pavucontrol"]);
            } else {
                root.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
            }
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                root.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]);
            } else {
                root.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]);
            }
        }
    }
}
