import QtQuick
import QtQuick.Layouts
import "controls"

// Rounded glass applet. Children are laid out in a vertically centered row;
// the pill sizes itself to them. Set `interactive` to get clicked/scrolled
// over the whole pill, with hover/press feedback (tray-style pills handle
// input per child instead).
Glass {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing
    property int horizontalPadding: Theme.spacingMedium
    property bool interactive: false

    signal clicked(var mouse)
    signal scrolled(int delta)

    implicitWidth: row.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.pillHeight
    level: "raised"

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.durationNormal
            easing.type: Easing.OutCubic
        }
    }

    StateLayer {
        enabled: root.interactive
        visible: root.interactive
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Theme.spacingSmall
    }
}
