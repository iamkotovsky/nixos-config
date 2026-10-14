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
}
