import QtQuick
import ".."

// The shell's scrolling, for any Flickable (ScrollList, ScrollArea). Put it
// in the Flickable with `parent: <flickable>` (not its content) and
// `anchors.fill: parent`, and set the Flickable `interactive: false`, so
// Flickable's own flicking (momentum, overshoot, uneven wheel steps) stays
// out of the way:
//  - a touchpad follows the fingers 1:1, then keeps gliding at the speed it
//    was let go with, slowing down under constant friction;
//  - a mouse wheel moves about `step` per notch, through the same glide;
//  - past either end the content stretches with growing resistance (rubber
//    band) while dragged; a glide that reaches an end hits it at its speed
//    and a damped spring turns what is left into the bounce and brings it
//    back;
//  - `revealRange(top, bottom)` brings part of the content into view
//    (keyboard navigation).
// A thin scrollbar shows while it scrolls (squashing while stretched) and
// fades after.
//
// Glides and springs are simulated frame by frame (`motion`), not canned
// animations: an animation aimed at the end eases out to a stop there and
// only then bounces, which reads as a crawl and a late twitch.
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

    // What moves it between events: nothing, a glide (friction) or the spring
    // pulling an overscrolled end back. `velocity` is in px/ms of contentY.
    property string motion: "none"
    property real velocity: 0

    // Touchpad gesture state: whether fingers are down, the finger travel
    // past the end (before resistance), and the last event's time.
    property bool dragging: false
    property real pull: 0
    property real lastWheel: 0

    // Physics, in px and ms: glide friction; the spring's angular frequency
    // (critically damped: back in about 0.4 s, no wobble); the furthest a
    // drag stretches.
    readonly property real friction: 0.0025
    readonly property real springRate: 0.012
    readonly property real stretchLimit: step * 2
    // The hardest an end can be hit: a bounce stretches at most half of what
    // a drag can (peak = v / (rate * e) for a critically damped spring).
    readonly property real maxImpact: stretchLimit / 2 * springRate * Math.E

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
        motion = "none";
        velocity = 0;
    }

    // Glide or spring from the current position at `v` px/ms.
    function launch(v) {
        scroll.stop();
        linger.restart();
        velocity = v;
        motion = overscroll !== 0 ? "spring" : "glide";
        if (motion === "spring")
            velocity = Math.max(-maxImpact, Math.min(maxImpact, velocity));
    }

    function scrollTo(y, animate) {
        stopMotion();
        linger.restart();
        const target = clamp(y);
        if (animate) {
            scroll.to = target;
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

    // Fingers lifted: keep going at the release speed (glide), or spring
    // back with it if stretched.
    function release() {
        touchpadIdle.stop();
        dragging = false;
        pull = 0;
        // Fingers that stopped before lifting carry no speed.
        const v = Date.now() - lastWheel > 50 ? 0 : velocity;
        if (overscroll === 0 && Math.abs(v) < 0.05)
            return stopMotion();
        launch(v);
    }

    // One simulation step of `dt` ms.
    function advance(dt) {
        const flick = flickable;
        if (motion === "glide") {
            const slow = friction * dt;
            if (Math.abs(velocity) <= slow) {
                motion = "none";
                velocity = 0;
                return;
            }
            velocity -= Math.sign(velocity) * slow;
            flick.contentY += velocity * dt;
            // Hit an end: the spring takes over at the impact speed.
            if (overscroll !== 0) {
                motion = "spring";
                velocity = Math.max(-maxImpact, Math.min(maxImpact, velocity));
            }
        } else if (motion === "spring") {
            const x = overscroll;
            const end = x < 0 ? minY : maxY;
            velocity += (-springRate * springRate * x - 2 * springRate * velocity) * dt;
            flick.contentY += velocity * dt;
            // Settled, or pulled back into range: rest exactly at the end.
            const back = overscroll === 0 || Math.sign(overscroll) !== Math.sign(x);
            if (back || (Math.abs(overscroll) < 0.5 && Math.abs(velocity) < 0.01)) {
                flick.contentY = end;
                motion = "none";
                velocity = 0;
            }
        }
    }

    FrameAnimation {
        running: root.motion !== "none"
        onTriggered: {
            linger.restart();
            // Whole frames at most, so a stalled frame doesn't fling it.
            root.advance(Math.min(frameTime, 0.05) * 1000);
        }
    }

    // Keyboard reveals and scrollTo: exact positions, eased.
    NumberAnimation {
        id: scroll

        target: root.flickable
        property: "contentY"
        duration: Theme.durationFast
        easing.type: Easing.OutCubic
    }

    // Fingers lifted is normally reported (an event with no movement); this
    // only covers touchpads that never say so. Long, so holding still past
    // an end isn't taken for letting go.
    Timer {
        id: touchpadIdle

        interval: Theme.durationSlow * 4
        onTriggered: root.release()
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (!root.scrollable)
                return;
            // Touchpads report pixels, wheels notches (120 each). Only an
            // event with no movement at all, on either axis, is a touchpad
            // saying the fingers lifted: resting fingers still send jitter,
            // sideways or below a pixel (pixel delta 0, a small angle delta).
            const pixels = event.pixelDelta;
            const angle = event.angleDelta;
            if (pixels.x === 0 && pixels.y === 0 && angle.x === 0 && angle.y === 0) {
                if (root.dragging)
                    root.release();
                return;
            }

            const flick = root.flickable;
            // While fingers are down every event is touchpad input, never a
            // wheel notch; one without vertical pixels just keeps the hold.
            if (root.dragging && pixels.y === 0) {
                touchpadIdle.restart();
                return;
            }
            if (pixels.y !== 0) {
                // A new gesture picks up whatever is moving, stretch included.
                if (!root.dragging) {
                    root.stopMotion();
                    root.dragging = true;
                    root.pull = root.unrubber(root.overscroll);
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
            } else if (angle.y !== 0) {
                // A notch adds `step` to wherever the glide was headed; the
                // glide then covers it under friction, so notches at the end
                // hit it with speed and bounce like a flick.
                const notches = -event.angleDelta.y / 120;
                const v = root.motion === "glide" ? root.velocity : 0;
                const ahead = Math.sign(v) * v * v / (2 * root.friction);
                const distance = ahead + notches * root.step;
                root.launch(Math.sign(distance) * Math.sqrt(2 * root.friction * Math.abs(distance)));
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
