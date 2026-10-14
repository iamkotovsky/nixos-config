import QtQuick
import ".."

// Round icon button with a hover highlight. `active` fills it with the accent.
Rectangle {
    id: root

    property string icon
    property bool active: false
    property color iconColor: active ? Theme.background : Theme.foreground

    signal clicked(var mouse)

    implicitWidth: 36
    implicitHeight: 36
    radius: height / 2
    color: active ? Theme.accent : Qt.alpha(Theme.foreground, mouse.containsMouse ? 0.14 : 0.07)

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        name: root.icon
        color: root.iconColor
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => root.clicked(event)
    }
}
