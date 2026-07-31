{ theme, ... }:
let
  colors = theme.colors;
in
{
  # Theme.qml is generated from the same attrset used by Kitty and Helix.
  xdg.configFile = {
    "quickshell/zenbook/shell.qml".source = ../../config/quickshell/shell.qml;
    "quickshell/zenbook/qmldir".source = ../../config/quickshell/qmldir;

    "quickshell/zenbook/Theme.qml".text = ''
      pragma Singleton
      import Quickshell

      Singleton {
        readonly property color background: "${colors.background}"
        readonly property color surface: "${colors.surface}"
        readonly property color foreground: "${colors.foreground}"
        readonly property color muted: "${colors.muted}"
        readonly property color accent: "${colors.accent}"
        readonly property color red: "${colors.red}"
        readonly property color green: "${colors.green}"
        readonly property color yellow: "${colors.yellow}"
        readonly property color blue: "${colors.blue}"
        readonly property color magenta: "${colors.magenta}"
        readonly property color cyan: "${colors.cyan}"

        readonly property string monoFont: "${theme.font.mono}"
        readonly property int fontSize: ${toString theme.font.size}
        readonly property int radiusSmall: ${toString theme.radius.small}
        readonly property int radiusMedium: ${toString theme.radius.medium}
        readonly property int spacingSmall: ${toString theme.spacing.small}
        readonly property int spacingMedium: ${toString theme.spacing.medium}
      }
    '';

  };
}
