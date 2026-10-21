pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../ui"

// A notification's action buttons, as frosted chips sharing the width (the
// default action isn't here: clicking the card runs it).
RowLayout {
    id: actions

    property var buttons: []

    signal triggered(var action)

    visible: buttons.length > 0
    spacing: Theme.spacingSmall

    Repeater {
        model: actions.buttons

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
                onClicked: actions.triggered(button.modelData)
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
