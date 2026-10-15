import QtQuick
import QtQuick.Layouts
import ".."

// GNOME-style quick toggle: icon, title and subtitle on a frosted chip that
// lifts on hover; accent-filled when on.
Glass {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool interactive: true

    readonly property color contentColor: active ? Theme.background : Theme.foreground

    signal clicked

    implicitHeight: Theme.tileHeight
    radius: Theme.radiusMedium
    color: active ? Theme.accent : Qt.alpha(Theme.foreground, Theme.fillRest)
    border.color: Qt.alpha(Theme.foreground, Theme.fillRim)
    highlight: false

    StateLayer {
        enabled: root.interactive
        lift: root.interactive
        onClicked: root.clicked()
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Theme.spacingMedium
            rightMargin: Theme.spacingMedium
        }
        spacing: Theme.spacingMedium

        MaterialIcon {
            name: root.icon
            color: root.contentColor

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durationFast
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            BarText {
                Layout.fillWidth: true
                text: root.title
                color: root.contentColor
                font.pixelSize: Theme.fontSmall
                font.bold: true
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durationFast
                    }
                }
            }

            BarText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                color: root.active ? Qt.alpha(Theme.background, Theme.subtleTextOpacity) : Theme.muted
                font.pixelSize: Theme.fontCaption
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durationFast
                    }
                }
            }
        }
    }
}
