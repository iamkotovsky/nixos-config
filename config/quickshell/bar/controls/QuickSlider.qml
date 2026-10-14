import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ".."

// Icon button + slider + percent label, GNOME quick-settings style.
// `value` is 0-1 and follows the outside state except while dragging.
RowLayout {
    id: root

    property string icon
    property real value: 0
    property real from: 0
    property bool dimmed: false

    signal moved(real value)
    signal iconClicked(var mouse)

    spacing: Theme.spacingMedium

    IconButton {
        icon: root.icon
        iconColor: root.dimmed ? Theme.muted : Theme.foreground
        onClicked: mouse => root.iconClicked(mouse)
    }

    Slider {
        id: slider

        Layout.fillWidth: true
        from: root.from
        to: 1
        onMoved: root.moved(value)

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            implicitHeight: 6
            height: implicitHeight
            radius: height / 2
            color: Qt.alpha(Theme.muted, 0.25)

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: root.dimmed ? Theme.muted : Theme.accent
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 16
            implicitHeight: 16
            radius: width / 2
            color: Theme.foreground
        }
    }

    // Follow the real value, but don't fight the user mid-drag.
    Binding {
        target: slider
        property: "value"
        value: root.value
        when: !slider.pressed
    }

    BarText {
        Layout.preferredWidth: 48
        horizontalAlignment: Text.AlignRight
        text: Math.round(slider.value * 100) + "%"
        color: root.dimmed ? Theme.muted : Theme.foreground
    }
}
