import QtQuick
import Quickshell.Widgets
import ".."

// Round icon button: a frosted chip that lifts on hover. `active` fills it
// with the accent.
Glass {
    id: root

    property string icon
    // An image (app icon) shown instead of the glyph, when set.
    property string image
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

    IconImage {
        anchors.centerIn: parent
        visible: root.image !== ""
        implicitSize: Theme.iconSize
        source: root.image
        asynchronous: true
    }

    MaterialIcon {
        anchors.centerIn: parent
        visible: root.image === ""
        name: root.icon
        color: root.iconColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.durationFast
            }
        }
    }
}
