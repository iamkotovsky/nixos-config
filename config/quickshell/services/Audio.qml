pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default output (sink) volume straight from PipeWire, shared by the status
// button (scroll) and the control panel (slider, mute).
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property bool muted: ready && sink.audio.muted
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property int percent: Math.round(volume * 100)

    readonly property string icon: {
        if (muted || percent <= 0)
            return "volume_off";
        if (percent < 34)
            return "volume_mute";
        if (percent < 67)
            return "volume_down";
        return "volume_up";
    }

    // For the Sound page: output devices, and apps currently playing (output
    // streams, which PipeWire models as sources feeding a sink).
    readonly property var allOutputs: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    // Hides outputs whose port is unplugged (HDMI / DisplayPort with no
    // display attached); the current default always stays listed.
    readonly property var outputs: allOutputs.filter(n => n === sink || !AudioPorts.unplugged.includes(n.name))
    readonly property var streams: Pipewire.nodes.values.filter(n => n.audio && !n.isSink && n.isStream)
    // One entry per app, however many streams it opens (Vesktop opens
    // several): { name, streams }.
    readonly property var apps: {
        const groups = [];
        for (const stream of streams) {
            const name = appName(stream);
            let group = groups.find(g => g.name === name);
            if (!group) {
                group = {
                    name: name,
                    streams: []
                };
                groups.push(group);
            }
            group.streams.push(stream);
        }
        return groups;
    }

    // Outputs came or went: re-check which ports are plugged in.
    onAllOutputsChanged: AudioPorts.refresh()

    // The short port name ("Speaker", "HDMI / DisplayPort 1 Output"); the
    // description repeats the sound card's long name for every output.
    function nodeName(node) {
        return node.nickname || node.description || node.name;
    }

    function outputIcon(node) {
        const name = (node.name ?? "").toLowerCase();
        if (name.includes("bluez") || name.includes("headphone") || name.includes("headset"))
            return "headphones";
        if (name.includes("hdmi"))
            return "tv";
        return "volume_up";
    }

    function appName(stream) {
        const props = stream.properties;
        return props["application.name"] || props["node.name"] || stream.name;
    }

    // The app's own icon, or "" to fall back to a glyph.
    function appIcon(stream) {
        return Icons.resolve(stream.properties["application.icon-name"], appName(stream));
    }

    function setDefault(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setVolume(value) {
        if (ready)
            sink.audio.volume = Math.max(0, value);
    }

    // Scroll step: never pushes past 100%, but keeps any boost set elsewhere.
    function step(delta) {
        if (!ready)
            return;
        const current = sink.audio.volume;
        const ceiling = Math.max(current, 1);
        sink.audio.volume = Math.max(0, Math.min(ceiling, current + (delta > 0 ? 0.05 : -0.05)));
    }

    function toggleMute() {
        if (ready)
            sink.audio.muted = !sink.audio.muted;
    }

    function openMixer() {
        Quickshell.execDetached(["pavucontrol"]);
    }

    // Binds the sink so its audio properties are live.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // Outputs and app streams need binding too, for their names and volumes.
    PwObjectTracker {
        objects: [...root.allOutputs, ...root.streams]
    }

    // Floating slider on any volume/mute change, whoever made it (keys,
    // scroll, apps, pavucontrol). Connections only fire on real changes, not
    // on start-up or a sink switch; the open control panel shows its own.
    Connections {
        target: root.ready ? root.sink.audio : null

        function onVolumeChanged() {
            if (ControlCenter.openOn === "")
                Osd.show(Osd.volume);
        }

        function onMutedChanged() {
            if (ControlCenter.openOn === "")
                Osd.show(Osd.volume);
        }
    }
}
