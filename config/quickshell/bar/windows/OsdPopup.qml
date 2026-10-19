import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../ui"
import "../services"

// Floating volume/brightness slider, bottom center of the screen in use.
// Display only: the empty input mask lets clicks pass straight through.
PanelWindow {
    id: osd

    required property string screenName

    // Shown on the screen in use. Compares a plain name, not `screen`, which
    // mapping the window re-evaluates.
    readonly property bool active: Osd.shown && Osd.output === screenName
    readonly property bool volume: Osd.kind === Osd.volume
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
    // Always mapped (transparent, no input): a window mapped on demand is a
    // new surface each time, and its first frames lag behind the compositor,
    // so the blur showed up before the card did.
    visible: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"

    BackgroundEffect.blurRegion: card.liveBlurRegion

    // Springs up in; sinks and fades out quicker, no bounce.
    PopupSurface {
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

        shown: osd.active
        slideFrom: Theme.spacingMedium

        MaterialIcon {
            id: icon

            anchors {
                left: parent.left
                leftMargin: Theme.spacingLarge
                verticalCenter: parent.verticalCenter
            }
            name: osd.volume ? Audio.icon : Brightness.icon
            color: osd.dimmed ? Theme.muted : Theme.foreground
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
                    Anim {}
                }

                Behavior on color {
                    ColorFade {}
                }
            }
        }
    }
}
