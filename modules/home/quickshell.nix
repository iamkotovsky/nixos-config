{ pkgs, theme, ... }:
let
  inherit (theme) colors;

  # Each attribute fills the matching @NAME@ placeholder in Theme.qml.
  substitutions = {
    BACKGROUND = colors.background;
    SURFACE = colors.surface;
    FOREGROUND = colors.foreground;
    MUTED = colors.muted;
    ACCENT = colors.accent;
    RED = colors.red;
    GREEN = colors.green;
    YELLOW = colors.yellow;
    BLUE = colors.blue;
    MAGENTA = colors.magenta;
    CYAN = colors.cyan;
    GAP = toString theme.gap;
    SPACING_XS = toString theme.spacing.xs;
    SPACING_SMALL = toString theme.spacing.small;
    SPACING_MEDIUM = toString theme.spacing.medium;
    SPACING_LARGE = toString theme.spacing.large;
    RADIUS_SMALL = toString theme.radius.small;
    # Same corner radius as windows (niri geometry-corner-radius).
    RADIUS_MEDIUM = toString theme.radius.medium;
    RADIUS_LARGE = toString theme.radius.large;
    FONT = theme.font.ui;
    FONT_SIZE = toString theme.font.size;
    FONT_CAPTION = toString theme.fontSizes.caption;
    FONT_SMALL = toString theme.fontSizes.small;
    FONT_TITLE = toString theme.fontSizes.title;
    STRIP_OPACITY = theme.opacity.strip;
    RAISED_OPACITY = theme.opacity.raised;
    OVERLAY_OPACITY = theme.opacity.overlay;
    RIM_OPACITY = theme.opacity.rim;
    HIGHLIGHT_OPACITY = theme.opacity.highlight;
    FILL_REST = theme.fill.rest;
    FILL_HOVER = theme.fill.hover;
    FILL_PRESSED = theme.fill.pressed;
    FILL_RIM = theme.fill.rim;
    DURATION_FAST = toString theme.motion.fast;
    DURATION_NORMAL = toString theme.motion.normal;
    DURATION_SLOW = toString theme.motion.slow;
    OVERSHOOT = theme.motion.overshoot;
    PRESS_SCALE = theme.motion.pressScale;
    ICON_WEIGHT = toString theme.iconWeight;
    RAISED_SHADOW_BLUR = toString theme.elevation.raised.blur;
    RAISED_SHADOW_Y = toString theme.elevation.raised.y;
    RAISED_SHADOW_OPACITY = theme.elevation.raised.opacity;
    FLOATING_SHADOW_BLUR = toString theme.elevation.floating.blur;
    FLOATING_SHADOW_Y = toString theme.elevation.floating.y;
    FLOATING_SHADOW_OPACITY = theme.elevation.floating.opacity;
    SHADOW_PAD = toString theme.elevation.pad;
  };

  themeQml = builtins.replaceStrings
    (map (name: "@${name}@") (builtins.attrNames substitutions))
    (builtins.attrValues substitutions)
    (builtins.readFile ../../config/quickshell/Theme.qml);
in
{
  home.packages = [ pkgs.quickshell ];

  xdg.configFile = {
    # The bar's QML lives in its native format; new files need no Nix edits.
    "quickshell/bar" = {
      source = ../../config/quickshell/bar;
      recursive = true;
    };

    "quickshell/bar/Theme.qml".text = themeQml;
  };

  # A service rather than niri's spawn-at-startup: restarts on crash, and
  # rebuilds restart it whenever the QML or theme changes (see below).
  systemd.user.services.quickshell-bar = {
    Unit = {
      Description = "Quickshell top bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
      # Quickshell only hot-reloads edits to the files it loaded; a rebuild
      # swaps in new store paths instead, so restart on any QML/theme change.
      X-Restart-Triggers = [
        "${../../config/quickshell/bar}"
        (builtins.hashString "sha256" themeQml)
      ];
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell --config bar";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
