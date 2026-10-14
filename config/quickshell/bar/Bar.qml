import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// One bar per output: pills on a subtle frosted strip. Everything sits on
// Theme.gap: pills are one gap from the top and side edges and one gap above
// the strip's bottom, and niri (whose `gaps` is the same theme value) starts
// windows one more gap below the strip. The strip hides windows sliding
// under the pills during workspace-switch animations.
PanelWindow {
    id: bar

    required property ShellScreen modelData

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    // gap + pill + gap, so the pills are vertically centered in the strip.
    implicitHeight: Theme.gap * 2 + Theme.pillHeight
    // Reserve the whole strip: niri adds its own gap below it, so windows (and
    // their focus ring) start one full gap under the strip.
    exclusiveZone: implicitHeight
    color: Qt.alpha(Theme.background, Theme.stripOpacity)

    // Matched by the blur layer-rule in config/niri/config.kdl.
    WlrLayershell.namespace: "quickshell-bar"

    Workspaces {
        id: left

        output: bar.modelData.name
        anchors {
            left: parent.left
            leftMargin: Theme.gap
            top: parent.top
            topMargin: Theme.gap
        }
    }

    Clock {
        anchors.top: parent.top
        anchors.topMargin: Theme.gap
        // Centered, but clamped between the left and right groups.
        x: Math.max(left.x + left.width + Theme.gap, Math.min((parent.width - width) / 2, right.x - width - Theme.gap))
    }

    RowLayout {
        id: right

        anchors {
            right: parent.right
            rightMargin: Theme.gap
            top: parent.top
            topMargin: Theme.gap
        }
        spacing: Theme.spacingSmall

        Tray {}
        Language {}

        StatusButton {
            screenName: bar.modelData.name
        }
    }
}
