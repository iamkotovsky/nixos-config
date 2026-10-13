import QtQuick
import Quickshell

// Top bar: one PanelWindow per output. Left = workspaces, center = clock,
// right = language/tray/network/volume/backlight/battery. This mirrors the
// waybar layout found in modules/home/waybar.nix.
ShellRoot {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            exclusiveZone: Theme.barHeight
            implicitHeight: Theme.barHeight
            color: Qt.alpha(Theme.background, Theme.barOpacity)

            Workspaces {
                anchors {
                    left: parent.left
                    leftMargin: Theme.spacingMedium
                    verticalCenter: parent.verticalCenter
                }
            }

            Clock {
                anchors.centerIn: parent
            }

            Row {
                id: rightGroup
                anchors {
                    right: parent.right
                    rightMargin: Theme.spacingMedium
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.spacingSmall
                width: implicitWidth
                height: implicitHeight

                Language {}
                Tray {}
                Network {}
                Volume {}
                Backlight {}
                Battery {}
            }
        }
    }
}
