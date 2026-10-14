import QtQuick
import Quickshell
import "services"

// Per output: the top bar, plus its control panel while that one is open.
// Runs as the quickshell-bar user service (modules/home/quickshell.nix) via
// `quickshell --config bar`.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: output

            required property ShellScreen modelData

            Bar {
                modelData: output.modelData
            }

            LazyLoader {
                active: ControlCenter.openOn === output.modelData.name

                ControlPanel {
                    screen: output.modelData
                }
            }
        }
    }
}
