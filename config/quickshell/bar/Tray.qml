pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// StatusNotifier tray. Left-click activates (or opens the menu for menu-only
// items), right-click opens the app's menu under its icon. Symbolic icons
// (e.g. Telegram's monochrome tray icon) are tinted with the theme foreground.
Pill {
    id: root

    // Hidden items:
    // - Passive ones: by the StatusNotifierItem spec they have nothing to show
    //   right now (udiskie stays passive until a removable drive appears).
    // - blueman: Bluetooth lives in the control panel instead.
    readonly property var hiddenIds: ["blueman"]

    visible: items.count > 0
    spacing: Theme.spacingMedium

    Repeater {
        id: items

        model: ScriptModel {
            values: SystemTray.items.values.filter(item => item.status !== Status.Passive && !root.hiddenIds.includes(item.id))
        }

        delegate: Item {
            id: trayItem

            required property SystemTrayItem modelData

            // Monochrome "-symbolic" icons are drawn in one dark color meant to
            // be recolored, so they are tinted instead of shown as-is.
            readonly property bool symbolic: String(modelData.icon).includes("-symbolic")

            implicitWidth: Theme.iconSize
            implicitHeight: Theme.iconSize

            IconImage {
                id: image

                anchors.fill: parent
                source: trayItem.modelData.icon
                asynchronous: true
                mipmap: true
                // A symbolic icon only provides the shape for the tint below.
                visible: !trayItem.symbolic
                layer.enabled: trayItem.symbolic
            }

            // Theme color, cut to the symbolic icon's shape.
            Rectangle {
                anchors.fill: parent
                visible: trayItem.symbolic
                color: Theme.foreground
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: image
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    const item = trayItem.modelData;
                    const wantsMenu = mouse.button === Qt.RightButton || item.onlyMenu;
                    if (wantsMenu && item.hasMenu)
                        menu.open();
                    else if (mouse.button === Qt.RightButton)
                        item.secondaryActivate();
                    else
                        item.activate();
                }
            }

            QsMenuAnchor {
                id: menu

                menu: trayItem.modelData.menu
                anchor.item: trayItem
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
        }
    }
}
