{ pkgs, theme, ... }:
let
  dir = ./quickshell;

  # Applet palette comes straight from the active theme preset; the rest of the
  # bar QML only ever references the `theme` singleton by id.
  themeQml = ''
    // Requires `pragma Singleton` so Quickshell/AutoDir synthesizes a
    // `singleton` qmldir entry, making `Theme` resolvable from every file in
    // the config without instantiating it (see quickshell's QmlScanner).
    pragma Singleton

    import QtQuick
    import Quickshell

    // Generated from /etc/nixos/theme/ — edit the theme, not this file.
    Singleton {
        id: theme

        property color background: "${theme.colors.background}"
        property color surface: "${theme.colors.surface}"
        property color foreground: "${theme.colors.foreground}"
        property color muted: "${theme.colors.muted}"
        property color accent: "${theme.colors.accent}"
        property color red: "${theme.colors.red}"
        property color green: "${theme.colors.green}"
        property color yellow: "${theme.colors.yellow}"
        property color blue: "${theme.colors.blue}"
        property color magenta: "${theme.colors.magenta}"
        property color cyan: "${theme.colors.cyan}"

        property int barHeight: 38
        property int barMargin: 4
        property int moduleRadius: ${toString theme.radius.small}
        property int spacingSmall: ${toString theme.spacing.small}
        property int spacingMedium: ${toString theme.spacing.medium}
        property real barOpacity: ${theme.opacity.surface}
        property real moduleOpacity: 0.90

        property string fontFamily: "${theme.font.mono}"
        property int fontSize: ${toString theme.font.size}
    }
  '';

  file = name: { source = "${dir}/${name}"; };
in
{
  home.packages = [ pkgs.quickshell ];

  # Config name "bar": quickshell picks up any subfolder of ~/.config/quickshell
  # that contains shell.qml and runs it via `quickshell --config bar`.
  xdg.configFile."quickshell/bar/shell.qml".source = "${dir}/shell.qml";
  xdg.configFile."quickshell/bar/Theme.qml".text = themeQml;
  xdg.configFile."quickshell/bar/Niri.qml" = file "Niri.qml";
  xdg.configFile."quickshell/bar/Pill.qml" = file "Pill.qml";
  xdg.configFile."quickshell/bar/Workspaces.qml" = file "Workspaces.qml";
  xdg.configFile."quickshell/bar/Clock.qml" = file "Clock.qml";
  xdg.configFile."quickshell/bar/Language.qml" = file "Language.qml";
  xdg.configFile."quickshell/bar/Tray.qml" = file "Tray.qml";
  xdg.configFile."quickshell/bar/Network.qml" = file "Network.qml";
  xdg.configFile."quickshell/bar/Volume.qml" = file "Volume.qml";
  xdg.configFile."quickshell/bar/Backlight.qml" = file "Backlight.qml";
  xdg.configFile."quickshell/bar/Battery.qml" = file "Battery.qml";
  xdg.configFile."quickshell/bar/network.sh" = file "network.sh";
  xdg.configFile."quickshell/bar/battery.sh" = file "battery.sh";
}