import QtQuick
import ".."

// The shell's scrolling, for any Flickable (ScrollList, ScrollArea). Put it
// in the Flickable with `parent: <flickable>` (not its content) and
// `anchors.fill: parent`, and set the Flickable `interactive: false`, so
// Flickable's own flicking (momentum, overshoot, uneven wheel steps) stays
// out of the way:
//  - a touchpad follows the fingers 1:1, then keeps gliding at the speed it
//    was let go with, slowing down;
//  - a mouse wheel moves `step` per notch with a short glide;
//  - past either end the content stretches with growing resistance (rubber
//    band) and springs back; a wheel notch or a glide into the end bumps;
//  - `revealRange(top, bottom)` brings part of the content into view
//    (keyboard navigation).
// A thin scrollbar shows while it scrolls (squashing while stretched) and
// fades after.
Item {
    id: root

    required property Flickable flickable
    // Distance per wheel notch.
    property real step: Theme.rowHeight

    // Above the content, so wheel events and the scrollbar come first.
    z: 1

    // The scroll range, in contentY terms (the origin moves as rows come and go).
    readonly property real minY: flickable.originY
    readonly property real maxY: flickable.originY + Math.max(0, flickable.contentHeight - flickable.height)
    readonly property bool scrollable: flickable.contentHeight > flickable.height
    // How far the content is stretched past an end (negative: past the top).
    readonly property real overscroll: {
        const y = flickable.contentY;
        return y < minY ? y - minY : y > maxY ? y - maxY : 0;
    }

    // Touchpad gesture state: the finger travel past the end (before
    // resistance), the release speed in px/ms, and the last event's time.
    property real pull: 0
    property real velocity: 0
    property real lastWheel: 0

    // The furthest the content stretches, and the glide's deceleration (px/ms²).
    readonly property real stretchLimit: step * 2
    readonly property real deceleration: 0.0025

    function clamp(y) {
        return Math.max(minY, Math.min(maxY, y));
    }

    // Finger travel past the end -> how far the content actually stretches:
    // follows at first, then ever harder, never past stretchLimit.
    function rubber(travel) {
        const d = stretchLimit;
        return Math.sign(travel) * d * (1 - 1 / (Math.abs(travel) * 0.55 / d + 1));
    }

    // The inverse: finger travel that gives a stretch (to pick up content
    // that is still springing back).
    function unrubber(stretch) {
        const d = stretchLimit;
        const s = Math.min(Math.abs(stretch), d * 0.99);
        return Math.sign(stretch) * d / 0.55 * (1 / (1 - s / d) - 1);
    }

    function stopMotion() {
        scroll.stop();
        bounce.stop();
        settle.stop();
    }

    function scrollTo(y, animate) {
        stopMotion();
        linger.restart();
        const target = clamp(y);
        if (animate) {
            scroll.to = target;
            scroll.duration = Theme.durationFast;
            scroll.start();
        } else {
            flickable.contentY = target;
        }
    }

    // Scrolls just enough to show content between `top` and `bottom`
    // (contentY terms), gliding.
    function revealRange(top, bottom) {
        const from = scroll.running ? scroll.to : flickable.contentY;
        if (top < from)
            scrollTo(top, true);
        else if (bottom > from + flickable.height)
            scrollTo(bottom - flickable.height, true);
    }

    // Stretch past the end by `amount` (sign picks the end) and spring back.
    function bumpBy(amount) {
        if (amount === 0)
            return;
        stopMotion();
        linger.restart();
        const end = amount < 0 ? minY : maxY;
        bounceOut.from = flickable.contentY;
        bounceOut.to = end + amount;
        bounceBack.to = end;
        bounce.start();
    }

    // Glide towards `target`, bumping if it lies past an end (by the
    // stretch the overshoot would give, times `bumpScale`).
    function glideTo(target, duration, bumpScale) {
        const end = clamp(target);
        const excess = target - end;
        if (end === flickable.contentY && !scroll.running) {
            bumpBy(rubber(excess) * bumpScale);
            return;
        }
        stopMotion();
        linger.restart();
        scroll.to = end;
        scroll.duration = duration;
        scroll.pendingBump = rubber(excess) * bumpScale;
        scroll.start();
    }

    // Fingers lifted: spring back if stretched, else keep gliding.
    function release() {
        touchpadIdle.stop();
        if (overscroll !== 0) {
            pull = 0;
            settle.to = clamp(flickable.contentY);
            settle.start();
            return;
        }
        const v = velocity;
        velocity = 0;
        if (Math.abs(v) < 0.2)
            return;
        const distance = v * Math.abs(v) / (2 * deceleration);
        const duration = Math.min(Theme.durationSlow * 3, Math.abs(v) / deceleration);
        // Half the stretch: a hard flick would otherwise bounce far.
        glideTo(flickable.contentY + distance, Math.max(Theme.durationFast, duration), 0.5);
    }

    // Wheel glides, keyboard reveals and touchpad glides; a glide that was
    // aimed past an end bumps when it gets there.
    NumberAnimation {
        id: scroll

        property real pendingBump: 0

        target: root.flickable
        property: "contentY"
        easing.type: Easing.OutCubic
        onStopped: {
            const amount = pendingBump;
            pendingBump = 0;
            if (amount !== 0 && Math.abs(root.flickable.contentY - to) < 1)
                root.bumpBy(amount);
        }
    }

    SequentialAnimation {
        id: bounce

        NumberAnimation {
            id: bounceOut

            target: root.flickable
            property: "contentY"
            duration: Theme.durationFast
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: bounceBack

            target: root.flickable
            property: "contentY"
            duration: Theme.durationSlow
            easing.type: Easing.OutBack
            easing.overshoot: Theme.overshoot
        }
    }

    // Springing back after the fingers let go of stretched content.
    NumberAnimation {
        id: settle

        target: root.flickable
        property: "contentY"
        duration: Theme.durationSlow
        easing.type: Easing.OutBack
        easing.overshoot: Theme.overshoot
    }

    // Some touchpads never say the fingers lifted: treat a pause as release.
    Timer {
        id: touchpadIdle

        interval: Theme.durationFast / 2
        onTriggered: root.release()
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (!root.scrollable)
                return;
            // Touchpads report pixels, wheels notches (120 each). An event
            // with neither is a touchpad saying the fingers lifted.
            if (event.pixelDelta.y === 0 && event.angleDelta.y === 0) {
                if (touchpadIdle.running)
                    root.release();
                return;
            }

            const flick = root.flickable;
            if (event.pixelDelta.y !== 0) {
                // A new gesture picks up whatever is moving, stretch included.
                if (!touchpadIdle.running) {
                    root.stopMotion();
                    root.pull = root.unrubber(root.overscroll);
                    root.velocity = 0;
                }
                linger.restart();
                touchpadIdle.restart();

                const dy = -event.pixelDelta.y;
                const now = Date.now();
                const dt = Math.max(1, now - root.lastWheel);
                root.velocity = dt > 100 ? dy / dt : root.velocity * 0.6 + dy / dt * 0.4;
                root.lastWheel = now;

                const base = root.clamp(flick.contentY);
                const travel = base + root.pull + dy;
                if (travel < root.minY) {
                    root.pull = travel - root.minY;
                    flick.contentY = root.minY + root.rubber(root.pull);
                } else if (travel > root.maxY) {
                    root.pull = travel - root.maxY;
                    flick.contentY = root.maxY + root.rubber(root.pull);
                } else {
                    root.pull = 0;
                    flick.contentY = travel;
                }
            } else {
                const from = scroll.running ? scroll.to : root.clamp(flick.contentY);
                root.glideTo(from - event.angleDelta.y / 120 * root.step, Theme.durationFast, 1);
            }
        }
    }

    // Scrollbar: shown while scrolling (wheel, touchpad, keyboard), fading
    // out once it rests; not when the content merely changes. While
    // stretched it squashes against that end.
    Rectangle {
        id: bar

        readonly property real full: root.height * Math.min(1, root.height / Math.max(1, root.flickable.contentHeight))
        readonly property real span: Math.max(width * 2, full - Math.abs(root.overscroll))
        readonly property real progress: root.maxY > root.minY ? Math.max(0, Math.min(1, (root.flickable.contentY - root.minY) / (root.maxY - root.minY))) : 0

        visible: root.scrollable
        x: root.width - width - Theme.spacingXs
        y: progress * (root.height - span)
        width: Theme.scrollbarWidth
        height: span
        radius: width / 2
        color: Qt.alpha(Theme.foreground, Theme.trackOpacity)
        opacity: linger.running ? 1 : 0

        Behavior on opacity {
            Anim {
                leaving: !linger.running
            }
        }
    }

    Timer {
        id: linger

        interval: Theme.scrollbarLinger
    }
}
