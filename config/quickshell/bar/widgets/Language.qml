import QtQuick
import ".."
import "../ui"
import "../services"

// Active keyboard layout (EN/RU) from niri; click switches to the next one.
Pill {
    visible: NiriEvents.layoutCode !== ""
    interactive: true
    spacing: Theme.spacingXs
    onClicked: NiriEvents.switchLayout()

    // Filled, like the other bar status glyphs.
    MaterialIcon {
        name: "public"
        filled: true
    }

    BarText {
        fadeText: true
        text: NiriEvents.layoutCode
    }
}
