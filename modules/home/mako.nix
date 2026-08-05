# D-Bus activated (org.freedesktop.Notifications), so it starts on first
# notification rather than needing an explicit niri spawn-at-startup.
{ theme, ... }:
let
  colors = theme.colors;
in
{
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "overlay";
      width = 380;
      height = 120;
      margin = theme.spacing.medium;
      padding = theme.spacing.medium;
      border-size = 2;
      border-radius = theme.radius.medium;
      font = "${theme.font.mono} ${toString theme.font.size}";
      background-color = "#${theme.hex colors.surface}${theme.alphaHex theme.opacity.surface}";
      text-color = "#${theme.hex colors.foreground}ff";
      border-color = "#${theme.hex colors.accent}ff";
      progress-color = "over #${theme.hex colors.accent}55";
      default-timeout = 5000;
      icons = true;
      max-icon-size = 48;
      markup = true;

      "urgency=critical" = {
        border-color = "#${theme.hex colors.red}ff";
        default-timeout = 0;
      };
      "urgency=low" = {
        border-color = "#${theme.hex colors.muted}ff";
      };
    };
  };
}
