pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// StatusNotifier tray, matching waybar's tray (17px icons). Left-click
// activates, right-click opens the app's DBus menu when available. Icons are
// stacked manually (x = index * slotWidth), same reasoning as Workspaces.qml.
Pill {
    id: root

    visible: trayRepeater.count > 0
    horizontalPadding: Theme.spacingSmall
    readonly property int slotWidth: 23 // icon 17 + 6 spacing

    contentImplicitWidth: Math.max(0, trayRepeater.count * root.slotWidth - Theme.spacingSmall)

    Repeater {
        id: trayRepeater
        model: SystemTray.items
        anchors.fill: parent

        delegate: Item {
            id: trayItem
            required property int index
            required property var modelData

            x: root.horizontalPadding + index * root.slotWidth
            anchors.verticalCenter: parent.verticalCenter
            width: 17
            height: 17

            IconImage {
                anchors.fill: parent
                source: trayItem.modelData.icon
                asynchronous: true
                mipmap: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        if (trayItem.modelData.hasMenu)
                            trayMenu.open();
                        else
                            trayItem.modelData.secondaryActivate();
                    } else {
                        trayItem.modelData.activate();
                    }
                }
            }

            QsMenuAnchor {
                id: trayMenu
                menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
                anchor.item: parent
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
        }
    }
}
