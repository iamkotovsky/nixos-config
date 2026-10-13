import QtQuick
import Quickshell
import Quickshell.Io

// Network status via NetworkManager, mirroring waybar's network module:
// wifi shows "󰤨  {signal}%", ethernet the link glyph, otherwise the
// disconnected glyph.
Pill {
    id: root

    property string mode: "disconnected" // disconnected | wifi | ethernet
    property int signal: -1
    property string device: ""
    property string ip: ""

    contentImplicitWidth: label.implicitWidth

    Process {
        id: poll
        command: ["bash", Quickshell.shellDir + "/network.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(this.text.trim());
                    root.mode = d.state;
                    root.signal = Number(d.signal || -1);
                    root.device = d.device || "";
                    root.ip = d.ip || "";
                } catch (e) {
                    console.warn("failed to parse network status:", e);
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: poll.running = true
    }

    Component.onCompleted: poll.running = true

    Text {
        id: label
        anchors.centerIn: parent
        color: root.mode === "disconnected" ? Theme.muted : Theme.foreground
        text: root.mode === "wifi" && root.signal >= 0 ? "󰤨  " + root.signal + "%" : root.mode === "ethernet" ? "󰈀" : "󰤭"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
