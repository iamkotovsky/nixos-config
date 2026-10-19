import QtQuick
import Quickshell
import ".."

// A Glass surface that appears and disappears: it springs in (fade, a small
// slide and a scale from pressScale around `origin`) and leaves quicker
// without overshoot. Its window must keep it mapped until the exit ends
// (`visible: shown || surface.opacity > 0`) and use `liveBlurRegion` for
// BackgroundEffect.blurRegion.
Glass {
    id: surface

    property bool shown: false
    // The point it grows from, e.g. Item.TopRight under the status button.
    transformOrigin: Item.Center
    // Vertical offset while hidden (negative = from above).
    property real slideFrom: 0

    // The blur follows the visible (scaled, slid) shape, worked out by hand:
    // an item-bound Region ignores transforms and would freeze at the first
    // frame. Blur can't fade, so it waits until the surface is half faded in
    // (the compositor applies it at once, ahead of the card's first frames)
    // and is dropped as soon as the surface starts hiding.
    readonly property Region liveBlurRegion: shown && opacity >= 0.5 ? live : none

    // transformOrigin as a fraction of the size (TopLeft 0,0 ... BottomRight 1,1).
    readonly property real originX: [0, 0.5, 1][transformOrigin % 3]
    readonly property real originY: [0, 0.5, 1][Math.floor(transformOrigin / 3)]

    opacity: shown ? 1 : 0
    scale: shown ? 1 : Theme.pressScale
    transform: Translate {
        id: slide

        y: surface.shown ? 0 : surface.slideFrom

        Behavior on y {
            Anim {
                speed: "slow"
                spring: surface.shown
                leaving: !surface.shown
            }
        }
    }

    Behavior on opacity {
        Anim {
            leaving: !surface.shown
        }
    }

    Behavior on scale {
        Anim {
            speed: "slow"
            spring: surface.shown
            leaving: !surface.shown
        }
    }

    Region {
        id: live

        x: surface.x + surface.width * surface.originX * (1 - surface.scale)
        y: surface.y + surface.height * surface.originY * (1 - surface.scale) + slide.y
        width: surface.width * surface.scale
        height: surface.height * surface.scale
        radius: surface.radius * surface.scale
    }

    Region {
        id: none
    }
}
