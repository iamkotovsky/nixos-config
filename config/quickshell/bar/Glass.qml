import QtQuick
import QtQuick.Effects
import Quickshell

// Frosted glass surface: translucent fill over the compositor's blur, a 1px
// light rim and a faint top highlight, plus an optional soft shadow.
//   level:     "strip" (bar backdrop), "raised" (pills) or "overlay" (cards)
//   elevation: "flat", "raised" or "floating"; `lifted` (hover) adds a level
// Override `color` / `border` for chips and tiles. The window that shows it
// must request blur for `blurRegion` (or have a niri blur layer-rule), and
// leave Theme.shadowPad of room where the shadow falls.
Rectangle {
    id: glass

    property string level: "raised"
    property string elevation: "flat"
    property bool lifted: false
    property bool highlight: true

    readonly property int elevationLevel: Math.min(2, ["flat", "raised", "floating"].indexOf(elevation) + (lifted ? 1 : 0))

    // For BackgroundEffect.blurRegion, rounded like the surface.
    readonly property Region blurRegion: Region {
        item: glass
        radius: glass.radius
    }

    radius: Theme.radiusMedium
    color: {
        if (level === "strip")
            return Qt.alpha(Theme.background, Theme.stripOpacity);
        return Qt.alpha(Theme.surface, level === "overlay" ? Theme.overlayOpacity : Theme.raisedOpacity);
    }
    border.width: 1
    border.color: Qt.alpha(Theme.foreground, Theme.rimOpacity)

    Behavior on color {
        ColorAnimation {
            duration: Theme.durationFast
        }
    }

    // Light catching the top edge.
    Rectangle {
        anchors {
            fill: parent
            margins: glass.border.width
        }
        visible: glass.highlight
        radius: Math.max(0, glass.radius - glass.border.width)
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.alpha(Theme.foreground, Theme.highlightOpacity)
            }
            GradientStop {
                position: 0.4
                color: "transparent"
            }
        }
    }

    // Shadow behind the glass, cut out under it so the translucent fill
    // isn't darkened (like a CSS box-shadow).
    Item {
        id: shadow

        readonly property int level: glass.elevationLevel
        property real blur: level === 2 ? Theme.floatingShadowBlur : Theme.raisedShadowBlur
        property real offset: level === 2 ? Theme.floatingShadowY : level === 1 ? Theme.raisedShadowY : 0
        property real strength: level === 2 ? Theme.floatingShadowOpacity : level === 1 ? Theme.raisedShadowOpacity : 0

        z: -1
        anchors {
            fill: parent
            margins: -Theme.shadowPad
        }
        visible: strength > 0
        layer.enabled: visible
        layer.effect: MultiEffect {
            maskEnabled: true
            maskInverted: true
            maskSource: hole
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }

        Behavior on blur {
            NumberAnimation {
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on offset {
            NumberAnimation {
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
        }
        Behavior on strength {
            NumberAnimation {
                duration: Theme.durationNormal
                easing.type: Easing.OutCubic
            }
        }

        RectangularShadow {
            x: Theme.shadowPad
            y: Theme.shadowPad
            width: glass.width
            height: glass.height
            radius: glass.radius
            blur: shadow.blur
            offset.y: shadow.offset
            color: Qt.alpha(Theme.shadow, shadow.strength)
        }

        // The glass's own shape, in the shadow's coordinates.
        Item {
            id: hole

            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors {
                    fill: parent
                    margins: Theme.shadowPad
                }
                radius: glass.radius
            }
        }
    }
}
