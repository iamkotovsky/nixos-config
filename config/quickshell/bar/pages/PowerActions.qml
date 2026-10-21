pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../ui"
import "../services"

// The power rows, shared by the control panel's Power page and the lock
// screen's power menu. Actions that confirm count down in their row (red
// icon, cancel in the status slot); click the row again to go now.
ColumnLayout {
    id: root

    // Session action ids to show, in Session.actions order.
    property var ids: Session.actions.map(a => a.id)

    spacing: 0

    Repeater {
        model: Session.actions.filter(a => root.ids.includes(a.id))

        delegate: ListRow {
            id: row

            required property var modelData
            readonly property bool pending: Session.pending === modelData.id

            Layout.fillWidth: true
            icon: modelData.icon
            iconColor: pending ? Theme.red : Theme.foreground
            title: pending ? modelData.pendingTitle + " in " + Session.remaining + "…" : modelData.title
            subtitle: pending ? "Click to go now" : ""
            interactive: !Session.busy
            onClicked: Session.request(modelData.id)

            // Cancel, in the row's one status slot; fades in with the
            // countdown.
            IconButton {
                implicitWidth: Theme.smallButtonSize
                implicitHeight: Theme.smallButtonSize
                enabled: row.pending
                opacity: row.pending ? 1 : 0
                icon: "close"
                onClicked: Session.cancel()

                Behavior on opacity {
                    Anim {
                        speed: "fast"
                    }
                }
            }
        }
    }
}
