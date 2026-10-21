import QtQuick
import ".."

// Sub-page list: grows with its rows up to Theme.listMaxRows, then scrolls.
// Rows fade in and out, and the rest glide into place.
ListView {
    id: root

    implicitHeight: Math.min(contentHeight, Theme.rowHeight * Theme.listMaxRows)
    clip: true
    spacing: 0
    boundsBehavior: Flickable.StopAtBounds

    Behavior on implicitHeight {
        Anim {}
    }

    add: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.durationNormal
            easing.type: Easing.OutCubic
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: Theme.exitDuration(Theme.durationNormal)
            easing.type: Easing.InCubic
        }
    }

    displaced: Transition {
        NumberAnimation {
            property: "y"
            duration: Theme.durationNormal
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            property: "opacity"
            to: 1
            duration: Theme.durationNormal
        }
    }
}
