// A deliberately small panel: this is a theme consumer, not a desktop shell.
import Quickshell
import QtQuick

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30
    color: Theme.background

    Text {
        anchors.centerIn: parent
        text: "zenbook"
        color: Theme.foreground
        font.family: Theme.monoFont
        font.pointSize: Theme.fontSize
    }
}
