pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import ".."
import "../ui"
import "../services"

// One rounded indicator per workspace on this bar's output: the active one
// stretches into a pill, urgent ones turn red, new ones grow in. Click focuses
// that workspace.
Pill {
    id: root

    required property string output

    readonly property var workspaces: NiriEvents.workspaces.filter(w => w.output === root.output).sort((a, b) => a.idx - b.idx)

    horizontalPadding: Theme.spacingSmall
    spacing: 0

    Repeater {
        // Keyed by workspace id: niri events replace every workspace object, and
        // a plain array would rebuild all dots each time, so nothing animated.
        model: ScriptModel {
            values: root.workspaces
            objectProp: "id"
        }

        // The slot is the click target; the indicator inside it animates.
        delegate: Item {
            id: workspace

            required property var modelData

            readonly property bool active: modelData.is_active
            // False for the first frame, so a new dot grows in from nothing.
            property bool shown: false

            Component.onCompleted: shown = true

            implicitWidth: indicator.width + Theme.spacingSmall * 2
            implicitHeight: Theme.pillHeight

            Rectangle {
                id: indicator

                anchors.centerIn: parent
                width: !workspace.shown ? 0 : workspace.active ? Theme.indicatorActiveWidth : Theme.indicatorSize
                height: Theme.indicatorSize
                radius: height / 2
                color: {
                    if (workspace.modelData.is_urgent)
                        return Theme.red;
                    if (workspace.active)
                        return Theme.accent;
                    return hover.hovered ? Theme.muted : Qt.alpha(Theme.muted, Theme.disabledOpacity);
                }

                Behavior on width {
                    Anim {}
                }

                Behavior on color {
                    ColorFade {}
                }
            }

            HoverHandler {
                id: hover

                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: NiriEvents.focusWorkspace(root.output, workspace.modelData.idx)
            }
        }
    }
}
