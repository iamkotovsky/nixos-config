import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../ui"
import "../widgets"
import "../pages"
import "../services"

// What one screen of the lock shows: the wallpaper blurred and dimmed, clock
// and date, the password field, and keyboard layout / battery / power pills
// in the corner where the bar's status pills sit. Everything springs in; on
// unlock it fades out before the lock is released.
Item {
    id: surface

    property bool checking: false
    property bool failed: false
    property string message: ""
    property int failures: 0
    property bool unlocking: false

    signal submitted(string text)

    // False for the first frame, so everything animates in.
    property bool entered: false
    readonly property bool shown: entered && !unlocking
    // The power menu (suspend, restart, shut down) under the power pill.
    property bool powerOpen: false

    Component.onCompleted: entered = true

    // Wrong password: clear, shake, and take focus back (the field is
    // disabled, and loses focus, while PAM checks).
    onFailuresChanged: {
        field.text = "";
        // After clearing: editing the text resets the error.
        field.error = true;
        field.shake();
        Qt.callLater(field.focusInput);
    }

    // Backdrop: the wallpaper, pre-blurred at build time (Theme.lockBackdrop),
    // dimmed. Loaded synchronously and shown from the first frame, so the lock
    // never flashes an empty screen; it only fades out on unlock.
    Item {
        anchors.fill: parent
        opacity: surface.unlocking ? 0 : 1

        Behavior on opacity {
            Anim {
                leaving: !surface.shown
            }
        }

        Image {
            anchors.fill: parent
            source: Theme.lockBackdrop ? "file://" + Theme.lockBackdrop : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: false
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Theme.background, Theme.lockDim)
        }
    }

    // Clock, date and password, springing up into place.
    ColumnLayout {
        anchors.centerIn: parent
        // Optically centred: a little above the middle.
        anchors.verticalCenterOffset: -Theme.spacingLarge * 3
        spacing: Theme.spacingSmall
        opacity: surface.shown ? 1 : 0

        transform: Translate {
            y: surface.shown ? 0 : Theme.spacingLarge

            Behavior on y {
                Anim {
                    speed: "slow"
                    spring: surface.shown
                    leaving: !surface.shown
                }
            }
        }

        Behavior on opacity {
            Anim {
                leaving: !surface.shown
            }
        }

        SystemClock {
            id: clock

            precision: SystemClock.Minutes
        }

        BarText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(clock.date, "hh:mm")
            font.pixelSize: Theme.lockClockSize
            font.weight: Font.Light
        }

        BarText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(clock.date, "dddd, d MMMM")
            color: Theme.muted
            font.pixelSize: Theme.fontTitle
        }

        PasswordField {
            id: field

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.spacingLarge * 2
            Layout.preferredWidth: Theme.lockFieldWidth
            neutral: true
            enabled: !surface.checking && !surface.unlocking
            onAccepted: text => surface.submitted(text)
            // Typing again clears a power action's failure message.
            onTextChanged: {
                if (text !== "")
                    Session.failure = "";
            }
            // Esc closes the power menu first, then clears the field.
            onCanceled: {
                if (surface.powerOpen)
                    surface.powerOpen = false;
                else
                    text = "";
            }
            Component.onCompleted: focusInput()
        }

        // Checking / wrong password, or a power action closing apps (or
        // stopped by one that wouldn't close: the notification saying so is
        // hidden under the lock). The line keeps its height so nothing jumps.
        BarText {
            readonly property bool error: !surface.checking && !Session.busy && (surface.failed || Session.failure !== "")

            Layout.alignment: Qt.AlignHCenter
            text: {
                if (surface.checking)
                    return "Checking…";
                if (Session.busy)
                    return "Closing apps…";
                if (Session.failure !== "")
                    return Session.failure;
                return surface.failed ? surface.message : " ";
            }
            color: error ? Theme.red : Theme.muted
            font.pixelSize: Theme.fontSmall
        }
    }

    // Keyboard layout, battery and the power menu, where the bar's status
    // pills sit.
    RowLayout {
        anchors {
            top: parent.top
            right: parent.right
            margins: Theme.gap
        }
        spacing: Theme.spacingSmall
        opacity: surface.shown ? 1 : 0

        Behavior on opacity {
            Anim {
                leaving: !surface.shown
            }
        }

        Pill {
            visible: NiriEvents.layoutCode !== ""
            spacing: Theme.spacingXs

            MaterialIcon {
                name: "public"
                filled: true
            }

            BarText {
                fadeText: true
                text: NiriEvents.layoutCode
            }
        }

        Pill {
            visible: Power.hasBattery
            spacing: Theme.spacingXs

            MaterialIcon {
                name: Power.icon
                color: Power.levelColor
                size: Theme.batteryIconSize
            }

            BarText {
                text: Power.capacity + "%"
            }
        }

        Pill {
            interactive: true
            horizontalPadding: (Theme.pillHeight - Theme.iconSize) / 2
            onClicked: surface.powerOpen = !surface.powerOpen

            MaterialIcon {
                name: "power_settings_new"
                color: surface.powerOpen ? Theme.accent : Theme.foreground
            }
        }
    }

    // A click anywhere outside the power menu closes it.
    MouseArea {
        anchors.fill: parent
        enabled: surface.powerOpen
        onClicked: surface.powerOpen = false
    }

    // The power menu, springing down out of the power pill like the control
    // panel. Closing it cancels a countdown.
    PopupSurface {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: Theme.gap * 2 + Theme.pillHeight
            rightMargin: Theme.gap
        }
        width: Theme.panelWidth
        height: powerActions.implicitHeight + Theme.spacingLarge * 2
        radius: Theme.radiusLarge
        level: "overlay"
        elevation: "floating"
        shown: surface.powerOpen && surface.shown
        transformOrigin: Item.TopRight
        slideFrom: -Theme.spacingSmall

        // Swallow clicks so they don't reach the close area behind the card.
        MouseArea {
            anchors.fill: parent
        }

        // No log out (it would close apps with unsaved work for whoever is at
        // the keyboard) and no lock.
        PowerActions {
            id: powerActions

            anchors {
                fill: parent
                margins: Theme.spacingLarge
            }
            ids: [Session.suspend, Session.reboot, Session.poweroff]
        }
    }

    onPowerOpenChanged: {
        if (!powerOpen)
            Session.cancel();
    }

    // Starting an action closes the menu; the status line takes over.
    Connections {
        target: Session

        function onBusyChanged() {
            if (Session.busy)
                surface.powerOpen = false;
        }
    }
}
