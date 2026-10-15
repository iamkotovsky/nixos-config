import QtQuick
import ".."

// Hover/press feedback for anything clickable, filling its parent: a rounded
// tint (rest -> hover -> pressed), the pointing-hand cursor, a slight press
// scale, and hover lift for Glass parents. Only clickable things use it, so a
// hover effect always means "you can click this". Declare it before the
// parent's content so the tint sits under icons and text.
MouseArea {
    id: root

    // The item that scales on press and lifts on hover (if it is Glass).
    property Item target: parent
    property real radius: target && target.radius !== undefined ? target.radius : 0
    // Grow the tint past the parent, for bare icons with no surface of their own.
    property int outset: 0
    property bool lift: true
    // Shrink slightly on press. Off for surfaces with their own blur region,
    // which can't follow a scale.
    property bool squash: true

    readonly property real tint: !enabled ? 0 : pressed ? Theme.fillPressed - Theme.fillRest : containsMouse ? Theme.fillHover - Theme.fillRest : 0
    property real pressAmount: pressed ? 1 : 0

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    Behavior on pressAmount {
        NumberAnimation {
            duration: Theme.durationFast
            easing.type: Easing.OutCubic
        }
    }

    Binding {
        target: root.target
        property: "scale"
        value: 1 - (1 - Theme.pressScale) * root.pressAmount
        when: root.squash
    }

    Binding {
        target: root.target
        property: "lifted"
        value: root.enabled && root.containsMouse && !root.pressed
        when: root.lift && root.target !== null && root.target.lifted !== undefined
    }

    Rectangle {
        anchors {
            fill: parent
            margins: -root.outset
        }
        radius: root.outset > 0 ? height / 2 : root.radius
        color: Qt.alpha(Theme.foreground, root.tint)

        Behavior on color {
            ColorAnimation {
                duration: Theme.durationFast
            }
        }
    }
}
