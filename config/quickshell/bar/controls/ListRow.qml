import QtQuick
import QtQuick.Layouts
import ".."

// One row in a sub-page list: icon, title, muted subtitle and trailing items
// (signal bars, battery, buttons). Flat until hovered; `active` (connected,
// default) tints the icon and shows a check; `busy` swaps the icon for a
// spinner.
Item {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false
    // The trailing check; pages turn it off to put something else there.
    property bool showCheck: active
    property bool busy: false
    property bool interactive: true
    readonly property bool hovered: layer.containsMouse
    default property alias trailing: trailingRow.data

    signal clicked

    implicitHeight: Theme.rowHeight
    // Exposed so StateLayer rounds its tint.
    property real radius: Theme.radiusMedium

    StateLayer {
        id: layer

        enabled: root.interactive
        lift: false
        onClicked: root.clicked()
    }

    RowLayout {
        anchors {
            fill: parent
            // The icon sits in a button-wide column, so row icons line up with
            // the back button and slider icons, and titles share one edge.
            rightMargin: Theme.spacingMedium
        }
        spacing: Theme.spacingMedium

        Item {
            implicitWidth: Theme.buttonSize
            implicitHeight: Theme.iconSize

            MaterialIcon {
                anchors.centerIn: parent
                visible: !root.busy
                name: root.icon
                color: root.active ? Theme.accent : Theme.foreground

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durationFast
                    }
                }
            }

            Spinner {
                anchors.centerIn: parent
                visible: root.busy
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            BarText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSmall
                font.bold: root.active
                elide: Text.ElideRight
            }

            BarText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                color: Theme.muted
                font.pixelSize: Theme.fontCaption
                elide: Text.ElideRight
            }
        }

        RowLayout {
            id: trailingRow

            spacing: Theme.spacingSmall
        }

        MaterialIcon {
            visible: root.showCheck
            name: "check"
            color: Theme.accent
        }
    }
}
