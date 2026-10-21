pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."
import "../ui"
import "../services"

// One notification popup: a glass card like the control panel. Hovering lifts
// it and pauses its timeout (there is no visible countdown); clicking runs the
// app's default action (or just dismisses). Critical ones get a red border
// and stay until dismissed.
Glass {
    id: card

    required property var notification

    // Snapshot of the fields shown. The Notification object is destroyed as
    // soon as it closes, while the card still animates out; bindings read this
    // instead, refreshed whenever the app updates the notification in place.
    // Filled at creation (not later) so the list lays the card out at its
    // real height straight away.
    property var info: snapshot(notification)

    function snapshot(n) {
        return {
            appName: n.appName,
            appIcon: n.appIcon,
            desktopEntry: n.desktopEntry,
            summary: n.summary,
            body: n.body,
            image: n.image,
            urgency: n.urgency,
            expireTimeout: n.expireTimeout,
            actions: n.actions
        };
    }

    function capture() {
        if (notification)
            card.info = snapshot(notification);
    }

    // Turn the initial binding into a plain value, so a closing (null)
    // notification never blanks the card mid-animation.
    Component.onCompleted: capture()

    Connections {
        target: card.notification

        function onSummaryChanged() {
            card.capture();
        }

        function onBodyChanged() {
            card.capture();
        }

        function onImageChanged() {
            card.capture();
        }

        function onAppIconChanged() {
            card.capture();
        }

        function onActionsChanged() {
            card.capture();
        }
    }

    readonly property int timeout: info.summary === undefined ? 0 : Notifications.timeout(info)
    readonly property bool critical: info.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: (info.actions ?? []).find(a => a.identifier === "default") ?? null
    readonly property var buttons: (info.actions ?? []).filter(a => a.identifier !== "default")

    // Set once the notification is going away (dismissed, expired, or closed
    // by the app). From then on the card only animates out: it ignores input
    // and never touches the notification again, which may already be gone.
    property bool closing: false

    enabled: !closing
    // Covers every way out, including the app closing it.
    ListView.onRemove: closing = true

    function dismiss() {
        if (card.closing || !card.notification)
            return;
        card.closing = true;
        card.notification.dismiss();
    }
    // Driven by the countdown below: a NumberAnimation is used as a timer
    // because, unlike Timer, it can pause (while hovered).
    property real countdown: 1

    // App icon: explicit icon (name or path), else the app's desktop entry.
    readonly property string iconSource: Icons.resolve(info.appIcon, info.desktopEntry || info.appName)

    width: Theme.notificationWidth
    implicitHeight: content.implicitHeight + Theme.spacingLarge * 2
    radius: Theme.radiusLarge
    level: "overlay"
    elevation: "raised"
    border.color: critical ? Theme.red : Qt.alpha(Theme.foreground, Theme.rimOpacity)

    HoverHandler {
        id: hover
    }

    // Counts down to expiry; paused while hovered.
    NumberAnimation {
        target: card
        property: "countdown"
        from: 1
        to: 0
        duration: card.timeout
        running: card.timeout > 0 && !card.closing
        // Only meaningful while counting down; critical cards have no timer.
        paused: card.timeout > 0 && hover.hovered
        onFinished: {
            if (card.closing || !card.notification)
                return;
            card.closing = true;
            card.notification.expire();
        }
    }

    StateLayer {
        squash: false
        onClicked: {
            if (!card.closing && card.notification && card.defaultAction)
                card.defaultAction.invoke();
            card.dismiss();
        }
    }

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacingLarge
        }
        spacing: Theme.spacingSmall

        NotificationHeader {
            Layout.fillWidth: true
            iconSource: card.iconSource
            appName: card.info.appName ?? ""
            hovered: hover.hovered
            onCloseClicked: card.dismiss()
        }

        // Summary and body, with the notification image on the right.
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingMedium

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXs

                BarText {
                    Layout.fillWidth: true
                    text: card.info.summary ?? ""
                    font.bold: true
                    font.pixelSize: Theme.fontTitle
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                BarText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: card.info.body ?? ""
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    color: Qt.alpha(Theme.foreground, Theme.subtleTextOpacity)
                    font.pixelSize: Theme.fontSmall
                    linkColor: Theme.accent
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }
            }

            ClippingRectangle {
                visible: (card.info.image ?? "") !== ""
                implicitWidth: Theme.thumbnailSize
                implicitHeight: Theme.thumbnailSize
                radius: Theme.radiusSmall
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: card.info.image ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
        }

        NotificationActions {
            Layout.fillWidth: true
            buttons: card.buttons
            onTriggered: action => {
                if (!card.closing && card.notification)
                    action.invoke();
                card.dismiss();
            }
        }
    }
}
