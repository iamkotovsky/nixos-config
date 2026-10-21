import QtQuick
import QtQuick.Layouts
import ".."
import "../ui"
import "../services"

// Lock, suspend, log out, restart, shut down (see PowerActions).
ColumnLayout {
    spacing: Theme.spacingMedium

    PageHeader {
        Layout.fillWidth: true
        title: "Power"
        onBack: ControlCenter.back()
    }

    PowerActions {
        Layout.fillWidth: true
    }
}
