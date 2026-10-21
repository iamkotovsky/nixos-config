import QtQuick
import QtQuick.Layouts
import ".."
import "../ui"

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
        Anim {}
    }

    // Wheel and touchpad scrolling as whole steps (`scrolled(+1/-1)` each).
    WheelSteps {
        id: wheelSteps
    }

    StateLayer {
        enabled: root.interactive
        visible: root.interactive
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => {
            const steps = wheelSteps.feed(wheel);
            for (let i = 0; i < Math.abs(steps); i++)
                root.scrolled(Math.sign(steps));
        }
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Theme.spacingSmall
    }
}
