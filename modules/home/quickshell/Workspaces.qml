pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

// Mirrors waybar's niri/workspaces: one dot per workspace, active highlighted,
// click to focus (niri focus-workspace takes the workspace's 1-based idx).
// Dots are stacked manually (x = index * slotWidth) because Qt Quick's
// Repeater has no `container` property; the pill width is computed from the
// model count so the block stays centered.
Pill {
    id: root

    horizontalPadding: 3
    readonly property int slotWidth: 30 // dot 28 + 2 spacing

    contentImplicitWidth: Math.max(0, wsRepeater.count * root.slotWidth - 2)

    Repeater {
        id: wsRepeater
        model: Niri.workspaces
        anchors.fill: parent

        delegate: Rectangle {
            id: wsEntry
            required property int index
            required property var modelData

            property bool hovered: false
            readonly property bool active: modelData && modelData.is_active

            x: root.horizontalPadding + index * root.slotWidth
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: Theme.barHeight - Theme.barMargin * 2
            radius: Theme.moduleRadius
            color: wsEntry.hovered || wsEntry.active ? Qt.alpha(Theme.accent, 0.12) : "transparent"
            border.width: 0

            Text {
                anchors.centerIn: parent
                text: wsEntry.active ? "●" : "○"
                color: wsEntry.hovered || wsEntry.active ? Theme.accent : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: wsEntry.hovered = true
                onExited: wsEntry.hovered = false
                onClicked: Niri.focusWorkspace(wsEntry.modelData.idx)
            }
        }
    }
}
