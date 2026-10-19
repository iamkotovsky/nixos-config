import QtQuick
import ".."

// Text in the UI font, foreground color by default. Tabular digits keep
// clocks and percentages from shifting as they change.
Text {
    id: root

    // Crossfade when the text changes (time/date, EN/RU). Off by default:
    // on values that change continuously (percentages) it would only lag.
    property bool fadeText: false

    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.features: ({
            "tnum": 1
        })
    verticalAlignment: Text.AlignVCenter

    // Colour changes fade everywhere; don't add another Behavior on color
    // where it is used.
    Behavior on color {
        ColorFade {}
    }

    Behavior on text {
        enabled: root.fadeText

        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: Theme.exitDuration(Theme.durationFast)
                easing.type: Easing.InCubic
            }
            PropertyAction {}
            NumberAnimation {
                target: root
                property: "opacity"
                to: 1
                duration: Theme.durationFast
                easing.type: Easing.OutCubic
            }
        }
    }
}
