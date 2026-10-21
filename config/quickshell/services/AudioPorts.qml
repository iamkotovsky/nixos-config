pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Which audio outputs have nothing plugged in (HDMI / DisplayPort with no
// display attached). Quickshell doesn't expose port availability, so it is
// read from `pw-dump`: each sink's card.profile.device maps to one of its
// card's routes, which carries `available`.
Singleton {
    id: root

    // Node names of outputs whose port PipeWire reports as unavailable.
    property var unplugged: []

    function refresh() {
        reader.running = true;
    }

    function read(text) {
        let objects;
        try {
            objects = JSON.parse(text);
        } catch (e) {
            return;
        }
        const devices = objects.filter(o => o.type === "PipeWire:Interface:Device");
        const result = [];
        for (const o of objects) {
            const props = o.info?.props ?? {};
            if (props["media.class"] !== "Audio/Sink")
                continue;
            const device = devices.find(d => d.id === props["device.id"]);
            const routes = device?.info?.params?.EnumRoute ?? [];
            const index = Number(props["card.profile.device"]);
            const route = routes.find(r => r.direction === "Output" && (r.devices ?? []).includes(index));
            if (route && route.available === "no")
                result.push(props["node.name"]);
        }
        root.unplugged = result;
    }

    Process {
        id: reader

        command: ["pw-dump"]
        stdout: StdioCollector {
            onStreamFinished: root.read(text)
        }
    }

    // Plugging a display changes availability, not the node list, so re-read
    // every few seconds while the Sound page is open.
    Timer {
        interval: 2000
        repeat: true
        triggeredOnStart: true
        running: ControlCenter.showing(ControlCenter.soundPage)
        onTriggered: root.refresh()
    }
}
