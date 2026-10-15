# Wayland-native (rofi 2.0+ has this built in, no fork needed) application
# launcher: fixed-size popup, so it never hits the resize/blur redraw glitch
# that dynamically-sized layer-shell surfaces (like walker) run into on niri.
{
  pkgs,
  theme,
  ...
}:
let
  inherit (theme) colors;

  # Each attribute fills the matching @NAME@ placeholder in config.rasi.
  substitutions = {
    FONT = theme.font.ui;
    FONT_SIZE = toString theme.font.size;
    SURFACE_HEX = theme.hex colors.surface;
    SURFACE_ALPHA = theme.alphaHex theme.opacity.raised;
    RIM_ALPHA = theme.alphaHex theme.opacity.rim;
    FILL_ALPHA = theme.alphaHex theme.fill.rest;
    FILL_HOVER_ALPHA = theme.alphaHex theme.fill.hover;
    FOREGROUND_HEX = theme.hex colors.foreground;
    MUTED_HEX = theme.hex colors.muted;
    ACCENT_HEX = theme.hex colors.accent;
    RADIUS_SMALL = toString theme.radius.small;
    RADIUS_LARGE = toString theme.radius.large;
    SPACING_SMALL = toString theme.spacing.small;
    SPACING_MEDIUM = toString theme.spacing.medium;
    SPACING_LARGE = toString theme.spacing.large;
  };
in
{
  home.packages = [ pkgs.rofi ];

  # Layout lives in its native format; only theme values are injected here.
  xdg.configFile."rofi/config.rasi".text = builtins.replaceStrings
    (map (name: "@${name}@") (builtins.attrNames substitutions))
    (builtins.attrValues substitutions)
    (builtins.readFile ../../config/rofi/config.rasi);
}
