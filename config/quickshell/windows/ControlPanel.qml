import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../ui"
import "../pages"
import "../services"

// GNOME-style quick settings for one screen. The window covers the whole
// screen (transparent) so a click anywhere outside the card closes it; this
// replaces Hyprland's focus grab, which niri doesn't have. Esc steps back out
// of a sub-page, then closes.
PanelWindow {
    id: panel

    required property string screenName

    readonly property bool open: ControlCenter.openOn === screenName

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    // Always mapped: a window mapped on demand is a new surface each time and
    // its first frames lag behind the compositor (the blur showed before the
    // card). Closed, it is fully transparent and takes no input or focus.
    visible: true
    mask: open ? null : passThrough

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-panel"
    // Exclusive while open so Esc reaches the panel; it's transient anyway.
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    BackgroundEffect.blurRegion: card.liveBlurRegion

    Region {
        id: passThrough
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ControlCenter.close()
    }

    // Springs down out of the status button.
    PopupSurface {
        id: card

        anchors {
            top: parent.top
            right: parent.right
            // One gap below the pills, right edge aligned with the bar.
            topMargin: Theme.gap * 2 + Theme.pillHeight
            rightMargin: Theme.gap
        }
        width: Theme.panelWidth
        height: pages.height
        radius: Theme.radiusLarge
        level: "overlay"
        elevation: "floating"
        shown: panel.open
        transformOrigin: Item.TopRight
        slideFrom: -Theme.spacingSmall

        focus: true
        Keys.onEscapePressed: ControlCenter.page !== "" ? ControlCenter.back() : ControlCenter.close()

        // The window outlives each opening, so take focus again every time.
        onShownChanged: {
            if (shown)
                forceActiveFocus();
        }

        // Keep Esc working after a sub-page (or its text field) had focus.
        Connections {
            target: ControlCenter

            function onPageChanged() {
                card.forceActiveFocus();
            }
        }

        // Swallow clicks so they don't reach the close area behind the card.
        MouseArea {
            anchors.fill: parent
        }

        PageStack {
            id: pages

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            padding: Theme.spacingLarge
            current: ControlCenter.page
            main: Component {
                MainPage {}
            }
            pages: ({
                    [ControlCenter.wifiPage]: wifiPage,
                    [ControlCenter.soundPage]: soundPage,
                    [ControlCenter.bluetoothPage]: bluetoothPage,
                    [ControlCenter.powerPage]: powerPage
                })
        }

        Component {
            id: wifiPage

            WifiPage {}
        }

        Component {
            id: soundPage

            SoundPage {}
        }

        Component {
            id: bluetoothPage

            BluetoothPage {}
        }

        Component {
            id: powerPage

            PowerPage {}
        }
    }
}
