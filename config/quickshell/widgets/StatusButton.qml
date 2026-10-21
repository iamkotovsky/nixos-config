import QtQuick
import ".."
import "../ui"
import "../services"

// Network, Bluetooth and battery at a glance; click opens the control panel
// for this screen, scroll changes the volume (like GNOME).
Pill {
    id: root

    required property string screenName

    readonly property bool open: ControlCenter.openOn === root.screenName

    interactive: true
    spacing: Theme.spacingMedium
    color: open ? Qt.alpha(Theme.accent, Theme.trackOpacity) : Qt.alpha(Theme.surface, Theme.raisedOpacity)
    onClicked: ControlCenter.toggle(root.screenName)
    onScrolled: delta => Audio.step(delta)

    MaterialIcon {
        name: Network.icon
        color: Network.connected ? Theme.foreground : Theme.muted
    }

    MaterialIcon {
        visible: BluetoothState.available
        name: BluetoothState.icon
        color: BluetoothState.enabled ? Theme.foreground : Theme.muted
    }

    // Icon only; the exact percentage is in the control panel. A bit larger
    // than the others: the horizontal battery glyph is short, so at the
    // shared size it reads smaller than Wi-Fi.
    MaterialIcon {
        visible: Power.hasBattery
        name: Power.icon
        color: Power.levelColor
        size: Theme.batteryIconSize
        // The glyph sits high in its taller box at this size; nudge it to the
        // optical center without affecting the pill's layout.
        transform: Translate {
            y: 1
        }
    }
}
