import QtQuick

// Active keyboard layout (EN/RU) from niri; click switches to the next one.
Pill {
    visible: NiriEvents.layoutCode !== ""
    interactive: true
    onClicked: NiriEvents.switchLayout()

    BarText {
        text: NiriEvents.layoutCode
    }
}
