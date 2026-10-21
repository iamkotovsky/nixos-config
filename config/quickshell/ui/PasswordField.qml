import QtQuick
import ".."

// Password entry: a frosted chip with hidden text and a show/hide toggle.
// Enter accepts, Esc cancels; `error` gives it a red rim and `shake()` nudges
// it side to side (wrong password). `neutral` swaps the accent focus rim for a
// brighter light rim (the lock screen, where the field always has focus, so
// the accent would mean nothing). Selected text is always neutral.
Glass {
    id: root

    property bool error: false
    property bool reveal: false
    property bool neutral: false
    property alias text: input.text

    signal accepted(string text)
    signal canceled

    function shake() {
        shakeAnimation.restart();
    }

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: Theme.fieldHeight
    radius: Theme.radiusMedium
    color: Qt.alpha(Theme.foreground, Theme.fillRest)
    border.color: {
        if (error)
            return Theme.red;
        if (!input.activeFocus)
            return Qt.alpha(Theme.foreground, Theme.fillRim);
        return neutral ? Qt.alpha(Theme.foreground, Theme.focusRimOpacity) : Theme.accent;
    }
    highlight: false

    Behavior on border.color {
        ColorFade {}
    }

    transform: Translate {
        id: nudge
    }

    SequentialAnimation {
        id: shakeAnimation

        loops: 2

        NumberAnimation {
            target: nudge
            property: "x"
            to: Theme.spacingSmall
            duration: Theme.durationFast / 3
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: nudge
            property: "x"
            to: -Theme.spacingSmall
            duration: Theme.durationFast / 3
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: nudge
            property: "x"
            to: 0
            duration: Theme.durationFast / 3
            easing.type: Easing.InCubic
        }
    }

    TextInput {
        id: input

        anchors {
            left: parent.left
            right: eye.left
            leftMargin: Theme.spacingMedium
            rightMargin: Theme.spacingSmall
            verticalCenter: parent.verticalCenter
        }
        clip: true
        color: Theme.foreground
        selectionColor: Qt.alpha(Theme.foreground, Theme.trackOpacity)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        echoMode: root.reveal ? TextInput.Normal : TextInput.Password
        onTextChanged: root.error = false
        onAccepted: {
            if (text !== "")
                root.accepted(text);
        }
        Keys.onEscapePressed: event => {
            root.canceled();
            event.accepted = true;
        }

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: "Password"
            color: Theme.muted
            font.pixelSize: Theme.fontSmall
        }
    }

    Item {
        id: eye

        anchors {
            right: parent.right
            rightMargin: Theme.spacingMedium
            verticalCenter: parent.verticalCenter
        }
        implicitWidth: Theme.iconSize
        implicitHeight: Theme.iconSize

        StateLayer {
            outset: Theme.spacingXs
            lift: false
            onClicked: root.reveal = !root.reveal
        }

        MaterialIcon {
            anchors.centerIn: parent
            name: root.reveal ? "visibility_off" : "visibility"
            color: Theme.muted
        }
    }
}
