import QtQuick
import ".."

// On/off switch: accent track when on; the knob glides across.
Rectangle {
    id: root

    property bool checked: false

    signal toggled

    implicitWidth: Theme.switchWidth
    implicitHeight: Theme.switchHeight
    radius: height / 2
    color: checked ? Theme.accent : Qt.alpha(Theme.foreground, Theme.fillRest)
    border.width: 1
    border.color: checked ? Theme.accent : Qt.alpha(Theme.foreground, Theme.fillRim)

    Behavior on color {
        ColorFade {}
    }

    StateLayer {
        lift: false
        onClicked: root.toggled()
    }

    Rectangle {
        readonly property int inset: Theme.spacingXs

        x: root.checked ? root.width - width - inset : inset
        anchors.verticalCenter: parent.verticalCenter
        width: root.height - inset * 2
        height: width
        radius: width / 2
        color: root.checked ? Theme.background : Theme.foreground

        Behavior on x {
            NumberAnimation {
                duration: Theme.durationNormal
                easing.type: Easing.OutBack
                easing.overshoot: Theme.overshoot
            }
        }

        Behavior on color {
            ColorFade {}
        }
    }
}
