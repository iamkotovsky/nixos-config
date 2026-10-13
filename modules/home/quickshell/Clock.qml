import QtQuick
import Quickshell

// Waybar clock: "14:09" HH:MM with click to swap to the weekday/date form
// (waybar format / format-alt).
Pill {
    id: root

    property bool showDate: false

    contentImplicitWidth: label.implicitWidth

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    function pad2(n) {
        return ("0" + n).slice(-2);
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: root.showDate ? clock.date.toString("ddd, dd MMM") : root.pad2(clock.hours) + ":" + root.pad2(clock.minutes)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.showDate = !root.showDate
    }
}
