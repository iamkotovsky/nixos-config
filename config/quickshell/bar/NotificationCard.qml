pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "services"
import "controls"

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
    property real remaining: 1

    // App icon: explicit icon (name or path), else the app's desktop entry.
    readonly property string iconSource: {
        const icon = info.appIcon ?? "";
        if (icon.startsWith("/"))
            return "file://" + icon;
        if (icon.startsWith("file://") || icon.startsWith("image://"))
            return icon;
        if (icon !== "")
            return Quickshell.iconPath(icon, true);
        const entry = DesktopEntries.heuristicLookup(info.desktopEntry || info.appName || "");
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

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
        property: "remaining"
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

        // App icon, app name, close button.
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            IconImage {
                visible: card.iconSource !== ""
                implicitSize: Theme.iconSize
                source: card.iconSource
                asynchronous: true
            }

            MaterialIcon {
                visible: card.iconSource === ""
                name: "notifications"
                color: Theme.muted
            }

            BarText {
                Layout.fillWidth: true
                text: card.info.appName || "Notification"
                color: Theme.muted
                font.pixelSize: Theme.fontCaption
                elide: Text.ElideRight
            }

            IconButton {
                implicitWidth: Theme.smallButtonSize
                implicitHeight: Theme.smallButtonSize
                opacity: hover.hovered ? 1 : 0
                icon: "close"
                onClicked: card.dismiss()

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durationFast
                    }
                }
            }
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

        // Action buttons (except the default action, which is the card click).
        RowLayout {
            Layout.fillWidth: true
            visible: card.buttons.length > 0
            spacing: Theme.spacingSmall

            Repeater {
                model: card.buttons

                delegate: Glass {
                    id: button

                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: Theme.chipHeight
                    radius: height / 2
                    color: Qt.alpha(Theme.foreground, Theme.fillRest)
                    border.color: Qt.alpha(Theme.foreground, Theme.fillRim)
                    highlight: false

                    StateLayer {
                        onClicked: {
                            if (!card.closing && card.notification)
                                button.modelData.invoke();
                            card.dismiss();
                        }
                    }

                    BarText {
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingLarge
                        horizontalAlignment: Text.AlignHCenter
                        text: button.modelData.text
                        font.pixelSize: Theme.fontSmall
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
