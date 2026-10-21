import QtQuick
import QtQuick.Layouts
import ".."

// A scrolling column for content that isn't a list (the Sound page's app
// sliders): grows with its content up to `maxHeight`, then scrolls with the
// shell's scrolling (SmoothScroll). Children are laid out in a ColumnLayout
// (`spacing`), so they use Layout.fillWidth like in any page.
Flickable {
    id: root

    default property alias content: column.data
    property alias spacing: column.spacing
    property real maxHeight: Theme.rowHeight * Theme.listMaxRows

    implicitHeight: Math.min(column.implicitHeight, maxHeight)
    contentWidth: width
    contentHeight: column.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    // SmoothScroll does the scrolling.
    interactive: false

    Behavior on implicitHeight {
        Anim {}
    }

    ColumnLayout {
        id: column

        width: root.width
        spacing: Theme.spacingMedium
    }

    SmoothScroll {
        parent: root
        anchors.fill: parent
        flickable: root
    }
}
