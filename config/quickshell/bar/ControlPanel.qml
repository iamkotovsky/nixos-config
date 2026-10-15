import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "services"
import "controls"
import "pages"

// GNOME-style quick settings for one screen. The window covers the whole
// screen (transparent) so a click anywhere outside the card closes it; this
// replaces Hyprland's focus grab, which niri doesn't have. Esc closes too.
PanelWindow {
    id: panel

    required property string screenName

    readonly property bool open: ControlCenter.openOn === screenName
    // False for the first frame, so the card animates in after creation.
    property bool entered: false
    readonly property bool showing: entered && open

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    // Stays mapped while the card animates out (shell.qml keeps it loaded),
    // letting clicks through meanwhile.
    visible: open || card.opacity > 0
    mask: open ? null : passThrough

    Component.onCompleted: entered = true

    Region {
        id: passThrough
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-panel"
    // Exclusive while open so Esc reaches the panel; it's transient anyway.
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Blur only the card's rounded rectangle, not the whole screen. The rect
    // follows the card's scale (around its top-right corner) and slide by
    // hand: an item-bound Region ignores transforms and would freeze at the
    // first frame. Dropped as soon as closing starts, so no frost outlives the
    // fading card.
    BackgroundEffect.blurRegion: showing ? cardBlur : noBlur

    Region {
        id: cardBlur

        x: card.x + card.width * (1 - card.scale)
        y: card.y + slide.y
        width: card.width * card.scale
        height: card.height * card.scale
        radius: card.radius * card.scale
    }

    Region {
        id: noBlur
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ControlCenter.close()
    }

    Glass {
        id: card

        readonly property int padding: Theme.spacingLarge

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

        focus: true
        // Esc steps back out of a sub-page first.
        Keys.onEscapePressed: ControlCenter.page !== "" ? ControlCenter.back() : ControlCenter.close()

        // Springs down out of the status button; leaves quicker, no bounce.
        opacity: panel.showing ? 1 : 0
        scale: panel.showing ? 1 : Theme.pressScale
        transformOrigin: Item.TopRight
        transform: Translate {
            id: slide

            y: panel.showing ? 0 : -Theme.spacingSmall

            Behavior on y {
                NumberAnimation {
                    duration: panel.showing ? Theme.durationSlow : Theme.exitDuration(Theme.durationSlow)
                    easing.type: panel.showing ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: Theme.overshoot
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: panel.showing ? Theme.durationNormal : Theme.exitDuration(Theme.durationNormal)
                easing.type: panel.showing ? Easing.OutCubic : Easing.InCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: panel.showing ? Theme.durationSlow : Theme.exitDuration(Theme.durationSlow)
                easing.type: panel.showing ? Easing.OutBack : Easing.InCubic
                easing.overshoot: Theme.overshoot
            }
        }

        // Swallow clicks so they don't reach the close area behind the card.
        MouseArea {
            anchors.fill: parent
        }

        // Main page and sub-page side by side; switching slides one out to the
        // left and the other in from the right while the card resizes. Clipped
        // at the card edge (not the padding), so hover shadows stay whole.
        Item {
            id: pages

            readonly property bool sub: ControlCenter.page !== ""
            readonly property real contentWidth: width - card.padding * 2
            // The last sub-page stays loaded while it slides back out.
            property string shownPage: ""

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: (sub ? subPage.implicitHeight : mainPage.implicitHeight) + card.padding * 2
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: Theme.durationNormal
                    easing.type: Easing.OutCubic
                }
            }

            Connections {
                target: ControlCenter

                function onPageChanged() {
                    if (ControlCenter.page !== "")
                        pages.shownPage = ControlCenter.page;
                    card.forceActiveFocus();
                }
            }

            Component.onCompleted: shownPage = ControlCenter.page

            Loader {
                id: subPage

                x: card.padding + (pages.sub ? 0 : pages.width)
                y: card.padding
                width: pages.contentWidth
                opacity: pages.sub ? 1 : 0
                active: pages.shownPage !== ""
                sourceComponent: pages.shownPage === "wifi" ? wifiPage : pages.shownPage === "bluetooth" ? bluetoothPage : soundPage

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.durationNormal
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durationNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Component {
                id: wifiPage

                WifiPage {}
            }

            Component {
                id: bluetoothPage

                BluetoothPage {}
            }

            Component {
                id: soundPage

                SoundPage {}
            }

            ColumnLayout {
                id: mainPage

                x: card.padding - (pages.sub ? pages.width : 0)
                y: card.padding
                width: pages.contentWidth
                opacity: pages.sub ? 0 : 1
                spacing: Theme.spacingLarge

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.durationNormal
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durationNormal
                        easing.type: Easing.OutCubic
                    }
                }

                // Battery level and charge state.
                RowLayout {
                    Layout.fillWidth: true
                    visible: Power.hasBattery
                    spacing: Theme.spacingMedium

                    MaterialIcon {
                        name: Power.icon
                        color: Power.levelColor
                        size: Theme.iconSizeLarge
                    }

                    ColumnLayout {
                        spacing: 0

                        BarText {
                            text: Power.capacity + "%"
                            font.bold: true
                            font.pixelSize: Theme.fontTitle
                        }

                        BarText {
                            text: Power.stateText
                            color: Theme.muted
                            font.pixelSize: Theme.fontCaption
                        }
                    }
                }

                QuickSlider {
                    Layout.fillWidth: true
                    visible: Audio.ready
                    icon: Audio.icon
                    value: Math.min(Audio.volume, 1)
                    dimmed: Audio.muted
                    hasPage: true
                    onPageRequested: ControlCenter.openPage("sound")
                    onMoved: value => Audio.setVolume(value)
                    onIconClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            Audio.openMixer();
                        else
                            Audio.toggleMute();
                    }
                }

                QuickSlider {
                    Layout.fillWidth: true
                    visible: Brightness.available
                    icon: Brightness.icon
                    from: 0.01
                    value: Brightness.percent / 100
                    onMoved: value => Brightness.set(value * 100)
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Theme.spacingSmall
                    rowSpacing: Theme.spacingSmall

                    ToggleTile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        icon: Network.wifiIcon
                        title: "Wi-Fi"
                        subtitle: !Network.wifiEnabled ? "Off" : Network.ssid !== "" ? Network.ssid : "Not connected"
                        active: Network.wifiEnabled
                        onClicked: Network.toggleWifi()
                        hasPage: true
                        onPageRequested: ControlCenter.openPage("wifi")
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        visible: BluetoothState.available
                        icon: BluetoothState.icon
                        title: "Bluetooth"
                        subtitle: !BluetoothState.enabled ? "Off" : BluetoothState.deviceName !== "" ? BluetoothState.deviceName : "On"
                        active: BluetoothState.enabled
                        onClicked: BluetoothState.toggle()
                        hasPage: true
                        onPageRequested: ControlCenter.openPage("bluetooth")
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        icon: Power.profileIcon
                        title: "Power mode"
                        subtitle: Power.profileName
                        // Highlighted when not on the default (balanced) profile.
                        active: !Power.balanced
                        onClicked: Power.cycleProfile()
                    }

                    // Keeps the screen from locking (it still turns off).
                    ToggleTile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        icon: "coffee"
                        title: "Caffeine"
                        subtitle: Caffeine.enabled ? "Won't lock" : "Off"
                        active: Caffeine.enabled
                        onClicked: Caffeine.toggle()
                    }

                    ToggleTile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        visible: Network.wired !== null
                        icon: "lan"
                        title: "Wired"
                        subtitle: "Connected"
                        active: true
                        interactive: false
                    }
                }
            }
        }
    }
}
