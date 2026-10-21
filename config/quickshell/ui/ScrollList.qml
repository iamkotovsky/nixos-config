import QtQuick
import ".."

// Sub-page list: grows with its rows up to `maxRows` (Theme.listMaxRows),
// then scrolls with the shell's scrolling (SmoothScroll: touchpad glide,
// rubber-band ends, wheel glides, a scrollbar while moving). Rows fade in and
// out, and the rest glide into place.
ListView {
    id: root

    property int maxRows: Theme.listMaxRows
    property int rowHeight: Theme.rowHeight

    // Scrolls just enough to show row `index`, gliding. Not
    // positionViewAtIndex: that also snaps the highlight instead of letting
    // it glide.
    function reveal(index) {
        const item = itemAtIndex(index);
        const top = item ? item.y : originY + index * rowHeight;
        scroller.revealRange(top, top + (item ? item.height : rowHeight));
    }

    function scrollTo(y, animate) {
        scroller.scrollTo(y, animate);
    }

    implicitHeight: Math.min(contentHeight, rowHeight * maxRows)
    clip: true
    spacing: 0
    boundsBehavior: Flickable.StopAtBounds
    // SmoothScroll does the scrolling.
    interactive: false

    Behavior on implicitHeight {
        Anim {}
    }

    SmoothScroll {
        id: scroller

        parent: root
        anchors.fill: parent
        flickable: root
        step: root.rowHeight
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
