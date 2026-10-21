import QtQuick
import ".."

// Search entry: the same frosted chip as PasswordField, with a leading search
// glyph. Enter accepts, Esc cancels; Up/Down, Tab/Shift+Tab and Ctrl+J/K
// report `moved(delta)` so a list below can follow the keyboard. Focused, it
// gets the neutral light rim: it is the only thing taking keys where it is
// used, so the accent would add nothing.
Glass {
    id: root

    property alias text: input.text
    property string placeholder: "Search"
    property int textSize: Theme.fontSize
    property int glyphSize: Theme.iconSize
    // Inset of the glyph, and the gap from it to the text (the launcher
    // widens both to line up with its rows' icons and titles).
    property int glyphMargin: Theme.spacingMedium
    property int glyphGap: Theme.spacingSmall

    signal accepted
    signal canceled
    signal moved(int delta)

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: Theme.fieldHeight
    radius: Theme.radiusMedium
    color: Qt.alpha(Theme.foreground, Theme.fillRest)
    border.color: Qt.alpha(Theme.foreground, input.activeFocus ? Theme.focusRimOpacity : Theme.fillRim)
    highlight: false

    Behavior on border.color {
        ColorFade {}
    }

    MaterialIcon {
        id: glyph

        anchors {
            left: parent.left
            leftMargin: root.glyphMargin
            verticalCenter: parent.verticalCenter
        }
        name: "search"
        size: root.glyphSize
        color: Theme.muted
    }

    TextInput {
        id: input

        anchors {
            left: glyph.right
            right: parent.right
            leftMargin: root.glyphGap
            rightMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        clip: true
        color: Theme.foreground
        selectionColor: Qt.alpha(Theme.foreground, Theme.trackOpacity)
        selectByMouse: true
        font.family: Theme.fontFamily
        font.pixelSize: root.textSize
        onAccepted: root.accepted()

        Keys.onPressed: event => {
            const ctrl = event.modifiers & Qt.ControlModifier;
            let delta = 0;
            if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J))
                delta = 1;
            else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K))
                delta = -1;
            else if (event.key === Qt.Key_Tab)
                delta = 1;
            else if (event.key === Qt.Key_Backtab)
                delta = -1;
            else if (event.key === Qt.Key_Escape) {
                root.canceled();
                event.accepted = true;
                return;
            }
            if (delta !== 0) {
                root.moved(delta);
                event.accepted = true;
            }
        }

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: root.placeholder
            color: Theme.muted
            font.pixelSize: root.textSize
        }
    }
}
