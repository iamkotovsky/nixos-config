import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../notifications"
import "../services"

// Notification popups, bottom right corner of the screen in use: the newest
// card sits one gap from the corner and older ones stack upward. New cards
// spring in from the right; the rest glide into place when one closes.
// Only the cards take input and get frosted.
PanelWindow {
    id: popups

    required property string screenName

    // Cards sit two gaps in from the screen edges: one gap inside a tiled
    // window's border instead of right on top of it (and its focus ring),
    // which also leaves room below and to the right for the shadow. To the
    // left the window keeps a full shadow pad.
    readonly property int inset: Theme.gap * 2
    // One rounded region per card (leaving ones included), for the input mask
    // and the blur, so the gaps between cards stay clear.
    readonly property var cardRegions: list.contentItem.children.filter(child => child.blurRegion !== undefined).map(child => child.blurRegion)

    // Always mapped, a fixed full-height column on the right edge, and never
    // resized: every resize or unmap/remap of a layer surface is a new
    // configure round-trip (and niri fades closing layers), which made cards
    // stutter, vanish mid-animation and flash back. The window is fully
    // transparent; the input mask and blur cover only the cards, so it costs
    // nothing and clicks pass through everywhere else.
    anchors {
        top: true
        bottom: true
        right: true
    }
    implicitWidth: Theme.shadowPad + Theme.notificationWidth + inset
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    // Only the cards take input; the rest of the column passes clicks through.
    mask: Region {
        regions: popups.cardRegions
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    BackgroundEffect.blurRegion: Region {
        regions: popups.cardRegions
    }

    ListView {
        id: list

        // Fills the whole column (cards stack from the bottom). Sized to its
        // content instead, the list shrinks as a card is removed, the leaving
        // card falls outside it, and ListView destroys it mid-animation.
        anchors {
            top: parent.top
            bottom: parent.bottom
            bottomMargin: popups.inset
        }
        x: Theme.shadowPad
        width: Theme.notificationWidth
        interactive: false
        // Newest (first) at the bottom, nearest the corner.
        verticalLayoutDirection: ListView.BottomToTop
        spacing: Theme.gap
        model: ScriptModel {
            // Only on the screen in use; switching screens moves the cards.
            values: Osd.output === popups.screenName ? Notifications.popups : []
        }

        delegate: NotificationCard {
            required property var modelData

            notification: modelData
        }

        add: Transition {
            NumberAnimation {
                property: "x"
                from: Theme.notificationWidth
                to: 0
                duration: Theme.durationSlow
                easing.type: Easing.OutBack
                easing.overshoot: Theme.overshoot
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
        }

        // Slides off the screen edge without fading: the card's blur can't
        // fade, so a faded card would leave a ghost frost rectangle behind.
        remove: Transition {
            NumberAnimation {
                property: "x"
                to: Theme.notificationWidth + popups.inset
                duration: Theme.exitDuration(Theme.durationSlow)
                easing.type: Easing.InCubic
            }
        }

        // Also finishes x/opacity: a card still sliding in when the next one
        // arrives would otherwise stop half-faded.
        displaced: Transition {
            NumberAnimation {
                property: "y"
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "x"
                to: 0
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                to: 1
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
        }
    }
}
