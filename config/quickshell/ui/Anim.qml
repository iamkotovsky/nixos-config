import QtQuick
import ".."

// The design system's motion, so a Behavior is one line:
//   Behavior on x { Anim {} }                       normal, OutCubic
//   Behavior on opacity { Anim { speed: "fast" } }  hover, colour, press
//   Anim { speed: "slow"; spring: true }            a surface entering
//   Anim { leaving: true }                          exits: 0.7x, InCubic
NumberAnimation {
    // "fast" | "normal" | "slow"
    property string speed: "normal"
    // Overshoot on the way in (OutBack), for surfaces appearing.
    property bool spring: false
    // Exit timing: shorter, accelerating, never overshooting.
    property bool leaving: false

    readonly property int base: speed === "fast" ? Theme.durationFast : speed === "slow" ? Theme.durationSlow : Theme.durationNormal

    duration: leaving ? Theme.exitDuration(base) : base
    easing.type: leaving ? Easing.InCubic : spring ? Easing.OutBack : Easing.OutCubic
    easing.overshoot: Theme.overshoot
}
