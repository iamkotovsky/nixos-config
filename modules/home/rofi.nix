# Wayland-native (rofi 2.0+ has this built in, no fork needed) application
# launcher: fixed-size popup, so it never hits the resize/blur redraw glitch
# that dynamically-sized layer-shell surfaces (like walker) run into on niri.
{
  pkgs,
  theme,
  ...
}:
let
  colors = theme.colors;
in
{
  home.packages = [ pkgs.rofi ];

  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
        modi: "drun";
        show-icons: true;
        icon-theme: "Papirus-Dark";
        display-drun: "Search";
        drun-display-format: "{name}";
        font: "${theme.font.mono} ${toString theme.font.size}";
        location: 0;
    }

    * {
        bg: #${theme.hex colors.surface}${theme.alphaHex theme.opacity.surface};
        bg-alt: #${theme.hex colors.foreground}${theme.alphaHex "0.10"};
        fg: #${theme.hex colors.foreground}ff;
        muted: #${theme.hex colors.muted}ff;
        accent: #${theme.hex colors.accent}ff;

        background-color: transparent;
        text-color: @fg;
    }

    window {
        width: 560px;
        background-color: @bg;
        border: 2px;
        border-color: @accent;
        border-radius: ${toString theme.radius.medium}px;
        padding: ${toString theme.spacing.medium}px ${toString theme.spacing.medium}px ${toString theme.spacing.small}px ${toString theme.spacing.medium}px;
        location: center;
    }

    mainbox {
        background-color: transparent;
        spacing: ${toString theme.spacing.small}px;
        children: [ "inputbar", "listview" ];
    }

    inputbar {
        background-color: @bg-alt;
        border-radius: ${toString theme.radius.small}px;
        padding: ${toString theme.spacing.medium}px;
        children: [ "entry" ];
    }

    entry {
        placeholder: "Search";
        placeholder-color: @muted;
        text-color: @fg;
    }

    listview {
        background-color: transparent;
        border: 0px;
        padding: 0px;
        lines: 5;
        spacing: ${toString theme.spacing.small}px;
        scrollbar: false;
        fixed-height: false;
        dynamic: true;
        require-input: true;
    }

    element {
        padding: ${toString theme.spacing.small}px;
        border-radius: ${toString theme.radius.small}px;
        orientation: horizontal;
        spacing: ${toString theme.spacing.medium}px;
    }

    element normal.normal, element alternate.normal, element normal.urgent,
    element alternate.urgent, element normal.active, element alternate.active {
        background-color: transparent;
        text-color: @fg;
    }

    element selected.normal, element selected.urgent, element selected.active {
        background-color: @bg-alt;
        text-color: @fg;
    }

    element-icon {
        size: 40px;
        vertical-align: 0.5;
        background-color: transparent;
    }

    element-text {
        vertical-align: 0.5;
        text-color: inherit;
        background-color: transparent;
    }
  '';
}
