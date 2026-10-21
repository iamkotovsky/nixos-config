import QtQuick
import ".."

// Rounded Material Symbols glyph, picked by ligature name, e.g.
// MaterialIcon { name: "volume_up" }. Outlined by default; solid status
// glyphs (Wi-Fi, Bluetooth, battery, volume, brightness) and checks are
// filled, since their shapes read better solid. Set `size`, not
// font.pixelSize: the optical size follows it, so small icons get sturdier
// strokes.
Text {
    id: root

    property string name
    property int size: Theme.iconSize
    property bool filled: /^(network_wifi|signal_wifi|wifi|bluetooth|battery|volume|brightness|check$|lan$)/.test(name)

    text: name
    color: Theme.foreground
    font.family: Theme.iconFont
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": root.filled ? 1 : 0,
            "wght": Theme.iconWeight,
            "opsz": Math.max(20, Math.min(48, root.size))
        })
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    // State colour changes (on/off, muted, connected) fade everywhere; don't
    // add another Behavior on color where it is used.
    Behavior on color {
        ColorFade {}
    }
}
