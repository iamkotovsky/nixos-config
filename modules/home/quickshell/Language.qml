import QtQuick
import Quickshell

// Active keyboard layout, derived from niri's keyboard-layouts IPC (EN/RU on
// this machine). Click cycles layouts, same as waybar's niri/language module.
Pill {
    id: root

    contentImplicitWidth: label.implicitWidth

    Text {
        id: label
        anchors.centerIn: parent
        color: Theme.foreground
        text: Niri.layoutCode
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Niri.switchLayout()
    }
}
