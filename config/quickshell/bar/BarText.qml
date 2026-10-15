import QtQuick

// Text in the UI font, foreground color by default. Tabular digits keep
// clocks and percentages from shifting as they change.
Text {
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.features: ({
            "tnum": 1
        })
    verticalAlignment: Text.AlignVCenter
}
