{ pkgs, theme, ... }:
let
  inherit (theme) colors render percent;

  # Vesktop's icon (Papirus's is a rainbow): Papirus's Discord logo with the
  # circle in the accent and the glyph in the background colour, so it
  # follows the preset like the rest of the desktop.
  icon = pkgs.runCommand "vesktop-icon.svg" { } ''
    sed -e 's/fill:#5865f2/fill:${colors.accent}/' \
      -e 's/style="fill:#ffffff"/style="fill:${colors.background}"/' \
      ${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/discord.svg > $out
  '';

  # Each attribute fills the matching @NAME@ placeholder in the template.
  substitutions = {
    BACKGROUND = colors.background;
    SURFACE = colors.surface;
    FOREGROUND = colors.foreground;
    MUTED = colors.muted;
    ACCENT = colors.accent;
    RED = colors.red;
    GREEN = colors.green;
    YELLOW = colors.yellow;
    FILL_REST = percent theme.fill.rest;
    FILL_HOVER = percent theme.fill.hover;
    FILL_PRESSED = percent theme.fill.pressed;
    RIM = percent theme.opacity.rim;
    # The selection grey as a foreground overlay (Helix/kitty mix it solid).
    SELECTION = percent theme.tint.selection;
    FONT = theme.font.ui;
    FONT_MONO = theme.font.mono;
  };
in
{
  # Vesktop's launcher entry, as packaged but with the icon above; this copy
  # in ~/.local/share/applications takes the place of the package's.
  xdg.desktopEntries.vesktop = {
    name = "Vesktop";
    genericName = "Internet Messenger";
    comment = "Alternative Discord client with Vencord built-in";
    exec = "vesktop %U";
    icon = "${icon}";
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    mimeType = [ "x-scheme-handler/discord" ];
    settings = {
      Keywords = "discord;vencord;electron;chat";
      StartupWMClass = "Vesktop";
    };
  };

  # A Vencord theme in the design system's palette. Its name stays the same
  # across presets, so enabling it once (Vesktop: Settings -> Themes) keeps it
  # following whichever preset is active. Only the theme file is managed:
  # Vesktop's settings.json stays writable by Vesktop.
  xdg.configFile."vesktop/themes/zenbook.theme.css".text =
    render substitutions ../../config/vesktop/theme.css;
}
