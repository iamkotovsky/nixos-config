import QtQuick
import QtQuick.Layouts
import ".."

// Sub-page header: back button, title, an optional busy spinner (scanning)
// and an optional on/off switch.
RowLayout {
    id: root

    property string title
    property bool busy: false
    property bool showSwitch: false
    property bool checked: false

    signal back
    signal toggled

    spacing: Theme.spacingMedium

    IconButton {
        icon: "arrow_back"
        onClicked: root.back()
    }

    BarText {
        Layout.fillWidth: true
        text: root.title
        font.pixelSize: Theme.fontTitle
        font.bold: true
        elide: Text.ElideRight
    }

    Spinner {
        visible: root.busy
    }

    Switch {
        visible: root.showSwitch
        checked: root.checked
        onToggled: root.toggled()
    }
}
