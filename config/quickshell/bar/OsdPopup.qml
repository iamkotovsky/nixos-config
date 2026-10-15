import QtQuick
import Quickshell
import Quickshell.Wayland
import "services"

// Floating volume/brightness slider, bottom center of the screen in use.
// Display only: the empty input mask lets clicks pass straight through.
PanelWindow {
    id: osd

    required property string screenName

    // Shown on the screen in use; the window stays mapped until the fade-out ends.
    // Compares a plain name, not `screen`, which mapping the window re-evaluates.
    readonly property bool active: Osd.shown && Osd.output === screenName
    readonly property bool volume: Osd.kind === "volume"
    readonly property real value: volume ? Math.min(Audio.volume, 1) : Brightness.percent / 100
    readonly property bool dimmed: volume && Audio.muted

    anchors.bottom: true
    // Room for the card's shadow on every side; the card floats a few gaps
    // above the bottom edge.
    implicitWidth: Theme.osdWidth + Theme.shadowPad * 2
    implicitHeight: Theme.osdHeight + Theme.shadowPad + Theme.gap * 6
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    visible: active || card.opacity > 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"

    // Follows the card's scale (around its center) and slide by hand: an
    // item-bound Region ignores transforms. Dropped as soon as it starts hiding.
    BackgroundEffect.blurRegion: active ? cardBlur : noBlur

    Region {
        id: cardBlur

        x: card.x + card.width * (1 - card.scale) / 2
        y: card.y + card.height * (1 - card.scale) / 2 + slide.y
        width: card.width * card.scale
        height: card.height * card.scale
        radius: card.radius * card.scale
    }

    Region {
        id: noBlur
    }

    Glass {
        id: card

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Theme.shadowPad
        }
        width: Theme.osdWidth
        height: Theme.osdHeight
        // Same rounding as the bar pills.
        radius: Theme.radiusMedium
        level: "overlay"
        elevation: "floating"

        // Springs up in; sinks and fades out quicker, no bounce.
        opacity: osd.active ? 1 : 0
        scale: osd.active ? 1 : Theme.pressScale
        transform: Translate {
            id: slide

            y: osd.active ? 0 : Theme.spacingMedium

            Behavior on y {
                NumberAnimation {
                    duration: osd.active ? Theme.durationSlow : Theme.exitDuration(Theme.durationSlow)
                    easing.type: osd.active ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: Theme.overshoot
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: osd.active ? Theme.durationNormal : Theme.exitDuration(Theme.durationNormal)
                easing.type: osd.active ? Easing.OutCubic : Easing.InCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: osd.active ? Theme.durationSlow : Theme.exitDuration(Theme.durationSlow)
                easing.type: osd.active ? Easing.OutBack : Easing.InCubic
                easing.overshoot: Theme.overshoot
            }
        }

        MaterialIcon {
            id: icon

            anchors {
                left: parent.left
                leftMargin: Theme.spacingLarge
                verticalCenter: parent.verticalCenter
            }
            name: osd.volume ? Audio.icon : Brightness.icon
            color: osd.dimmed ? Theme.muted : Theme.foreground

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durationFast
                }
            }
        }

        BarText {
            id: label

            anchors {
                right: parent.right
                rightMargin: Theme.spacingLarge
                verticalCenter: parent.verticalCenter
            }
            width: Theme.percentWidth
            horizontalAlignment: Text.AlignRight
            text: Math.round(osd.value * 100) + "%"
            color: osd.dimmed ? Theme.muted : Theme.foreground
        }

        // Track + fill, display only.
        Rectangle {
            anchors {
                left: icon.right
                right: label.left
                leftMargin: Theme.spacingMedium
                rightMargin: Theme.spacingMedium
                verticalCenter: parent.verticalCenter
            }
            height: Theme.sliderTrack
            radius: height / 2
            color: Qt.alpha(Theme.muted, Theme.trackOpacity)

            Rectangle {
                width: parent.width * osd.value
                height: parent.height
                radius: parent.radius
                color: osd.dimmed ? Theme.muted : Theme.accent

                Behavior on width {
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
    }
}
