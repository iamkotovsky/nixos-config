import QtQuick
import QtQuick.Layouts
import ".."

// GNOME-style quick toggle: icon, title and subtitle on a frosted chip that
// lifts on hover; accent-filled when on. With `hasPage`, a chevron area on the
// right opens a sub-page while the rest of the tile still toggles.
Glass {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool interactive: true
    property bool hasPage: false

    readonly property color contentColor: active ? Theme.background : Theme.foreground

    signal clicked
    signal pageRequested

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
            rightMargin: root.hasPage ? Theme.chevronWidth + Theme.spacingSmall : Theme.spacingMedium
        }
        spacing: Theme.spacingMedium

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
                font.pixelSize: Theme.fontSmall
                font.bold: true
                elide: Text.ElideRight
            }

            BarText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                color: root.active ? Qt.alpha(Theme.background, Theme.subtleTextOpacity) : Theme.muted
                font.pixelSize: Theme.fontCaption
                elide: Text.ElideRight
            }
        }
    }

    // Chevron chip: its own hover, on top of the tile's.
    Rectangle {
        visible: root.hasPage
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: Theme.spacingXs
        }
        width: Theme.chevronWidth
        radius: Theme.radiusSmall
        color: Qt.alpha(root.contentColor, Theme.fillRest)

        Behavior on color {
            ColorFade {}
        }

        StateLayer {
            lift: false
            onClicked: root.pageRequested()
        }

        MaterialIcon {
            anchors.centerIn: parent
            name: "chevron_right"
            color: root.contentColor
        }
    }
}
