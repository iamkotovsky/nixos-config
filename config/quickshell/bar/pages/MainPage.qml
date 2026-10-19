import QtQuick
import QtQuick.Layouts
import ".."
import "../ui"
import "../services"

// The control panel's main page: battery, volume and brightness, and the
// quick toggles. Sub-pages open from the chevrons.
ColumnLayout {
    spacing: Theme.spacingLarge

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
            onPageRequested: ControlCenter.openPage(ControlCenter.soundPage)
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
                onPageRequested: ControlCenter.openPage(ControlCenter.wifiPage)
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
                onPageRequested: ControlCenter.openPage(ControlCenter.bluetoothPage)
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
