import QtQuick
import Quickshell
import Quickshell.Wayland
import "services"

// Notification popups, top right under the bar, on the screen in use. New
// cards spring in from the right; the rest glide into place when one closes.
// Only the cards take input and get frosted; the window leaves room around
// them for their shadows.
PanelWindow {
    id: popups

    required property string screenName

    // Where the first card's top edge goes: below the bar's strip (gap + pill
    // + gap), plus one gap.
    readonly property int cardsTop: Theme.gap * 3 + Theme.pillHeight

    anchors {
        top: true
        right: true
    }
    margins.top: Math.max(0, cardsTop - Theme.shadowPad)
    implicitWidth: Theme.notificationWidth + Theme.gap + Theme.shadowPad
    implicitHeight: Math.max(1, list.y + list.contentHeight + Theme.shadowPad)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: Notifications.popups.length > 0 && Osd.output === screenName
    mask: Region {
        item: list
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    // One rounded region per card, so the gaps between cards stay clear.
    BackgroundEffect.blurRegion: Region {
        regions: list.contentItem.children.filter(child => child.blurRegion !== undefined).map(child => child.blurRegion)
    }

    ListView {
        id: list

        x: Theme.shadowPad
        y: popups.cardsTop - popups.margins.top
        width: Theme.notificationWidth
        height: contentHeight
        interactive: false
        spacing: Theme.gap
        model: ScriptModel {
            values: Notifications.popups
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

        remove: Transition {
            NumberAnimation {
                property: "x"
                to: Theme.notificationWidth
                duration: Theme.exitDuration(Theme.durationSlow)
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: Theme.exitDuration(Theme.durationNormal)
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
