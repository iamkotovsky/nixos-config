pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import ".."
import "../controls"
import "../services"

// Bluetooth devices: click to connect/disconnect, or pair a new one found by
// discovery (running while this page is open). Hover a paired one to forget.
ColumnLayout {
    spacing: Theme.spacingMedium

    PageHeader {
        Layout.fillWidth: true
        title: "Bluetooth"
        busy: BluetoothState.enabled && (BluetoothState.adapter?.discovering ?? false)
        showSwitch: true
        checked: BluetoothState.enabled
        onBack: ControlCenter.back()
        onToggled: BluetoothState.toggle()
    }

    BarText {
        Layout.fillWidth: true
        Layout.margins: Theme.spacingMedium
        visible: !BluetoothState.enabled || BluetoothState.devices.length === 0
        text: BluetoothState.enabled ? "Looking for devices…" : "Bluetooth is off"
        color: Theme.muted
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
    }

    ScrollList {
        Layout.fillWidth: true
        visible: BluetoothState.enabled
        model: ScriptModel {
            values: BluetoothState.devices
        }

        delegate: ListRow {
            id: row

            required property var modelData

            width: ListView.view.width
            icon: BluetoothState.deviceIcon(modelData)
            title: modelData.name
            subtitle: {
                const d = modelData;
                if (d.pairing)
                    return "Pairing…";
                if (d.connected)
                    return "Connected";
                return d.paired ? "Paired" : "";
            }
            active: modelData.connected
            showCheck: false
            busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
            onClicked: BluetoothState.activate(modelData)

            // Battery for devices that report it (headphones, mice).
            BarText {
                visible: row.modelData.batteryAvailable
                text: Math.round(row.modelData.battery * 100) + "%"
                color: Theme.muted
                font.pixelSize: Theme.fontCaption
            }

            // One slot at the end: forget (a paired device, on hover), else the
            // check (connected).
            Item {
                id: slot

                readonly property bool forgetting: row.modelData.paired && (row.hovered || forgetLayer.containsMouse)

                implicitWidth: Theme.iconSize
                implicitHeight: Theme.iconSize

                StateLayer {
                    id: forgetLayer

                    enabled: row.modelData.paired
                    visible: row.modelData.paired
                    outset: Theme.spacingXs
                    lift: false
                    onClicked: BluetoothState.forget(row.modelData)
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    name: "delete"
                    color: Theme.muted
                    opacity: slot.forgetting ? 1 : 0
                    scale: slot.forgetting ? 1 : Theme.pressScale

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.durationFast
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.durationFast
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    name: "check"
                    color: Theme.accent
                    opacity: row.modelData.connected && !slot.forgetting ? 1 : 0
                    scale: row.modelData.connected && !slot.forgetting ? 1 : Theme.pressScale

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.durationFast
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.durationFast
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
