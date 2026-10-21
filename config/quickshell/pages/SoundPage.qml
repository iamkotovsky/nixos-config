pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../ui"
import "../services"

// Sound: pick the output device, and set each playing app's volume.
ColumnLayout {
    spacing: Theme.spacingMedium

    PageHeader {
        Layout.fillWidth: true
        title: "Sound"
        onBack: ControlCenter.back()
    }

    SectionLabel {
        text: "Output"
    }

    ScrollList {
        Layout.fillWidth: true
        model: ScriptModel {
            values: Audio.outputs
        }

        delegate: ListRow {
            required property var modelData

            width: ListView.view.width
            icon: Audio.outputIcon(modelData)
            title: Audio.nodeName(modelData)
            active: modelData === Audio.sink
            onClicked: Audio.setDefault(modelData)
        }
    }

    SectionLabel {
        text: "Apps"
    }

    BarText {
        Layout.fillWidth: true
        Layout.margins: Theme.spacingMedium
        visible: Audio.apps.length === 0
        text: "No apps playing"
        color: Theme.muted
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        model: ScriptModel {
            values: Audio.apps
        }

        // One slider per app, driving all of its streams together.
        delegate: QuickSlider {
            id: app

            required property var modelData
            readonly property var streams: modelData.streams.filter(s => s.audio !== null)
            readonly property var lead: streams.length > 0 ? streams[0] : null
            readonly property bool muted: lead !== null && lead.audio.muted

            Layout.fillWidth: true
            label: modelData.name
            icon: muted ? "volume_off" : "music_note"
            image: Audio.appIcon(modelData.streams[0])
            value: lead ? Math.min(lead.audio.volume, 1) : 0
            dimmed: muted
            onMoved: value => {
                for (const s of app.streams)
                    s.audio.volume = value;
            }
            onIconClicked: {
                const mute = !app.muted;
                for (const s of app.streams)
                    s.audio.muted = mute;
            }
        }
    }

    // Everything else (inputs, profiles) lives in pavucontrol.
    Item {
        Layout.fillWidth: true
        implicitHeight: settings.implicitHeight + Theme.spacingSmall * 2

        StateLayer {
            lift: false
            radius: Theme.radiusMedium
            onClicked: {
                Audio.openMixer();
                ControlCenter.close();
            }
        }

        BarText {
            id: settings

            anchors.centerIn: parent
            text: "Sound settings…"
            color: Theme.muted
            font.pixelSize: Theme.fontSmall
        }
    }
}
