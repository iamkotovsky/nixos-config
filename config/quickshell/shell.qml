import QtQuick
import Quickshell
import "windows"
import "services"

// Per output: the top bar, its control panel, the app launcher, the floating
// volume/brightness slider and notification popups.
// Runs as the `quickshell` user service (modules/home/quickshell.nix), as
// Quickshell's default config (~/.config/quickshell/shell.qml).
ShellRoot {
    // Singletons are only created when something first reads them. These
    // must run from start-up, not only once a panel or popup touches them:
    // Audio shows the OSD on volume changes, Brightness owns the brightness
    // IPC handler, Notifications owns the notification server, ControlCenter
    // owns the panel IPC handler (Mod+Shift+E), Launcher the launcher's
    // (Mod+D), Power the power-profile one (Mod+P).
    readonly property var services: [Audio, Brightness, Notifications, ControlCenter, Launcher, Power]

    Variants {
        model: Quickshell.screens

        Scope {
            id: output

            required property ShellScreen modelData

            Bar {
                modelData: output.modelData
            }

            ControlPanel {
                screen: output.modelData
                screenName: output.modelData.name
            }

            AppLauncher {
                screen: output.modelData
                screenName: output.modelData.name
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
