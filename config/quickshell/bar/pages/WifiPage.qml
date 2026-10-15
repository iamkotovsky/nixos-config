pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../controls"
import "../services"

// Wi-Fi networks: click to connect (or disconnect the current one); a new
// secured network asks for its password inline. Hover a saved one to forget.
ColumnLayout {
    id: page

    // The network whose password field is open.
    property var asking: null

    spacing: Theme.spacingMedium

    PageHeader {
        Layout.fillWidth: true
        title: "Wi-Fi"
        busy: Network.wifiEnabled && Network.networks.length === 0
        showSwitch: true
        checked: Network.wifiEnabled
        onBack: ControlCenter.back()
        onToggled: Network.toggleWifi()
    }

    BarText {
        Layout.fillWidth: true
        Layout.margins: Theme.spacingMedium
        visible: !Network.wifiEnabled
        text: "Wi-Fi is off"
        color: Theme.muted
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
    }

    ScrollList {
        Layout.fillWidth: true
        visible: Network.wifiEnabled
        model: ScriptModel {
            values: Network.networks
        }

        delegate: ColumnLayout {
            id: entry

            required property var modelData
            readonly property bool asking: page.asking === modelData

            width: ListView.view.width
            spacing: 0

            ListRow {
                id: row

                Layout.fillWidth: true
                icon: Network.signalIcon(entry.modelData)
                title: entry.modelData.name
                subtitle: {
                    const n = entry.modelData;
                    if (n.stateChanging)
                        return n.connected ? "Disconnecting…" : "Connecting…";
                    if (n.connected)
                        return "Connected";
                    return n.known ? "Saved" : "";
                }
                active: entry.modelData.connected
                showCheck: false
                busy: entry.modelData.stateChanging
                onClicked: {
                    const n = entry.modelData;
                    if (n.connected)
                        n.disconnect();
                    else if (n.known || !Network.secured(n))
                        Network.connectTo(n);
                    else
                        page.asking = entry.asking ? null : n;
                }

                // One slot at the end: forget (a saved network, on hover), else
                // the check (connected), else a lock (needs a password first).
                Item {
                    id: slot

                    readonly property bool forgetting: entry.modelData.known && (row.hovered || forgetLayer.containsMouse)
                    readonly property string shown: forgetting ? "forget" : entry.modelData.connected ? "check" : !entry.modelData.known && Network.secured(entry.modelData) ? "lock" : ""

                    implicitWidth: Theme.iconSize
                    implicitHeight: Theme.iconSize

                    StateLayer {
                        id: forgetLayer

                        enabled: entry.modelData.known
                        visible: entry.modelData.known
                        outset: Theme.spacingXs
                        lift: false
                        onClicked: entry.modelData.forget()
                    }

                    Repeater {
                        model: [
                            {
                                key: "forget",
                                glyph: "delete",
                                tint: Theme.muted
                            },
                            {
                                key: "check",
                                glyph: "check",
                                tint: Theme.accent
                            },
                            {
                                key: "lock",
                                glyph: "lock",
                                tint: Theme.muted
                            }
                        ]

                        delegate: MaterialIcon {
                            required property var modelData

                            anchors.centerIn: parent
                            name: modelData.glyph
                            color: modelData.tint
                            opacity: slot.shown === modelData.key ? 1 : 0
                            scale: slot.shown === modelData.key ? 1 : Theme.pressScale

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

            // Password for a new secured network, unfolded under its row.
            Item {
                Layout.fillWidth: true
                implicitHeight: entry.asking ? field.implicitHeight + Theme.spacingSmall * 2 : 0
                clip: true

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Theme.durationNormal
                        easing.type: Easing.OutCubic
                    }
                }

                PasswordField {
                    id: field

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: Theme.spacingSmall
                        leftMargin: Theme.spacingMedium
                        rightMargin: Theme.spacingMedium
                    }
                    onAccepted: password => Network.connectTo(entry.modelData, password)
                    onCanceled: page.asking = null
                }
            }

            onAskingChanged: {
                if (asking) {
                    field.text = "";
                    field.focusInput();
                }
            }

            Connections {
                target: entry.modelData

                // Wrong password (or none accepted): ask again.
                function onConnectionFailed(reason) {
                    if (!entry.asking)
                        page.asking = entry.modelData;
                    field.error = true;
                    field.shake();
                    field.focusInput();
                }

                function onConnectedChanged() {
                    if (entry.modelData.connected && entry.asking)
                        page.asking = null;
                }
            }
        }
    }
}
