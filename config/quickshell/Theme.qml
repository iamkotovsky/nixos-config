// Rendered by modules/home/quickshell.nix into ~/.config/quickshell/bar/: @NAME@
// placeholders are replaced with values from the active theme at build time.
// Lives outside bar/ so the unrendered copy never shadows the rendered one.
//
// The design tokens for the shell; roles and rules are in
// .claude/rules/design.md. Never hardcode a size, color, opacity or duration
// in a component: use (or add) a token here.

// Requires `pragma Singleton` so Quickshell/AutoDir synthesizes a `singleton`
// qmldir entry, making `Theme` resolvable from every file in the config
// without instantiating it (see quickshell's QmlScanner).
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: theme

    // Colors. Accent only marks state (on, active, focus, progress, links).
    property color background: "@BACKGROUND@"
    property color surface: "@SURFACE@"
    property color foreground: "@FOREGROUND@"
    property color muted: "@MUTED@"
    property color accent: "@ACCENT@"
    property color red: "@RED@"
    property color green: "@GREEN@"
    property color yellow: "@YELLOW@"
    property color blue: "@BLUE@"
    property color magenta: "@MAGENTA@"
    property color cyan: "@CYAN@"
    property color shadow: "#000000"

    // One gap everywhere: screen edges, between pills and windows, and
    // between windows (niri `gaps` uses the same theme value).
    property int gap: @GAP@

    // 4px spacing grid.
    property int spacingXs: @SPACING_XS@
    property int spacingSmall: @SPACING_SMALL@
    property int spacingMedium: @SPACING_MEDIUM@
    property int spacingLarge: @SPACING_LARGE@

    // Radii; "full" is height / 2.
    property int radiusSmall: @RADIUS_SMALL@
    property int radiusMedium: @RADIUS_MEDIUM@
    property int radiusLarge: @RADIUS_LARGE@

    // Type scale.
    property string fontFamily: "@FONT@"
    property int fontCaption: @FONT_CAPTION@
    property int fontSmall: @FONT_SMALL@
    property int fontSize: @FONT_SIZE@
    property int fontTitle: @FONT_TITLE@

    // Rounded Material Symbols, addressed by ligature name (e.g. "volume_up").
    property string iconFont: "Material Symbols Rounded"
    property int iconSize: fontSize + 2
    property int iconSizeLarge: 24
    // The horizontal battery glyph reads small at iconSize.
    property int batteryIconSize: iconSize + 4

    // Frosted glass: translucent surfaces over compositor blur, with a light
    // rim and a faint top highlight.
    property real stripOpacity: @STRIP_OPACITY@
    property real raisedOpacity: @RAISED_OPACITY@
    property real overlayOpacity: @OVERLAY_OPACITY@
    property real rimOpacity: @RIM_OPACITY@
    property real highlightOpacity: @HIGHLIGHT_OPACITY@

    // Foreground fills on glass (chips, tiles, buttons) and their states.
    property real fillRest: @FILL_REST@
    property real fillHover: @FILL_HOVER@
    property real fillPressed: @FILL_PRESSED@
    property real fillRim: @FILL_RIM@
    // Secondary text that still needs to read well (notification body,
    // subtitles on an accent tile).
    property real subtleTextOpacity: 0.8
    property real trackOpacity: 0.25
    property real progressOpacity: 0.6
    property real disabledOpacity: 0.4
    property real pressScale: 0.96

    // Elevation: soft shadows for depth and hover lift only.
    property int shadowPad: @SHADOW_PAD@
    property int raisedShadowBlur: @RAISED_SHADOW_BLUR@
    property int raisedShadowY: @RAISED_SHADOW_Y@
    property real raisedShadowOpacity: @RAISED_SHADOW_OPACITY@
    property int floatingShadowBlur: @FLOATING_SHADOW_BLUR@
    property int floatingShadowY: @FLOATING_SHADOW_Y@
    property real floatingShadowOpacity: @FLOATING_SHADOW_OPACITY@

    // Motion. Enter with OutBack (overshoot) for movement, OutCubic for
    // fades; exits are shorter, InCubic, never overshoot.
    property int durationFast: @DURATION_FAST@
    property int durationNormal: @DURATION_NORMAL@
    property int durationSlow: @DURATION_SLOW@
    property real overshoot: @OVERSHOOT@

    function exitDuration(duration) {
        return Math.round(duration * 0.7);
    }

    // Component sizes.
    property int pillHeight: 30
    property int buttonSize: 36
    property int smallButtonSize: 24
    property int chipHeight: 32
    property int tileHeight: 56
    property int sliderTrack: 6
    property int sliderKnob: 16
    property int sliderKnobHover: 18
    property int indicatorSize: 8
    property int indicatorActiveWidth: 22
    property int thumbnailSize: 48
    property int criticalBorder: 2
    property int progressHeight: 2
    property int panelWidth: 360
    property int notificationWidth: 380
    property int osdWidth: 300
    property int osdHeight: 44
    property int percentWidth: 48
}
