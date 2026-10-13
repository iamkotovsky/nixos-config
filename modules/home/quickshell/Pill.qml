import QtQuick
import Quickshell

// Shared applet background: a rounded pill sized like the waybar modules it
// replaces (barHeight 38, 4px vertical margin). Each widget reports the width
// of its content via `contentImplicitWidth` and lays that content out itself
// (anchors/Row); the pill only frames it.
Rectangle {
    id: root

    property real contentImplicitWidth: 0
    property int horizontalPadding: Theme.spacingMedium
    property real fillOpacity: Theme.moduleOpacity

    width: implicitWidth
    height: implicitHeight
    implicitWidth: root.contentImplicitWidth + root.horizontalPadding * 2
    implicitHeight: Theme.barHeight - Theme.barMargin * 2

    color: Qt.alpha(Theme.surface, root.fillOpacity)
    radius: Theme.moduleRadius
    border.width: 0
}
