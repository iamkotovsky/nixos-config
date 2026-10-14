pragma ComponentBehavior: Bound

import QtQuick

// One rounded indicator per workspace on this bar's output: the active one
// stretches into a pill, urgent ones turn red. Click focuses that workspace.
Pill {
    id: root

    required property string output

    readonly property var workspaces: NiriEvents.workspaces.filter(w => w.output === root.output).sort((a, b) => a.idx - b.idx)

    horizontalPadding: Theme.spacingSmall
    spacing: 0

    Repeater {
        model: root.workspaces

        // The slot is the click target; the indicator inside it animates.
        delegate: Item {
            id: workspace

            required property var modelData

            readonly property bool active: modelData.is_active

            implicitWidth: indicator.width + Theme.spacingSmall * 2
            implicitHeight: Theme.pillHeight

            Rectangle {
                id: indicator

                anchors.centerIn: parent
                width: workspace.active ? 22 : 8
                height: 8
                radius: height / 2
                color: {
                    if (workspace.modelData.is_urgent)
                        return Theme.red;
                    if (workspace.active)
                        return Theme.accent;
                    return hover.hovered ? Qt.alpha(Theme.accent, 0.6) : Qt.alpha(Theme.muted, 0.45);
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
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
