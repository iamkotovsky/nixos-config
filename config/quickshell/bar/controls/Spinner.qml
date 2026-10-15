import QtQuick
import ".."

// Small busy indicator (connecting, scanning): a rotating rounded glyph.
MaterialIcon {
    id: root

    name: "progress_activity"
    color: Theme.muted

    RotationAnimation on rotation {
        running: root.visible
        from: 0
        to: 360
        duration: Theme.durationSlow * 3
        loops: Animation.Infinite
    }
}
