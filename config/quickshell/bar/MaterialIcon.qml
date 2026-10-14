import QtQuick

// Rounded Material Symbols glyph, picked by ligature name, e.g.
// MaterialIcon { name: "volume_up" }. Filled by default so small sizes stay solid.
Text {
    property string name
    property bool filled: true

    text: name
    color: Theme.foreground
    font.family: Theme.iconFont
    font.pixelSize: Theme.iconSize
    font.variableAxes: ({
            "FILL": filled ? 1 : 0,
            "wght": 400,
            "opsz": 20
        })
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
