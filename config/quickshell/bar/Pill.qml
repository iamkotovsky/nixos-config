import QtQuick
import QtQuick.Layouts

// Rounded applet background. Children are laid out in a vertically centered
// row; the pill sizes itself to them. Set `interactive` to get clicked/scrolled
// over the whole pill (tray-style pills handle input per child instead).
Rectangle {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing
    property int horizontalPadding: Theme.spacingMedium
    property bool interactive: false

    signal clicked(var mouse)
    signal scrolled(int delta)

    implicitWidth: row.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.pillHeight
    color: Qt.alpha(Theme.surface, Theme.pillOpacity)
    radius: Theme.moduleRadius

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Theme.spacingSmall
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }
}
