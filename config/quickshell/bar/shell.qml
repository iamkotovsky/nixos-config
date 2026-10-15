import QtQuick
import Quickshell
import "services"

// Per output: the top bar, its control panel while open, the floating
// volume/brightness slider and notification popups.
// Runs as the quickshell-bar user service (modules/home/quickshell.nix) via
// `quickshell --config bar`.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: output

            required property ShellScreen modelData
            // The control panel is still on screen (open, or animating out).
            property bool panelShown: false

            Bar {
                modelData: output.modelData
            }

            // Loaded while open, and kept until its card has animated out.
            LazyLoader {
                active: ControlCenter.openOn === output.modelData.name || output.panelShown

                ControlPanel {
                    screen: output.modelData
                    screenName: output.modelData.name
                    onVisibleChanged: output.panelShown = visible
                    Component.onCompleted: output.panelShown = visible
                }
            }

            OsdPopup {
                screen: output.modelData
                screenName: output.modelData.name
            }

            NotificationPopups {
                screen: output.modelData
                screenName: output.modelData.name
            }
        }
    }
}
