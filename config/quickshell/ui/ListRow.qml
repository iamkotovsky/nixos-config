import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import ".."

// One row in a sub-page list: icon, title, muted subtitle and trailing items
// (signal bars, battery, buttons). Flat until hovered; `active` (connected,
// default) tints the icon and shows a check; `busy` swaps the icon for a
// spinner. `iconColor` overrides the tint (red while a power action counts
// down). `image` shows an app icon instead of the glyph; `hoverTint: false`
// leaves hover to a list highlight (the launcher).
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
    property color iconColor: active ? Theme.accent : Theme.foreground
    property string image: ""
    // Larger rows (the launcher) raise these.
    property int imageSize: Theme.iconSizeLarge
    property int titleSize: Theme.fontSmall
    // Padding before the icon, and the icon column's width (button-wide by
    // default so row icons line up with the back button and slider icons).
    property int leftPadding: 0
    property int iconColumnWidth: Theme.buttonSize
    property bool hoverTint: true
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
        tinted: root.hoverTint
        onClicked: root.clicked()
    }

    RowLayout {
        anchors {
            fill: parent
            // The icon sits in a button-wide column, so row icons line up with
            // the back button and slider icons, and titles share one edge.
            leftMargin: root.leftPadding
            rightMargin: Theme.spacingMedium
        }
        spacing: Theme.spacingMedium

        Item {
            implicitWidth: root.iconColumnWidth
            implicitHeight: Theme.iconSize

            IconImage {
                anchors.centerIn: parent
                visible: !root.busy && root.image !== ""
                implicitSize: root.imageSize
                source: root.image
                asynchronous: true
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: !root.busy && root.image === ""
                name: root.icon
                color: root.iconColor
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
                font.pixelSize: root.titleSize
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
