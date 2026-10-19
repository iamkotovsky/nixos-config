import QtQuick
import Quickshell
import "../ui"

// HH:MM; click toggles the weekday/date form.
Pill {
    id: root

    property bool showDate: false

    interactive: true
    onClicked: root.showDate = !root.showDate

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    BarText {
        fadeText: true
        text: root.showDate ? Qt.formatDate(clock.date, "dddd, dd MMMM") : Qt.formatTime(clock.date, "hh:mm")
    }
}
