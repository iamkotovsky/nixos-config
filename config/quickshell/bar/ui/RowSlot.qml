import QtQuick
import ".."

// The single status slot at the end of a ListRow: a hover action (e.g.
// forget) in place of the status, else the status glyph (check, lock), else
// nothing. Glyphs cross-fade. See .claude/rules/design.md.
Item {
    id: slot

    // The row's hover state; the slot adds its own.
    property bool rowHovered: false
    // Hover action (empty = none) and its handler.
    property string action: ""
    // Status glyph when not showing the action (empty = none), and its tint.
    property string status: ""
    property color statusColor: Theme.accent

    signal triggered

    readonly property bool acting: action !== "" && (rowHovered || layer.containsMouse)
    readonly property string glyph: acting ? action : status

    implicitWidth: Theme.iconSize
    implicitHeight: Theme.iconSize

    StateLayer {
        id: layer

        enabled: slot.action !== ""
        visible: slot.action !== ""
        outset: Theme.spacingXs
        lift: false
        onClicked: slot.triggered()
    }

    // One glyph per possible state, cross-faded.
    Repeater {
        model: [slot.action, slot.status].filter((g, i, all) => g !== "" && all.indexOf(g) === i)

        delegate: MaterialIcon {
            required property string modelData

            readonly property bool current: slot.glyph === modelData

            anchors.centerIn: parent
            name: modelData
            color: modelData === slot.action ? Theme.muted : slot.statusColor
            opacity: current ? 1 : 0
            scale: current ? 1 : Theme.pressScale

            Behavior on opacity {
                Anim {
                    speed: "fast"
                }
            }
            Behavior on scale {
                Anim {
                    speed: "fast"
                }
            }
        }
    }
}
