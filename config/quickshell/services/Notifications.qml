pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import ".."

// The desktop notification server (replaces mako): owns
// org.freedesktop.Notifications while the bar runs. Popups only, no history:
// a notification stays tracked until it expires or is dismissed.
Singleton {
    id: root

    // Newest first, at most 5 on screen at once.
    readonly property var popups: [...server.trackedNotifications.values].reverse().slice(0, 5)

    // Display time in ms, or 0 to stay until dismissed (critical, or the app
    // asked for no timeout). The app default (-1) is Theme.notificationTimeout.
    // Quickshell reports the timeout in seconds; accept milliseconds too, as
    // the spec uses them.
    function timeout(notification) {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;
        const t = notification.expireTimeout;
        if (t === 0)
            return 0;
        if (t < 0)
            return Theme.notificationTimeout;
        return t < 100 ? t * 1000 : t;
    }

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        actionsSupported: true
        persistenceSupported: false

        onNotification: notification => notification.tracked = true
    }
}
