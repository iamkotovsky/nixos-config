import QtQml
import ".."

// Turns wheel events into whole steps for controls that change a value by
// steps (scrolling volume on a bar pill): one per wheel notch, and one per
// `touchpadStep` of touchpad travel, so a touchpad swipe doesn't fire a step
// for each of its many small events. `feed(event)` returns the steps to take
// (positive: scrolled up).
QtObject {
    id: root

    property real touchpadStep: Theme.rowHeight / 2

    // Travel not yet worth a whole step, in notch (120) or pixel units.
    property real pending: 0

    function feed(event) {
        const pixels = event.pixelDelta.y !== 0;
        const delta = pixels ? event.pixelDelta.y : event.angleDelta.y;
        const unit = pixels ? touchpadStep : 120;
        // Turning back starts afresh rather than cancelling travel.
        if (Math.sign(delta) !== Math.sign(pending))
            pending = 0;
        pending += delta;
        const steps = Math.trunc(pending / unit);
        pending -= steps * unit;
        return steps;
    }
}
