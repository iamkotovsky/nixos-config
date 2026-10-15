import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ".."

// Icon button + slider + percent label, GNOME quick-settings style.
// `value` is 0-1 and follows the outside state except while dragging; outside
// changes glide, drags follow the pointer directly. The knob grows on hover.
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

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            implicitHeight: Theme.sliderTrack
            height: implicitHeight
            radius: height / 2
            color: Qt.alpha(Theme.muted, Theme.trackOpacity)

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: root.dimmed ? Theme.muted : Theme.accent

                Behavior on width {
                    enabled: !slider.pressed

                    NumberAnimation {
                        duration: Theme.durationNormal
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durationFast
                    }
                }
            }
        }

        // The knob keeps its layout size and grows by scale: the slider places
        // it using its width, so resizing it would nudge it along the track.
        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: Theme.sliderKnob
            implicitHeight: Theme.sliderKnob
            radius: width / 2
            color: Theme.foreground
            scale: slider.hovered || slider.pressed ? Theme.sliderKnobHover / Theme.sliderKnob : 1

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.durationFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on x {
                enabled: !slider.pressed

                NumberAnimation {
                    duration: Theme.durationNormal
                    easing.type: Easing.OutCubic
                }
            }
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
        Layout.preferredWidth: Theme.percentWidth
        horizontalAlignment: Text.AlignRight
        text: Math.round(slider.value * 100) + "%"
        color: root.dimmed ? Theme.muted : Theme.foreground
    }
}
