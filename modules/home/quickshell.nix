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
    # Same corner radius as windows (niri geometry-corner-radius).
    RADIUS = toString theme.radius.medium;
    SPACING_SMALL = toString theme.spacing.small;
    SPACING_MEDIUM = toString theme.spacing.medium;
    SURFACE_OPACITY = theme.opacity.surface;
    FONT = theme.font.mono;
    FONT_SIZE = toString theme.font.size;
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
