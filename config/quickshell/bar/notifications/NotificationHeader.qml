import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import ".."
import "../ui"

// A notification's top row: app icon (or a bell), app name, and a close
// button that appears while the card is hovered.
RowLayout {
    id: header

    property string iconSource
    property string appName
    property bool hovered: false

    signal closeClicked

    spacing: Theme.spacingSmall

    IconImage {
        visible: header.iconSource !== ""
        implicitSize: Theme.iconSize
        source: header.iconSource
        asynchronous: true
    }

    MaterialIcon {
        visible: header.iconSource === ""
        name: "notifications"
        color: Theme.muted
    }

    BarText {
        Layout.fillWidth: true
        text: header.appName || "Notification"
        color: Theme.muted
        font.pixelSize: Theme.fontCaption
        elide: Text.ElideRight
    }

    IconButton {
        implicitWidth: Theme.smallButtonSize
        implicitHeight: Theme.smallButtonSize
        opacity: header.hovered ? 1 : 0
        icon: "close"
        onClicked: header.closeClicked()

        Behavior on opacity {
            Anim {
                speed: "fast"
            }
        }
    }
}
