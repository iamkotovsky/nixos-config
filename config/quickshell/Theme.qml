// Rendered by modules/home/quickshell.nix into ~/.config/quickshell/bar/: @NAME@
// placeholders are replaced with values from the active theme at build time.
// Lives outside bar/ so the unrendered copy never shadows the rendered one.

// Requires `pragma Singleton` so Quickshell/AutoDir synthesizes a `singleton`
// qmldir entry, making `Theme` resolvable from every file in the config
// without instantiating it (see quickshell's QmlScanner).
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: theme

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

    // One gap everywhere: screen edges, between pills and windows, and
    // between windows (niri `gaps` uses the same theme value).
    property int gap: @GAP@
    property int pillHeight: 30
    property int moduleRadius: @RADIUS@
    property int spacingSmall: @SPACING_SMALL@
    property int spacingMedium: @SPACING_MEDIUM@
    // Pills float over the wallpaper, so they use the shared surface opacity.
    property real pillOpacity: @SURFACE_OPACITY@
    // Subtle frosted strip behind the pills; hides windows sliding under the
    // bar during niri's workspace-switch animation.
    property real stripOpacity: 0.75
    // Control panel card: translucent enough for the frost to show.
    property real panelOpacity: 0.72

    property string fontFamily: "@FONT@"
    property int fontSize: @FONT_SIZE@

    // Rounded Material Symbols, addressed by ligature name (e.g. "volume_up").
    property string iconFont: "Material Symbols Rounded"
    property int iconSize: fontSize + 2
}
