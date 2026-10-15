import QtQuick
import ".."

// Round icon button: a frosted chip that lifts on hover. `active` fills it
// with the accent.
Glass {
    id: root

    property string icon
    property bool active: false
    property color iconColor: active ? Theme.background : Theme.foreground

    signal clicked(var mouse)

    implicitWidth: Theme.buttonSize
    implicitHeight: Theme.buttonSize
    radius: height / 2
    color: active ? Theme.accent : Qt.alpha(Theme.foreground, Theme.fillRest)
    border.color: Qt.alpha(Theme.foreground, Theme.fillRim)
    highlight: false

    StateLayer {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => root.clicked(event)
    }

    MaterialIcon {
        anchors.centerIn: parent
        name: root.icon
        color: root.iconColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.durationFast
            }
        }
    }
}
