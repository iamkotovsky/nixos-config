import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "services"
import "controls"

// GNOME-style quick settings for one screen. The window covers the whole
// screen (transparent) so a click anywhere outside the card closes it; this
// replaces Hyprland's focus grab, which niri doesn't have. Esc closes too.
PanelWindow {
    id: panel

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-panel"
    // Exclusive while open so Esc reaches the panel; it's transient anyway.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // niri blurs only the card's rounded rectangle, not the whole screen.
    BackgroundEffect.blurRegion: Region {
        item: card
        radius: card.radius
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ControlCenter.close()
    }

    Rectangle {
        id: card

        readonly property int padding: 16

        anchors {
            top: parent.top
            right: parent.right
            // One gap below the pills, right edge aligned with the bar.
            topMargin: Theme.gap * 2 + Theme.pillHeight
            rightMargin: Theme.gap
        }
        width: 360
        height: content.implicitHeight + padding * 2
        radius: Theme.moduleRadius * 1.6
        color: Qt.alpha(Theme.surface, Theme.panelOpacity)
        border.width: 1
        border.color: Qt.alpha(Theme.foreground, 0.08)

        focus: true
        Keys.onEscapePressed: ControlCenter.close()

        // Short fade + slide in.
        opacity: 0
        transform: Translate {
            id: slide

            y: -8

            Behavior on y {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }
        Component.onCompleted: {
            card.opacity = 1;
            slide.y = 0;
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        // Swallow clicks so they don't reach the close area behind the card.
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content

            anchors {
                fill: parent
                margins: card.padding
            }
            spacing: 14

            // Battery and power profile.
            RowLayout {
                Layout.fillWidth: true
                visible: Power.hasBattery
                spacing: 12

                MaterialIcon {
                    name: Power.icon
                    color: Power.levelColor
                    font.pixelSize: Theme.iconSize + 8
                }

                ColumnLayout {
                    spacing: 0

                    BarText {
                        text: Power.capacity + "%"
                        font.bold: true
                    }

                    BarText {
                        text: Power.stateText
                        color: Theme.muted
                        font.pixelSize: Theme.fontSize - 4
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                IconButton {
                    icon: Power.profileIcon
                    active: !Power.balanced
                    onClicked: Power.cycleProfile()
                }
            }

            QuickSlider {
                Layout.fillWidth: true
                visible: Audio.ready
                icon: Audio.icon
                value: Math.min(Audio.volume, 1)
                dimmed: Audio.muted
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
                columnSpacing: 8
                rowSpacing: 8

                ToggleTile {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: Network.wifiIcon
                    title: "Wi-Fi"
                    subtitle: !Network.wifiEnabled ? "Off" : Network.ssid !== "" ? Network.ssid : "Not connected"
                    active: Network.wifiEnabled
                    onClicked: Network.toggleWifi()
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
