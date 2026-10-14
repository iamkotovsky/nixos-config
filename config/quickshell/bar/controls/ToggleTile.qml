import QtQuick
import QtQuick.Layouts
import ".."

// GNOME-style quick toggle: icon, title and subtitle; accent-filled when on.
Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool interactive: true

    readonly property color contentColor: active ? Theme.background : Theme.foreground

    signal clicked

    implicitHeight: 56
    radius: Theme.moduleRadius
    color: active ? Theme.accent : Qt.alpha(Theme.foreground, mouse.containsMouse && interactive ? 0.14 : 0.07)

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 12
        }
        spacing: 12

        MaterialIcon {
            name: root.icon
            color: root.contentColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            BarText {
                Layout.fillWidth: true
                text: root.title
                color: root.contentColor
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
                elide: Text.ElideRight
            }

            BarText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                color: root.active ? Qt.alpha(Theme.background, 0.75) : Theme.muted
                font.pixelSize: Theme.fontSize - 4
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
